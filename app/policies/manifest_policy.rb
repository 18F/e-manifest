class ManifestPolicy < ApplicationPolicy
  def can_sign?
    user && signer? && shares_org?
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

  def signer?
    user.tsdf_certifier?
  end

  def shares_org?
    user.shares_organization?(record.user)
  end
end
