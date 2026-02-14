class Admin::LeadsController < ApplicationController
  require "csv"
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @leads = filter_leads.order(created_at: :desc)
    @filter = params[:filter] || "all"

    # Stats for dashboard cards
    @total_count = Lead.count
    @hot_count = Lead.hot_leads.count
    @warm_count = Lead.warm_leads.count
    @survey_completed_count = Lead.where(survey_completed: true).count
  end

  def export
    @leads = filter_leads

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["First Name", "Last Name", "Email", "Signal Strength", "Family Size", "Biggest Challenge", "Source", "Campaign", "Survey Completed", "Created At"]

      @leads.each do |lead|
        csv << [
          lead.first_name,
          lead.last_name,
          lead.email,
          lead.signal_strength,
          lead.family_size,
          lead.biggest_challenge,
          lead.source,
          lead.campaign,
          lead.survey_completed ? "Yes" : "No",
          lead.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end

    send_data csv_data, filename: "familyhub-leads-#{Date.today}.csv"
  end

  private

  def filter_leads
    case params[:filter]
    when "hot"
      Lead.hot_leads
    when "warm"
      Lead.warm_leads
    when "cold"
      Lead.cold_leads
    else
      Lead.all
    end
  end

  def require_admin!
    unless current_user.admin?
      redirect_to root_path
      return
    end
  end
end