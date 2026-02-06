class Member < ApplicationRecord
  ROLES = %w[admin_parent parent teen child].freeze
  TEEN_AGE_THRESHOLD = 13

  # Personal theme color presets (12 distinct colors)
  THEME_COLORS = {
    indigo: '#4F46E5',
    emerald: '#10B981',
    rose: '#F43F5E',
    amber: '#F59E0B',
    sky: '#0EA5E9',
    violet: '#8B5CF6',
    teal: '#14B8A6',
    orange: '#F97316',
    cyan: '#06B6D4',
    fuchsia: '#D946EF',
    lime: '#84CC16',
    slate: '#64748B'
  }.freeze

  belongs_to :family
  belongs_to :user, optional: true
  has_many :issue_members, dependent: :destroy
  has_many :issues, through: :issue_members
  has_one :invitation, class_name: 'FamilyInvitation', dependent: :nullify
  has_many :thrive_assessments, dependent: :destroy
  has_many :relationships_as_low, class_name: 'Relationship',
           foreign_key: 'member_low_id', dependent: :destroy
  has_many :relationships_as_high, class_name: 'Relationship',
           foreign_key: 'member_high_id', dependent: :destroy

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, presence: true, if: :requires_email?
  validates :theme_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }, allow_blank: true
  validates :avatar_emoji, length: { maximum: 4 }, allow_blank: true
  validate :only_one_admin_parent_per_family, on: :create

  before_validation :calculate_age_from_birthdate, if: :birthdate_changed?
  before_validation :assign_role_from_age, if: :should_auto_assign_role?
  before_save :sync_is_parent_with_role
  after_create :ensure_family_relationships

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

  # Calculate age from birthdate
  def calculated_age
    return nil unless birthdate.present?
    today = Date.current
    age = today.year - birthdate.year
    age -= 1 if today < birthdate + age.years # Adjust if birthday hasn't occurred yet
    age
  end

  # Determine role based on age
  def role_for_age(age)
    return role if age.nil? # Keep existing role instead of nil
    return 'child' if age < TEEN_AGE_THRESHOLD
    'teen'
  end

  def relationships
    Relationship.for_member(self)
  end

  def bubble_radius
    return 40 if parent_or_above? || (age.present? && age >= 18)
    return 25 if age.nil?
    16 + (age / 18.0 * 22).round
  end

  # Personal theme color (defaults to indigo for parents, emerald for children)
  def display_color
    theme_color.presence || (parent_or_above? ? '#4F46E5' : '#10B981')
  end

  # Display name (nickname if set, otherwise name)
  def display_name
    nickname.presence || name
  end

  # Avatar display (emoji if set, otherwise first initial)
  def avatar_display
    avatar_emoji.presence || name[0].upcase
  end

  # Stats for member dashboard
  def active_issue_count
    issues.active.count
  end

  def relationship_count
    relationships.count
  end

  def healthy_relationship_count
    relationships.select { |r| r.current_health_band == 'high' }.count
  end

  private

  def calculate_age_from_birthdate
    self.age = calculated_age if birthdate.present?
  end

  def should_auto_assign_role?
    birthdate.present? && !role.in?(%w[admin_parent parent])
  end

  def assign_role_from_age
    self.role = role_for_age(calculated_age)
  end

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

  def ensure_family_relationships
    family.ensure_all_relationships! if family.present?
  end
end
