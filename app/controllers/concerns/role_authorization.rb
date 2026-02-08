module RoleAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_member
  end

  def current_member
    return @current_member if defined?(@current_member)
    @current_member = current_user&.member_in(@family)
  end

  def require_parent_access!
    unless current_member&.parent_or_above?
      redirect_to family_path(@family), alert: "You need parent access to perform this action."
      return false
    end
    true
  end

  def require_admin_access!
    unless current_member&.admin_parent?
      redirect_to family_path(@family), alert: "Only the family admin can perform this action."
      return false
    end
    true
  end

  def require_edit_access!
    unless current_member&.can_edit?
      redirect_to family_path(@family), alert: "Advisors have view-only access."
      return false
    end
    true
  end
end
