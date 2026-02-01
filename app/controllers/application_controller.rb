class ApplicationController < ActionController::Base
  before_action :set_no_cache
  helper_method :current_family

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
