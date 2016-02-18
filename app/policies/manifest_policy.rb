class ManifestPolicy < ApplicationPolicy
  def can_sign?
    user && signer? && shares_org?
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
