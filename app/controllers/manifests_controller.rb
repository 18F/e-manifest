class ManifestsController < ApplicationController
  include ManifestParams
  include SearchParams

  def new
    authenticate_user!
  end

  def create
    authenticate_user!

    @manifest = Manifest.new(content: manifest_params, user: current_user)

    if @manifest.valid? && validate_manifest(manifest_params)
      @manifest.save!
      @manifest.reload
      flash[:notice] = "Manifest #{@manifest.tracking_number} submitted successfully."
      redirect_to new_manifest_sign_or_upload_path(@manifest.uuid)
    else
      flash[:error] = validation_errors
      render :new
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

  def has_permission?
    if !@manifest.is_public?
      authenticate_user!

      unless performed?
        # TODO apply org+roles authz policy
        if @manifest.user != current_user
          render_authz_error
          false
        end
      end
    end
    true
  end

  def render_authz_error
    render "authorization_error", status: 403, locals: { msg: "You do not have permission to view this record." }
  end

  def validation_errors
    if @manifest.errors.any?
      @manifest.errors.full_messages.to_sentence
    elsif @errors
      @errors
    end
  end

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
