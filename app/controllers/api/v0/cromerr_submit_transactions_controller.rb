class Api::V0::CromerrSubmitTransactionsController < ApiController
  def create
    manifest = find_manifest(params[:manifest_id])
    authorize manifest, :can_submit?

    submit_request = read_body_as_json(symbolize_names: true)
    
    if validate_submit(submit_request)
      cdx_response = ManifestSubmitter.new(submit_request.merge(manifest: manifest)).perform

      unless performed?
        render(json: cdx_response.to_json, status: status_code(cdx_response))
      end
    end
  end

  private

  def validate_submit(content)
    run_validator(SubmitValidator.new(content))
  end

  def status_code(cdx_response)
    if cdx_response.key?(:transaction_id) && cdx_response[:status] != 'Failed'
      200
    else
      422
    end
  end
end
