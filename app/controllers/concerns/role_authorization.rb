module RoleAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_member
  end

  def current_member
    return @current_member if defined?(@current_member)
    @current_member = current_user&.member
  end

  def require_parent_access!
    unless current_user&.family_parent?
      redirect_to family_path(current_user.family), alert: "You need parent access to perform this action."
      return false
    end
    true
  end

  def require_admin_access!
    unless current_user&.family_admin?
      redirect_to family_path(current_user.family), alert: "Only the family admin can perform this action."
      return false
    end
    true
  end
end
