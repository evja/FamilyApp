class FamilyVisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_colors

  def show
    @vision = @family.vision || @family.build_vision
    @values = @family.family_values
  end

  def edit
    @vision = @family.vision || @family.build_vision
    @existing_values = @family.family_values.pluck(:name)
    @assist_remaining = IssueAssist.remaining_today(@family)
  end

  def update
    @vision = @family.vision || @family.build_vision
    update_successful = false

    ActiveRecord::Base.transaction do
      # Sync family values from submitted names
      if params[:family_vision][:value_names].present?
        value_names = JSON.parse(params[:family_vision][:value_names])
        @family.family_values.delete_all
        value_names.each do |name|
          @family.family_values.create!(name: name.strip) if name.strip.present?
        end
      end

      if @vision.update(vision_params)
        update_successful = true
      else
        raise ActiveRecord::Rollback
      end
    end

    if update_successful
      # Mark vision tour as completed to prevent modal showing after save
      session[:completed_tours] ||= []
      session[:completed_tours] << "vision" unless session[:completed_tours].include?("vision")
      redirect_to family_vision_path(@family), notice: "Family vision updated!"
    else
      @existing_values = @family.family_values.reload.pluck(:name)
      @assist_remaining = IssueAssist.remaining_today(@family)
      render :edit, status: :unprocessable_entity
    end
  end

  def assist
    remaining = IssueAssist.remaining_today(@family)

    if remaining <= 0
      render json: { error: "You've reached the daily limit of #{IssueAssist::DAILY_LIMIT} assists. Try again tomorrow." }, status: :too_many_requests
      return
    end

    values = params[:values].presence || []
    if values.empty?
      render json: { error: "Please select at least one value first." }, status: :unprocessable_entity
      return
    end

    result = VisionAssistant.new(values).call

    if result[:error]
      render json: { error: result[:error] }, status: :service_unavailable
      return
    end

    IssueAssist.create!(
      family: @family,
      user: current_user,
      original_text: "Vision assist: #{values.join(', ')}",
      suggested_text: result[:suggestions].join(" | ")
    )

    render json: {
      suggestions: result[:suggestions],
      remaining: remaining - 1
    }
  end

  private

  def set_colors
    @colors = @family.theme_colors
  end

  def vision_params
    params.require(:family_vision).permit(:mission_statement, :notes, :ten_year_dream)
  end
end
