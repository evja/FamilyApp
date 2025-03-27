class LeadsController < ApplicationController
  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      redirect_to root_path, notice: "Thanks! We'll let you know when FamilyApp is ready."
    else
      redirect_to root_path, alert: @lead.errors.full_messages.to_sentence
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:email)
  end
end