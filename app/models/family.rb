class Family < ApplicationRecord
  include Themeable

  has_many :users, dependent: :nullify
  has_many :members, dependent: :destroy
  has_many :family_values, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :rhythms, dependent: :destroy
  has_many :invitations, class_name: 'FamilyInvitation', dependent: :destroy
  has_one :vision, class_name: "FamilyVision", dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  before_destroy :check_last_family

  def invite_user(email)
    invitations.create(email: email)
  end

  def invite_member(member)
    return { success: false, error: "Member cannot have an account" } unless member.can_have_account?
    return { success: false, error: "Email is required to send an invitation" } if member.email.blank?
    return { success: false, error: "Member has already joined" } if member.joined?

    # Expire any existing pending invitations for this member
    member.invitation&.expire! if member.invitation&.status == 'pending'

    invitation = invitations.create(email: member.email, member: member)

    if invitation.persisted?
      member.update(invited_at: Time.current)
      { success: true, invitation: invitation }
    else
      { success: false, error: invitation.errors.full_messages.join(', ') }
    end
  end

  def ensure_admin_parent_member(user)
    return if members.admin_parents.exists?

    # Check if there's an existing member that matches the user
    existing_member = members.find_by(email: user.email) ||
                     members.find_by(user_id: user.id)

    if existing_member
      existing_member.update!(
        role: 'admin_parent',
        user_id: user.id,
        email: user.email,
        joined_at: Time.current
      )
    else
      members.create!(
        name: user.email.split('@').first.titleize,
        role: 'admin_parent',
        user_id: user.id,
        email: user.email,
        joined_at: Time.current,
        is_parent: true
      )
    end
  end

  def can_be_accessed_by?(user)
    return false unless user
    users.include?(user) || invitations.valid.exists?(email: user.email)
  end

  def admin_parent_member
    members.admin_parents.first
  end

  private

  def check_last_family
    throw(:abort) if users.count > 1
  end
end
