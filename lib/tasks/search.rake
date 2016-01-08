require 'rake'
require 'digest/sha1'
require 'ansi'

namespace :search do

  desc 're-index all records, in parallel'
  task :index do
    nprocs     = ENV['NPROCS'] || 1
    batch_size = ENV['BATCH']  || 100
    max        = ENV['MAX']    || nil
    klass      = eval( ENV['CLASS']  || 'Manifest' )
    nprocs     = nprocs.to_i
    batch_size = batch_size.to_i

    create_mindex({
      :klass => klass, 
      :idx_name => klass.index_name,
      :nprocs => nprocs.to_i, 
      :batch_size => batch_size.to_i, 
      :max => max, 
      :force => ENV['FORCE']
    })
  end

  def create_mindex(opts)
    klass    = opts[:klass] or raise "klass required"
    idx_name = opts[:idx_name] or raise "idx_name required"
    nprocs   = opts[:nprocs] or raise "nprocs required"
    batch_size = opts[:batch_size] or raise "batch_size required"
    max        = opts[:max]
    force      = opts[:force]

    # calculate array of offsets based on nprocs
    total_expected = klass.count
    pool_size = (total_expected / nprocs).round
    offsets = []

    # get all ids since we can't assume there are no holes in the PK sequencing
    # because of the deleted_at paranoia feature.
    ids = klass.order('id ASC').pluck(:id)
    ids.each_slice(pool_size) do |chunk|
      #puts "chunk: size=#{chunk.size} #{chunk.first}..#{chunk.last}"
      offsets.push( chunk.first )
    end
    puts ANSI.blue{ "index=#{idx_name} total=#{total_expected} nprocs=#{nprocs} pool_size=#{pool_size} offsets=#{offsets} " }

    if force
      puts "Force creating new index"
      klass.__elasticsearch__.create_index! force: true, index: idx_name
      klass.__elasticsearch__.refresh_index!
    end

    current_db_config = ActiveRecord::Base.connection_config

    offsets.each do |start_at|
      ActiveRecord::Base.connection.disconnect! # IMPORTANT before fork
      fork do
        # child worker
        # IMPORTANT after fork
        ActiveRecord::Base.establish_connection(current_db_config)

        completed = 0
        errors    = []
        puts ANSI.blue{ "Start worker #{$$} at offset #{start_at}" }
        pbar = ANSI::Progressbar.new("#{klass} [#{$$}]", pool_size, STDOUT) rescue nil
        checkpoint = false
        if pbar
          pbar.__send__ :show
          pbar.bar_mark = '='
        else
          checkpoint = true
        end

        klass.__elasticsearch__.import :return => 'errors',
        :index => idx_name,
        :start => start_at,
        :batch_size => batch_size    do |resp|
          # show errors immediately (rather than buffering them)
          errors += resp['items'].select { |k, v| k.values.first['error'] }
          completed += resp['items'].size
          pbar.inc resp['items'].size if pbar
          puts ANSI.blue{ "[#{$$}] #{Time.now.utc.iso8601} : #{completed} records completed" } if checkpoint
          STDERR.flush
          STDOUT.flush
          if errors.size > 0
            STDOUT.puts "ERRORS in #{$$}:"
            STDOUT.puts pp(errors)
          end
          if completed >= pool_size || (max && max.to_i == completed)
            pbar.finish if pbar
            puts ANSI.blue{ "Worker #{$$} finished #{completed} records" }
            exit # exit child worker
          end
        end
        # end callback
      end
    end
    results = Process.waitall

    # check exit status of each child so we know if we should throw exception
    results.each do |pair|
      pid = pair[0]
      pstat = pair[1]
      exit_ok = true
      if pstat.exited?
        puts ANSI.blue{ "PID #{pid} exited with #{pstat.exitstatus}" }
      end
      if pstat.signaled?
        puts ANSI.red{ " >> #{pid} exited with uncaught signal #{pstat.termsig}" }
        exit_ok = false
      end

      if !pstat.success?
        puts ANSI.red{ " >> #{pid} was not successful" }
        exit_ok = false
      end

      if pair[1].exitstatus != 0
        puts ANSI.red{ " >> #{pid} exited with non-zero status" }
        exit_ok = false
      end

      if !exit_ok
        raise ANSI.red{ "PID #{pair[0]} exited abnormally, so the whole reindex fails" }
      end
    end

  end

  desc 'stage a reindex of all records'
  task :stage do
    nprocs     = ENV['NPROCS'] || 1
    batch_size = ENV['BATCH']  || 100
    max        = ENV['MAX']    || nil
    klass      = eval( ENV['CLASS']  || 'Manifest' )
    nprocs     = nprocs.to_i
    batch_size = batch_size.to_i

    tmp_idx_name = tmp_index_name(klass)
    stage_idx_name = klass.index_name + '_staged'

    # create temp index
    create_mindex({
      :klass => klass,
      :idx_name => tmp_idx_name,
      :nprocs => nprocs.to_i,
      :batch_size => batch_size.to_i,
      :max => max,
      :force => true
    })

    # create alias
    es_client = klass.__elasticsearch__.client
    
    es_client.indices.delete index: stage_idx_name rescue false
    es_client.indices.update_aliases body: {
      actions: [
        { add: { index: tmp_idx_name, alias: stage_idx_name } },
      ]
    }

    # clean up
    old_aliases = es_client.indices.get_aliases(index: stage_idx_name).keys
    old_aliases.each do |alias_name|
      begin
        if Time.parse(alias_name.gsub(/^.+_/, '')) < 1.weeks.ago
          es_client.indices.delete index: alias_name
          puts ANSI.blue{ "Cleaned up old alias #{alias_name}" }
        end
      rescue => err
        puts ANSI.red{ "Failed to clean up alias #{alias_name}: #{err}" }
      end
    end

    puts ANSI.blue{ "[#{Time.now.utc.iso8601}] #{klass} index staged as #{stage_idx_name}" }
  end

  desc 'commit the staged index to be the new index'
  task commit: [:environment] do
    klass = eval( ENV['CLASS']  || 'Manifest' )
    stage_idx_name = klass.index_name + '_staged'

    es_client = klass.__elasticsearch__.client

    # find the newest tmp index to which staged is aliased.
    # we need this because we want to re-alias it.
    stage_aliased_to = nil
    stage_aliases = es_client.indices.get_aliases(index: stage_idx_name)
    stage_aliases.each do |k,v|
      stage_aliased_to ||= k
      stage_tstamp = stage_aliased_to.gsub(/^.+_/, '')
      tstamp = k.gsub(/^.+_/, '')
      if Time.parse(stage_tstamp) < Time.parse(tstamp)
        stage_aliased_to = k
      end
    end
    if !stage_aliased_to
      raise "Cannot identify index aliased to by '#{stage_idx_name}'"
    end

    # the renaming actions (performed atomically by ES)
    rename_actions = [
      { remove: { index: stage_aliased_to, alias: stage_idx_name } },
      {    add: { index: stage_idx_name, alias: klass.index_name } }
    ]

    # zap any existing index known as index_name,
    # but do it conditionally since it is reasonable that it does not exist.
    to_delete = []
    existing_live_index = es_client.indices.get_aliases(index: klass.index_name)
    existing_live_index.each do |k,v|
       
      # if the index is merely aliased, remove its alias as part of the aliasing transaction.
      if k != klass.index_name
        rename_actions.unshift({ remove: { index: k, alias: klass.index_name } })

        # and mark it for deletion when we've successfully updated aliases
        to_delete.push k

      # otherwise, this is a real, unaliased index with this name, so it must be deleted.
      # (This usually happens the first time we implement the aliasing scheme against an existing installation.)
      else
        es_client.indices.delete index: klass.index_name rescue false
      end
    end

    # re-alias
    es_client.indices.update_aliases body: { actions: rename_actions }

    # clean up
    to_delete.each do |idxname|
      es_client.indices.delete index: idxname rescue false
    end

    # all done.
    puts "[#{Time.now.utc.iso8601}] #{klass} promoted #{stage_idx_name} to #{klass.index_name}"
  end


  def tmp_index_name(klass)
    klass.index_name + '_' + Time.now.strftime('%Y%m%d%H%M%S')
  end

end
