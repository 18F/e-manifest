class CDX::Sign < CDX::LoggedRequest
  private

  def request
    client.call(
      :submit,
      {
        message: {
          securityToken: opts[:token],
          dataflow: (opts[:dataflow] || ENV['CDX_MANIFEST_SUBMIT_DATAFLOW']),
          documents: signature_document
        }
      }
    )
  end

  def client
    CDX::Client::Submit
  end
  
  def signature_document
    {
      documentName: "e-manifest #{opts[:id]}",
      documentFormat: "OTHER",
      documentContent: Base64.encode64(opts[:manifest])
    }
  end

  def repackage_response
    status = response.body[:submit_response][:status]

    if status != "Failed"
      response.body[:submit_response][:transaction_id]
    end
  end
end
