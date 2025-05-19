class FamilyInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family, except: [:accept]
  before_action :ensure_family_member, except: [:accept]
  before_action :set_invitation, only: [:destroy]

  def new
    @invitation = @family.invitations.new
  end

  def create
    @invitation = @family.invitations.new(invitation_params)

    if @invitation.save
      # TODO: Send invitation email
      FamilyMailer.invitation_email(@invitation).deliver_later
      redirect_to family_path(@family), notice: 'Invitation sent successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation.expire!
    redirect_to family_path(@family), notice: 'Invitation cancelled successfully.'
  end

  def accept
    @invitation = FamilyInvitation.find_by(token: params[:token])

    if @invitation&.valid? && @invitation.email == current_user.email
      current_user.update(family: @invitation.family)
      @invitation.accept!
      redirect_to family_path(@invitation.family), notice: 'Welcome to the family!'
    else
      redirect_to root_path, alert: 'Invalid or expired invitation.'
    end
  end

  private

  def set_family
    @family = Family.find(params[:family_id])
  end

  def set_invitation
    @invitation = @family.invitations.find(params[:id])
  end

  def ensure_family_member
    unless @family.can_be_accessed_by?(current_user)
      redirect_to root_path, alert: 'You do not have permission to access this family.'
    end
  end

  def invitation_params
    params.require(:family_invitation).permit(:email)
  end
end 