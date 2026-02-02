class IssueAssistsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!

  def create
    remaining = IssueAssist.remaining_today(@family)

    if remaining <= 0
      render json: { error: "You've reached the daily limit of #{IssueAssist::DAILY_LIMIT} assists. Try again tomorrow." }, status: :too_many_requests
      return
    end

    description = params[:description].to_s.strip
    if description.blank?
      render json: { error: "Please write a description first." }, status: :unprocessable_entity
      return
    end

    result = IssueAssistant.new(description).call

    if result[:error]
      render json: { error: result[:error] }, status: :service_unavailable
      return
    end

    IssueAssist.create!(
      family: @family,
      user: current_user,
      original_text: description,
      suggested_text: result[:suggested]
    )

    render json: {
      suggested: result[:suggested],
      tip: result[:tip],
      remaining: remaining - 1
    }
  end
end
