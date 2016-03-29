require 'elasticsearch/dsl'

module Search
  class QueryDSL
    include Elasticsearch::DSL

    MAX_RESULTS = 100

    attr_reader :params, :user, :query_str

    def initialize(args)
      @user = args[:user]
      @params = args[:params]
      @query_str = @params[:q]
      build_dsl
    end

    def to_hash
      @dsl.to_hash
    end

    def default_operator
      params[:operator] || "and"
    end

    def apply_authz?
      if user == nil
        false
      else
        !(user.epa_data_download? || user.state_data_download?)
      end
    end

    def apply_state_authz?
      user && user.state_data_download_states.any? && user.state_data_download?
    end

    def apply_public_filter?
      params[:public] || apply_state_authz?
    end

    def composite_query_string
      stringify_clauses [query_str, client_query].select(&:present?)
    end

    def humanized_query_string
      stringify_clauses [query_str, client_query_humanized].select(&:present?)
    end

    def client_query
      fielded = params[:aq]
      munge_fielded_params(fielded) if fielded
      FieldedQuery.new(fielded)
    end

    private

    def stringify_clauses(clauses)
      if clauses.length == 2
        clauses.map { |c| "(#{c})" }.join(" AND ")
      elsif clauses.length == 1
        clauses[0].to_s
      else
        ""
      end
    end

    def client_query_humanized
      client_query.humanized(user.client_model)
    end

    def munge_fielded_params(fielded)
      if fielded[:created_at].present? && fielded[:created_within].present?
        munge_created_at_field(fielded)
      end
      # do not calculate more than once, or when created_at is null
      fielded.delete(:created_within)
    end

    def munge_created_at_field(fielded)
      high_end_range = Time.zone.parse(fielded[:created_at])
      within_parsed = fielded[:created_within].match(/^(\d+) (\w+)/)
      return unless high_end_range && within_parsed
      low_end_range = high_end_range.utc - within_parsed[1].to_i.send(within_parsed[2])
      fielded[:created_at] = "[#{low_end_range} TO #{high_end_range.utc}]"
    end

    def build_dsl
      @dsl = Elasticsearch::DSL::Search::Search.new
      add_query
      add_filter
      add_sort
      add_pagination
    end

    def add_query
      searchdsl = self
      return unless composite_query_string.present?
      @dsl.query = Query.new
      @dsl.query do
        query_string do
          query searchdsl.composite_query_string
          default_operator searchdsl.default_operator
        end
      end
    end

    def add_filter
      bools = build_filters

      if bools.any?
        @dsl.filter = Filter.new
        @dsl.filter.bool do
          bools.each do |should_filter|
            filter_block = should_filter.instance_variable_get(:@block)
            should &filter_block
          end
        end
      end
    end

    def build_filters
      bools = []
      if apply_authz?
        bools.push authz_filter
      end
      if apply_state_authz?
        bools.push state_authz_filter
      end
      if apply_public_filter?
        bools.push public_filter
      end
      bools.flatten
    end

    def authz_filter
      searchdsl = self
      Filter.new do
        term user_id: searchdsl.user.id
      end
    end

    def public_filter
      Filter.new do
        range :created_at do
          lt 'now-90d'
        end
      end
    end

    def state_authz_filter
      searchdsl = self
      state_filters = []
      @user.state_data_download_states.each do |user_state|
        Manifest.state_fields.each do |field|
          state_filters << Filter.new do
            term "content.#{field}" => user_state.downcase
          end
        end
      end
      state_filters
    end

    def add_sort
      if params[:sort]
        @dsl.sort(params[:sort].map{ |pair| [pair.split(':')].to_h })
      end
    end

    def add_pagination
      return if params[:size] == :all
      calculate_from_size if params[:page]
      add_from
      add_size
    end

    def add_from
      if @from
        @dsl.from = @from
      elsif params[:from]
        @dsl.from = params[:from].to_i
      else
        @dsl.from = 0
      end
    end

    def add_size
      if @size
        @dsl.size = @size
      elsif params[:size]
        @dsl.size = params[:size].to_i
      else
        @dsl.size = MAX_RESULTS
      end
    end

    def calculate_from_size
      page = params[:page].to_i
      @size ||= (params[:size] || MAX_RESULTS).to_i
      @from = (page - 1) * @size.to_i
    end
  end
end
