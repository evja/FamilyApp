class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_member, only: [:show, :edit, :update, :destroy, :invite, :resend_invite]

  def index
    @members = @family.members.order(Arel.sql("CASE role WHEN 'owner' THEN 0 WHEN 'parent' THEN 1 WHEN 'teen' THEN 2 WHEN 'child' THEN 3 END"), :name)
    @owner = @members.find(&:owner?)
    @parents = @members.select { |m| m.role == 'parent' }
    @teens = @members.select { |m| m.role == 'teen' }
    @children = @members.select { |m| m.role == 'child' }
    @pending_invitations = @family.invitations.pending.where(member_id: nil)
  end

  def show
  end

  def new
    @member = @family.members.new
  end

  def create
    @member = @family.members.new(member_params)
    if @member.save
      redirect_to family_members_path(@family), notice: "Member added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @member.update(member_params)
      redirect_to family_member_path(@family, @member), notice: "Member updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @member.owner?
      redirect_to family_members_path(@family), alert: "Cannot delete the family owner."
      return
    end

    @member.destroy
    redirect_to family_members_path(@family), notice: "Member deleted."
  end

  def invite
    unless @member.can_have_account?
      redirect_to family_members_path(@family), alert: "This member cannot receive an invitation."
      return
    end

    if @member.email.blank?
      redirect_to edit_family_member_path(@family, @member), alert: "Please add an email address before inviting."
      return
    end

    result = @family.invite_member(@member)

    if result[:success]
      invitation = result[:invitation]
      invite_url = accept_family_invitation_url(invitation.token)

      if ENV["EMAIL_INVITES_ENABLED"] == "true"
        FamilyMailer.invitation_email(invitation).deliver_later
        redirect_to family_members_path(@family), notice: "Invitation sent to #{@member.email}."
      else
        redirect_to family_members_path(@family),
          notice: "Email is disabled. Share this invite link with #{@member.name}: #{invite_url}"
      end
    else
      redirect_to family_members_path(@family), alert: result[:error]
    end
  end

  def resend_invite
    unless @member.invited? && !@member.joined?
      redirect_to family_members_path(@family), alert: "Cannot resend invitation for this member."
      return
    end

    result = @family.invite_member(@member)

    if result[:success]
      invitation = result[:invitation]
      invite_url = accept_family_invitation_url(invitation.token)

      if ENV["EMAIL_INVITES_ENABLED"] == "true"
        FamilyMailer.invitation_email(invitation).deliver_later
        redirect_to family_members_path(@family), notice: "Invitation resent to #{@member.email}."
      else
        redirect_to family_members_path(@family),
          notice: "Email is disabled. Share this invite link with #{@member.name}: #{invite_url}"
      end
    else
      redirect_to family_members_path(@family), alert: result[:error]
    end
  end

  private

  def set_member
    @member = @family.members.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:name, :age, :personality, :interests, :health, :development, :needs, :is_parent, :role, :email)
  end
end
