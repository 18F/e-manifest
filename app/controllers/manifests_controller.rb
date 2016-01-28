class ManifestsController < ApplicationController
  include ManifestParams

  def new
  end

  def create
    @manifest = Manifest.new(content: manifest_params)

    if @manifest.save && validate_manifest(manifest_params)
      @manifest.reload
      tracking_number = @manifest.tracking_number
      flash[:notice] = "Manifest #{tracking_number} submitted successfully."
      redirect_to new_manifest_sign_or_upload_path(@manifest.uuid)
    else
      flash[:error] = [[@errors] + [@manifest.errors.full_messages]].flatten.compact.to_sentence
      render :new
    end
  end

  def index
    if params[:q] || params[:aq]
      @search_response = Manifest.authorized_search(params)
    else
      @search_response = Manifest.authorized_search(params.merge({public: true}))
    end
    @es_response = @search_response[:es_response]
    @manifests = @es_response.records.to_a
    build_search_stats
  end

  def show
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:id])
  end

  private

  def validate_manifest(content)
    validator = ManifestValidator.new(content)
    unless validator.run
      @errors = validator.error_messages
    end
    !validator.errors.any?
  end

  def build_search_stats
    dsl_hash = @search_response[:dsl].to_hash
    @stats = {
      from: dsl_hash[:from] + 1,
      to: dsl_hash[:from] + dsl_hash[:size],
      total: @search_response[:es_response].results.total,
    }
    if @stats[:total] < dsl_hash[:size]
      @stats[:to] = @stats[:total]
    end
  end
end
