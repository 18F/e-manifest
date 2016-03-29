class Api::V0::SignaturesController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    signature_request = read_body_as_json(symbolize_names: true)
    authorize manifest, :can_submit?

    if validate_signature(signature_request)
      cdx_response = ManifestSigner.new(signature_request.merge(manifest: manifest,
                                                                user_session: user_session,
                                                                current_user: current_user,
                                                                cdx_user_role_id: cdx_user_role_id(manifest))).perform

      unless performed?
        render(json: cdx_response.to_json, status: status_code(cdx_response))
      end
    end
  end

  private

  def validate_signature(content)
    run_validator(SignatureValidator.new(content))
  end

  def cdx_user_role_id(manifest)
    shared_org_ids = current_user.shares_organizations(manifest.user)
    current_user.user_org_roles.select do |uor| 
      shared_org_ids.include?(uor.organization_id) && uor.role.tsdf_certifier? && uor.cdx_status == 'Active'
    end.first[:cdx_user_role_id]
  end
  
  def status_code(cdx_response)
    if cdx_response.key?(:transaction_id)
      200
    else
      422
    end
  end
end
