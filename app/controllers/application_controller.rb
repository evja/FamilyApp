class ApplicationController < ActionController::Base


	def after_sign_in_path_for(resource)
	  if resource.family
	    family_path(resource.family)
	  else
	    new_family_path
	  end
	end

	before_action :set_no_cache

	private

	def set_no_cache
	  response.headers["Cache-Control"] = "no-store"
	end

	# app/controllers/application_controller.rb
	class ApplicationController < ActionController::Base
	  helper_method :current_family
	  def current_family
	    return @family if defined?(@family) && @family.present?
	    Family.find_by(id: params[:family_id] || params[:id]) || current_user&.family
	  end
	end

end
