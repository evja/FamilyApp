class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all
    @leads = Lead.all
    @families = Family.all
    @subscribers = User.where(is_subscribed: true)# Adjust when Stripe is fully integrated
  end

  private

  def require_admin
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end
end