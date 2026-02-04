class Member < ApplicationRecord
  ROLES = %w[admin_parent parent teen child].freeze

  belongs_to :family
  belongs_to :user, optional: true
  has_many :issue_members, dependent: :destroy
  has_many :issues, through: :issue_members
  has_one :invitation, class_name: 'FamilyInvitation', dependent: :nullify

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, presence: true, if: :requires_email?
  validate :only_one_admin_parent_per_family, on: :create

  before_save :sync_is_parent_with_role

  scope :parents, -> { where(is_parent: true) }
  scope :children, -> { where(is_parent: false) }
  scope :by_role, ->(role) { where(role: role) }
  scope :admin_parents, -> { where(role: 'admin_parent') }
  scope :invitable, -> { where(role: %w[admin_parent parent teen]).where(user_id: nil) }
  scope :pending_invitation, -> { invitable.where.not(invited_at: nil).where(joined_at: nil) }
  scope :with_accounts, -> { where.not(user_id: nil) }

  def paid?
    subscription_status == "active"
  end

  def can_have_account?
    role.in?(%w[admin_parent parent teen])
  end

  def invited?
    invited_at.present?
  end

  def joined?
    joined_at.present? || user_id.present?
  end

  def display_status
    return 'admin_parent' if role == 'admin_parent' && joined?
    return 'joined' if joined?
    return 'pending' if invited? && !joined?
    return 'not_invited' if can_have_account? && !invited?
    'child'
  end

  def admin_parent?
    role == 'admin_parent'
  end

  def parent_or_above?
    role.in?(%w[admin_parent parent])
  end

  def display_role
    case role
    when 'admin_parent' then 'Admin Parent'
    when 'parent' then 'Parent'
    when 'teen' then 'Teen'
    when 'child' then 'Child'
    else role.titleize
    end
  end

  private

  def requires_email?
    role.in?(%w[admin_parent parent teen]) && invited_at.present?
  end

  def sync_is_parent_with_role
    self.is_parent = role.in?(%w[admin_parent parent])
  end

  def only_one_admin_parent_per_family
    if role == 'admin_parent' && family&.members&.admin_parents&.where&.not(id: id)&.exists?
      errors.add(:role, "there can only be one admin parent per family")
    end
  end
end
