class HomeController < ApplicationController
  def index
    if user_signed_in? && current_user.family
      redirect_to family_path(current_user.family)
    end
  end

  def about

  end
end
