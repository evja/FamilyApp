class Member < ApplicationRecord
  ROLES = %w[owner parent teen child].freeze

  belongs_to :family
  belongs_to :user, optional: true
  has_many :issue_members, dependent: :destroy
  has_many :issues, through: :issue_members
  has_one :invitation, class_name: 'FamilyInvitation', dependent: :nullify

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, presence: true, if: :requires_email?
  validate :only_one_owner_per_family, on: :create

  before_save :sync_is_parent_with_role

  scope :parents, -> { where(is_parent: true) }
  scope :children, -> { where(is_parent: false) }
  scope :by_role, ->(role) { where(role: role) }
  scope :owners, -> { where(role: 'owner') }
  scope :invitable, -> { where(role: %w[owner parent teen]).where(user_id: nil) }
  scope :pending_invitation, -> { invitable.where.not(invited_at: nil).where(joined_at: nil) }
  scope :with_accounts, -> { where.not(user_id: nil) }

  def paid?
    subscription_status == "active"
  end

  def can_have_account?
    role.in?(%w[owner parent teen])
  end

  def invited?
    invited_at.present?
  end

  def joined?
    joined_at.present? || user_id.present?
  end

  def display_status
    return 'owner' if role == 'owner' && joined?
    return 'joined' if joined?
    return 'pending' if invited? && !joined?
    return 'not_invited' if can_have_account? && !invited?
    'child'
  end

  def owner?
    role == 'owner'
  end

  def parent_or_above?
    role.in?(%w[owner parent])
  end

  def display_role
    case role
    when 'owner' then 'Owner'
    when 'parent' then 'Parent'
    when 'teen' then 'Teen'
    when 'child' then 'Child'
    else role.titleize
    end
  end

  private

  def requires_email?
    role.in?(%w[owner parent teen]) && invited_at.present?
  end

  def sync_is_parent_with_role
    self.is_parent = role.in?(%w[owner parent])
  end

  def only_one_owner_per_family
    if role == 'owner' && family&.members&.owners&.where&.not(id: id)&.exists?
      errors.add(:role, "there can only be one owner per family")
    end
  end
end
