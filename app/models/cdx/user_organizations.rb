class CDX::UserOrganizations < CDX::ProfileRequest
  private

  def request
    client.call(
      :retrieve_organizations_by_dataflow,
      {   
        message: {
          securityToken: security_token,
          user: user_profile,
          dataflow: (opts[:dataflow] || ENV['CDX_DEFAULT_DATAFLOW'])
        }   
      }   
    )   
  end

  def repackage_response
    lower_camelize(orgs_data.is_a?(Array) ? orgs_data : [orgs_data])
  end 

  def orgs_data
    @orgs_data ||= response.hash[:envelope][:body][:retrieve_organizations_by_dataflow_response][:organization]
  end
end
