class CDX::Sign < CDX::LoggedRequest
  private

  def request
    client.call(
      :sign,
      {
        message: {
          securityToken: opts[:token],
          activityId: opts[:activity_id],
          signatureDocument: signature_document
        }
      }
    )
  end

  def signature_document
    {
      Name: "e-manifest #{opts[:id]}",
      Format: "BIN",
      Content: opts[:manifest]
    }
  end

  def repackage_response
    response.body[:sign_response][:document_id]
  end
end
