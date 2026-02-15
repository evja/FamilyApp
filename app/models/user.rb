class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Onboarding state machine
  ONBOARDING_STATES = %w[pending welcome add_members first_issue dashboard_intro complete].freeze

  # Valid signup codes for special access
  # beta26: Beta testers - full module access
  # Add more codes as needed: admin2026, etc.
  VALID_SIGNUP_CODES = {
    'beta26' => :beta_tester,
    'betatester' => :beta_tester,
    'familyhub2026' => :beta_tester
  }.freeze

  validates :onboarding_state, inclusion: { in: ONBOARDING_STATES }

  scope :onboarding_incomplete, -> { where.not(onboarding_state: 'complete') }
  scope :onboarding_complete, -> { where(onboarding_state: 'complete') }

  # Legacy single-family association (kept for backward compatibility)
  belongs_to :family, optional: true

  # Multi-family support
  belongs_to :current_family, class_name: 'Family', optional: true
  has_many :members, dependent: :nullify
  has_many :families, through: :members

  scope :subscribed, -> { where(is_subscribed: true) }
  scope :unsubscribed, -> { where(is_subscribed: false) }
  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }

  after_destroy :destroy_family_if_last_user

  # Returns the user's active family (current_family, or first family, or legacy family)
  def active_family
    current_family || families.first || family
  end

  # Switch to a different family
  def switch_family!(new_family)
    raise ArgumentError, "Not a member of that family" unless member_of?(new_family)
    update!(current_family: new_family)
  end

  # Check if user is a member of a family
  def member_of?(family)
    return false unless family
    families.include?(family)
  end

  # Get the user's member record in a specific family
  def member_in(family)
    return nil unless family
    members.find_by(family: family)
  end

  # Get the user's member record in their active family
  def member
    member_in(active_family)
  end

  def family_admin?
    member&.admin_parent?
  end

  def family_parent?
    member&.parent_or_above?
  end

  def family_role
    member&.role
  end

  # Onboarding state helpers
  def onboarding_complete?
    onboarding_state == 'complete'
  end

  def onboarding_pending?
    onboarding_state == 'pending'
  end

  def in_onboarding?
    !onboarding_complete?
  end

  def advance_onboarding_to!(state)
    return if onboarding_complete?
    return unless ONBOARDING_STATES.include?(state)

    update!(onboarding_state: state)
    update!(onboarding_completed_at: Time.current) if state == 'complete'
  end

  def complete_onboarding!
    advance_onboarding_to!('complete')
  end

  # Signup code access methods
  def signup_code_type
    return nil if signup_code.blank?
    VALID_SIGNUP_CODES[signup_code.downcase.strip]
  end

  def beta_tester?
    signup_code_type == :beta_tester
  end

  def has_full_access?
    admin? || beta_tester? || is_subscribed?
  end

  private

  def destroy_family_if_last_user
    return unless family

    family.with_lock do
      if family.users.where.not(id: id).empty?
        family.destroy
      end
    end
  end
end
