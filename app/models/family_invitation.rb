class FamilyInvitation < ApplicationRecord
  belongs_to :family

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending accepted expired] }
  validates :expires_at, presence: true

  before_validation :set_default_values, on: :create
  
  scope :pending, -> { where(status: 'pending') }
  scope :valid, -> { where('expires_at > ? AND status = ?', Time.current, 'pending') }

  def expired?
    expires_at < Time.current || status != 'pending'
  end

  def accept!
    return false if expired?
    
    update(status: 'accepted')
  end

  def expire!
    update(status: 'expired')
  end

  private

  def set_default_values
    self.token = generate_secure_token
    self.status ||= 'pending'
    self.expires_at ||= 7.days.from_now
  end

  def generate_secure_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless FamilyInvitation.exists?(token: token)
    end
  end
end
