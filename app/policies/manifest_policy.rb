class ManifestPolicy < ApplicationPolicy
  def can_sign?
    user && signer_in_shared_org?
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
      shared_org_ids.include?(uor.organization_id) && uor.role.tsdf_certifier?
    end.any?
  end

  def signer?
    user.tsdf_certifier?
  end

  def shares_org?
    user.shares_organization?(record.user)
  end
end
