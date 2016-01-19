class CDX::Activity < CDX::LoggedRequest
  alias :create :perform

  private

  def request_properties
    [
      {:Property => {:Key => "activityDescription", :Value => opts[:activity_description]}},
      {:Property => {:Key => "roleCode", :Value => opts[:role_code]}}
    ]
  end

  def request
    client.call(:create_activity_with_properties, {
      message: {
        :securityToken => opts[:token],
        :signatureUser => opts[:signature_user],
        :dataflowName => opts[:dataflow_name],
        :properties => request_properties
      }
    })
  end

  def repackage_response
    response.body[:create_activity_with_properties_response][:activity_id]
  end
end
