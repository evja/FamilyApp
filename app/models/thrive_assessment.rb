class ThriveAssessment < ApplicationRecord
  RATING_RANGE = 1..5
  ASSESSABLE_ROLES = %w[child teen].freeze

  belongs_to :member
  belongs_to :completed_by, class_name: "User", optional: true
  belongs_to :rhythm_completion, optional: true

  validates :assessed_at, presence: true
  validates :mind_rating, inclusion: { in: RATING_RANGE }, allow_nil: true
  validates :body_rating, inclusion: { in: RATING_RANGE }, allow_nil: true
  validates :spirit_rating, inclusion: { in: RATING_RANGE }, allow_nil: true
  validates :responsibility_rating, inclusion: { in: RATING_RANGE }, allow_nil: true
  validate :member_must_be_child_or_teen

  before_validation :set_assessed_at, on: :create

  scope :recent, -> { order(assessed_at: :desc) }
  scope :for_member, ->(member) { where(member: member) }
  # TODO: Currently unused - kept for future assessment history filtering
  scope :in_date_range, ->(start_date, end_date) { where(assessed_at: start_date..end_date) }

  # Immutable - assessments cannot be updated or destroyed after creation
  def readonly?
    persisted?
  end

  def average_rating
    ratings = [mind_rating, body_rating, spirit_rating, responsibility_rating].compact
    return nil if ratings.empty?
    (ratings.sum.to_f / ratings.size).round(1)
  end

  def completed_during_rhythm?
    rhythm_completion_id.present?
  end

  private

  def set_assessed_at
    self.assessed_at ||= Time.current
  end

  def member_must_be_child_or_teen
    return unless member.present?
    unless member.role.in?(ASSESSABLE_ROLES)
      errors.add(:member, "must be a child or teen")
    end
  end
end
