class Admin::LeadsController < ApplicationController
  require "csv"
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @leads = Lead.order(created_at: :desc)
  end


  def export
    @leads = Lead.all

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Email", "Created At"]

      @leads.each do |lead|
        csv << [lead.email, lead.created_at.strftime("%Y-%m-%d %H:%M:%S")]
      end
    end

    send_data csv_data, filename: "familyhub-leads-#{Date.today}.csv"
  end

  private

  def require_admin!
    redirect_to root_path unless current_user.admin?
  end
end