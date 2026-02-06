class RelationshipAssessment < ApplicationRecord
  SCORE_RANGE = (0..2).freeze
  SCORE_LABELS = { 0 => 'Rarely', 1 => 'Sometimes', 2 => 'Often' }.freeze

  belongs_to :relationship
  belongs_to :assessor, class_name: 'User', optional: true
  belongs_to :rhythm_completion, optional: true

  validates :assessed_on, presence: true
  validates :score_cooperation, presence: true, inclusion: { in: SCORE_RANGE }
  validates :score_affection, presence: true, inclusion: { in: SCORE_RANGE }
  validates :score_trust, presence: true, inclusion: { in: SCORE_RANGE }

  before_validation :set_assessed_on, on: :create
  before_save :compute_derived_fields
  after_commit :update_relationship_health, on: [:create, :update]

  scope :recent, -> { order(assessed_on: :desc) }
  scope :for_quarter, ->(key) { where(quarter_key: key) }

  def band_label
    case total_score
    when 5..6 then 'High Functioning'
    when 3..4 then 'Functioning'
    else 'Low Functioning'
    end
  end

  private

  def set_assessed_on
    self.assessed_on ||= Date.current
  end

  def compute_derived_fields
    self.total_score = score_cooperation + score_affection + score_trust
    self.quarter_key = "#{assessed_on.year}-Q#{((assessed_on.month - 1) / 3) + 1}"
  end

  def update_relationship_health
    relationship.update_health_from_assessment!(self)
  end
end
