class CDX::UserRoles < CDX::ProfileRequest
  private

  def request
    client.call(
      :retrieve_roles_for_dataflow,
      {
        message: {
          securityToken: security_token,
          user: user_profile,
          organzation: opts[:organization], # NOTE the typo here reflects a bug in the upstream API
          dataflow: (opts[:dataflow] || ENV['CDX_DEFAULT_DATAFLOW'])
        }
      }
    )
  end

  def repackage_response
    lower_camelize(roles_data.is_a?(Array) ? roles_data : [roles_data])
  end 

  def roles_data
    @roles_data ||= response.hash[:envelope][:body][:retrieve_roles_for_dataflow_response][:role]
  end
end
