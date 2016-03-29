class ManifestsController < ApplicationController
  include ManifestParams
  include SearchParams

  def new
    authenticate_user!
    unless performed?
      authorize Manifest.new, :can_create?
    end
  end

  def create
    authenticate_user!

    unless performed?
      @manifest = Manifest.new(content: manifest_params, user: current_user)

      authorize @manifest, :can_create?

      if @manifest.valid? && validate_manifest(manifest_params)
        create_manifest
      else
        flash[:error] = error_messages
        render :new
      end
    end
  end

  def index
    if !authenticated? || !has_search_params?
      params.merge!({public: true})
    end
    @search_response = Manifest.authorized_search(params, current_user)
    @es_response = @search_response[:es_response]
    @manifests = @es_response.records.to_a
    build_search_stats
  end

  def show
    @manifest = Manifest.find_by_uuid_or_tracking_number!(params[:id])
    has_permission? or return
  end

  private

  def create_manifest
    @manifest.save!
    @manifest.reload
    flash[:notice] = "Manifest #{@manifest.tracking_number} submitted successfully."
    redirect_to new_manifest_sign_or_upload_path(@manifest.uuid)
  end

  def has_permission?
    if !@manifest.is_public?
      authenticate_user!

      unless performed?
        authorize @manifest, :can_view?
      end
    end
    true
  end

  def validate_manifest(content)
    validator = ManifestValidator.new(content)
    unless validator.run
      @errors = validator.error_messages
    end
    !validator.errors.any?
  end

  def error_messages
    [[@errors] + [@manifest.errors.full_messages]].flatten.compact.to_sentence
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
