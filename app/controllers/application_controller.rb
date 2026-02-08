class ApplicationController < ActionController::Base
  before_action :set_no_cache
  helper_method :current_family, :current_member, :viewing_as_user?, :show_admin_features?, :visible_modules

  DASHBOARD_MODULES = %w[Members Issues Vision Rhythms Relationships Responsibilities Rituals].freeze

  def after_sign_in_path_for(resource)
    if session[:invitation_token].present?
      accept_family_invitation_path(token: session[:invitation_token])
    elsif resource.active_family
      family_path(resource.active_family)
    else
      new_family_path
    end
  end

  def after_sign_up_path_for(resource)
    if session[:invitation_token].present?
      accept_family_invitation_path(token: session[:invitation_token])
    elsif resource.active_family
      family_path(resource.active_family)
    else
      new_family_path
    end
  end

  def current_family
    return @family if defined?(@family) && @family.present?
    Family.find_by(id: params[:family_id] || params[:id]) || current_user&.active_family
  end

  def current_member
    @current_member ||= current_user&.member_in(current_family)
  end

  def toggle_view_as_user
    if current_user&.admin?
      if session[:view_as_user]
        session.delete(:view_as_user)
      else
        session[:view_as_user] = true
      end
    end
    redirect_back fallback_location: root_path
  end

  def viewing_as_user?
    current_user&.admin? && session[:view_as_user].present?
  end

  def show_admin_features?
    current_user&.admin? && !viewing_as_user?
  end

  def toggle_module_visibility
    return head :forbidden unless current_user&.admin?

    mod = params[:module_name]
    return head :bad_request unless DASHBOARD_MODULES.include?(mod)

    hidden = session[:hidden_modules] ||= []
    if hidden.include?(mod)
      hidden.delete(mod)
    else
      hidden << mod
    end

    redirect_back fallback_location: admin_dashboard_path
  end

  def visible_modules
    all = DASHBOARD_MODULES.dup
    hidden = session[:hidden_modules] || []
    all - hidden
  end

  private

  def set_no_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def authorize_family!
    @family = Family.find_by(id: params[:family_id].to_i)
    unless @family && current_user.member_of?(@family)
      redirect_to root_path, alert: "You do not have access to this family."
      return
    end
  end
end
