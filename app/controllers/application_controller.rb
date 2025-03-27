class ApplicationController < ActionController::Base


	def after_sign_in_path_for(resource)
	  if resource.family
	    family_path(resource.family)
	  else
	    new_family_path
	  end
	end
	
end
