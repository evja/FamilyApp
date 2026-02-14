class Lead < ApplicationRecord
  # Honeypot field - should always be blank
  attr_accessor :hp

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :honeypot_must_be_blank

  # Scopes for signal strength filtering
  scope :hot_leads, -> { where("signal_strength >= ?", 3) }
  scope :warm_leads, -> { where(signal_strength: 1..2) }
  scope :cold_leads, -> { where("signal_strength < ?", 1) }
  scope :by_signal_strength, -> { order(signal_strength: :desc, created_at: :desc) }

  # Callbacks
  before_save :calculate_signal_strength

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def honeypot_must_be_blank
    errors.add(:base, "Something went wrong") if hp.present?
  end

  def calculate_signal_strength
    points = 1 # Base point for signup
    points += 2 if survey_completed?
    points += 1 if family_size.present?
    points += 1 if biggest_challenge.present?
    self.signal_strength = [points, 5].min
  end
end