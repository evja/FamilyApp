class FamilyInvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:accept]
  before_action :set_family, except: [:accept]
  before_action :ensure_family_member, except: [:accept]
  before_action :set_invitation, only: [:destroy]

  def new
    @invitation = @family.invitations.new
  end

  def create
    @invitation = @family.invitations.new(invitation_params)

    if @invitation.save
      invite_url = accept_family_invitation_url(@invitation.token)

      if ENV["EMAIL_INVITES_ENABLED"] == "true"
        FamilyMailer.invitation_email(@invitation).deliver_later
        redirect_to family_path(@family), notice: "Invitation sent successfully."
      else
        redirect_to new_family_family_invitation_path(@family),
          notice: "Email is disabled. Copy/share this invite link: #{invite_url}"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation.expire!
    redirect_back fallback_location: family_path(@family), notice: 'Invitation cancelled successfully.'
  end

  def accept
    @invitation = FamilyInvitation.find_by(token: params[:token])

    if @invitation.nil? || @invitation.expired?
      redirect_to root_path, alert: 'Invalid or expired invitation.'
      return
    end

    unless user_signed_in?
      session[:invitation_token] = params[:token]
      redirect_to new_user_registration_path, notice: 'Please create an account to join the family.'
      return
    end

    unless @invitation.email.downcase == current_user.email.downcase
      redirect_to root_path, alert: 'This invitation was sent to a different email address.'
      return
    end

    if current_user.family.present? && current_user.family != @invitation.family
      redirect_to family_path(current_user.family), alert: 'You are already a member of another family.'
      return
    end

    current_user.update!(family: @invitation.family)
    @invitation.accept!
    session.delete(:invitation_token)
    redirect_to family_path(@invitation.family), notice: 'Welcome to the family!'
  end

  private

  def set_family
    @family = current_user.family
    head :forbidden unless @family && @family.id.to_s == params[:family_id]
  end

  def set_invitation
    @invitation = @family.invitations.find(params[:id])
  end

  def ensure_family_member
    unless @family.can_be_accessed_by?(current_user)
      redirect_to root_path, alert: 'You do not have permission to access this family.'
      return
    end
  end

  def invitation_params
    params.require(:family_invitation).permit(:email)
  end
end 