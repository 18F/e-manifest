class ManifestPolicy < ApplicationPolicy
  def can_submit?
    user && signer_in_shared_org?
  end

  def can_view?
    public_manifest? || (user && (owner? || shares_org? || epa_data_download? || shares_state?))
  end

  def can_create?
    user && signer?
  end

  def can_update?
    user && owner?
  end

  def debug_user
    puts "user=#{user.pretty_inspect}"
    puts "signer?=#{signer?}"
    puts "shares_org?=#{shares_org?}"
    puts "authz=#{user.user_org_roles.pretty_inspect}"
    puts "orgs=#{user.organizations.pretty_inspect}"
    puts "roles=#{user.roles.pretty_inspect}"
  end

  def owner?
    record.user_id == user.id
  end

  def signer_in_shared_org?
    shared_org_ids = user.shares_organizations(record.user)
    user.user_org_roles.select do |uor| 
      shared_org_ids.include?(uor.organization_id) && uor.role.tsdf_certifier? && uor.cdx_status == 'Active'
    end.any?
  end

  def signer?
    user.tsdf_certifier?
  end

  def shares_org?
    user.shares_organization?(record.user)
  end

  def epa_data_download?
    user.epa_data_download?
  end

  def state_data_download?
    user.state_data_download?
  end

  def shares_state?
    user.state_data_download_states.select do |state|
      record.has_state?(state)
    end.any?
  end

  def public_manifest?
    record.is_public?
  end
end
