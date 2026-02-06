class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_member, only: [:show, :edit, :update, :destroy, :invite, :resend_invite]

  def index
    # Sort by role, then by age (youngest first), then by name
    @members = @family.members.includes(:user, :invitation).order(
      Arel.sql("CASE role WHEN 'admin_parent' THEN 0 WHEN 'parent' THEN 1 WHEN 'teen' THEN 2 WHEN 'child' THEN 3 END"),
      Arel.sql("COALESCE(birthdate, DATE('1900-01-01')) DESC"),  # Youngest first (most recent birthdate)
      Arel.sql("COALESCE(age, 999) ASC"),  # Fallback: youngest age first
      :name
    )
    @parents = @members.select { |m| m.role.in?(%w[admin_parent parent]) }
    @teens = @members.select { |m| m.role == 'teen' }
    @children = @members.select { |m| m.role == 'child' }
    @pending_invitations = @family.invitations.pending.where(member_id: nil)
  end

  def show
    @member_issues = @member.issues.active.order(created_at: :desc).limit(5)
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
    if @member.admin_parent?
      redirect_to family_members_path(@family), alert: "Cannot delete the family admin."
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
    params.require(:member).permit(
      :name, :age, :birthdate, :role, :email,
      :theme_color, :nickname, :bio, :avatar_emoji,
      :interests, :strengths, :growth_areas,
      # Legacy fields (hidden in MVP but preserved)
      :personality, :health, :development, :needs, :is_parent
    )
  end
end
