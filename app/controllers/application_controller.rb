class ApplicationController < ActionController::Base
  before_action :set_no_cache
  helper_method :current_family, :viewing_as_user?, :show_admin_features?

  def after_sign_in_path_for(resource)
    if resource.family
      family_path(resource.family)
    else
      new_family_path
    end
  end

  def current_family
    return @family if defined?(@family) && @family.present?
    Family.find_by(id: params[:family_id] || params[:id]) || current_user&.family
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

  private

  def set_no_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def authorize_family!
    @family = current_user.family
    unless @family && @family.id == params[:family_id].to_i
      redirect_to root_path, alert: "You do not have access to this family."
    end
  end
end
