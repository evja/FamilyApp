class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all
    @leads = Lead.all
    @families = Family.all

    # Subscribers (users and families)
    @user_subscribers = User.subscribed.includes(:families).order(created_at: :desc)
    @family_subscribers = Family.subscribed.includes(:members).order(created_at: :desc)
    @total_subscribers = @user_subscribers.count + @family_subscribers.count

    # Lead filtering
    @lead_filter = params[:lead_filter] || "all"
    @filtered_leads = case @lead_filter
      when "hot" then Lead.hot_leads.order(created_at: :desc).limit(10)
      when "warm" then Lead.warm_leads.order(created_at: :desc).limit(10)
      when "cold" then Lead.cold_leads.order(created_at: :desc).limit(10)
      else Lead.order(created_at: :desc).limit(10)
    end

    # Lead counts by signal
    @hot_leads_count = Lead.hot_leads.count
    @warm_leads_count = Lead.warm_leads.count
    @cold_leads_count = Lead.cold_leads.count
  end

  private

  def require_admin
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end
end