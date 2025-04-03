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

end
