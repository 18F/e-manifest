require 'elasticsearch/dsl'
require_relative 'fielded_search'

class QueryDSL
  include Elasticsearch::DSL

  MAX_RESULTS = 100

  attr_reader :params, :current_user, :query_str

  def initialize(args)
    @current_user = args[:current_user]
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
    current_user != nil
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
    FieldedSearch.new(fielded)
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
    client_query.humanized(current_user.client_model)
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
    @dsl.query = Query.new
    @dsl.query do
      query_string do
        query searchdsl.composite_query_string
        default_operator searchdsl.default_operator
      end
    end
  end

  def add_filter
    searchdsl = self
    if apply_authz?
      @dsl.filter = Filter.new
      @dsl.filter do
        bool do
          must do
            term "subscribers.id" => searchdsl.current_user.id.to_s
          end
        end
      end
    end
  end

  def add_sort
    if params[:sort]
      @dsl.sort = params[:sort]
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
      @dsl.from = params[:from]
    else
      @dsl.from = 0
    end
  end

  def add_size
    if @size
      @dsl.size = @size
    elsif params[:size]
      @dsl.size = params[:size]
    else
      @dsl.size = MAX_RESULTS
    end
  end

  def calculate_from_size
    page = params[:page].to_i
    @size ||= params[:size] || MAX_RESULTS
    @from = (page - 1) * @size.to_i
  end
end
