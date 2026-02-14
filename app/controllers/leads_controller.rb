class LeadsController < ApplicationController
  def create
    @lead = Lead.new(lead_params)

    # Honeypot check - silently accept but don't save
    if @lead.hp.present?
      # Return success to fool the bot
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("waitlist_content", partial: "leads/success", locals: { lead: Lead.new(first_name: "Friend") }) }
        format.html { redirect_to root_path, notice: "Thanks! We'll let you know when FamilyHub is ready." }
      end
      return
    end

    if @lead.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("waitlist_content", partial: "leads/success", locals: { lead: @lead }) }
        format.html { redirect_to root_path, notice: "Thanks! We'll let you know when FamilyHub is ready." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("waitlist_content", partial: "leads/form", locals: { lead: @lead }) }
        format.html { redirect_to root_path, alert: @lead.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @lead = Lead.find(params[:id])

    @lead.assign_attributes(survey_params)
    @lead.survey_completed = true

    if @lead.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("waitlist_content", partial: "leads/survey_thanks", locals: { lead: @lead }) }
        format.html { redirect_to root_path, notice: "Thanks for completing the survey!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("waitlist_content", partial: "leads/success", locals: { lead: @lead }) }
        format.html { redirect_to root_path, alert: @lead.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:first_name, :last_name, :email, :hp, :source, :campaign, :referral_source)
  end

  def survey_params
    params.require(:lead).permit(:family_size, :biggest_challenge)
  end
end