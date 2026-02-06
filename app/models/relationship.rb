class Relationship < ApplicationRecord
  HEALTH_BANDS = %w[unassessed low functioning high].freeze

  belongs_to :family
  belongs_to :member_low, class_name: 'Member'
  belongs_to :member_high, class_name: 'Member'
  has_many :assessments, class_name: 'RelationshipAssessment', dependent: :destroy

  before_validation :normalize_member_order

  validates :member_low_id, uniqueness: { scope: [:family_id, :member_high_id] }

  scope :assessed, -> { where.not(current_health_score: nil) }
  scope :unassessed, -> { where(current_health_score: nil) }
  scope :healthy, -> { where(current_health_band: 'high') }
  scope :needs_attention, -> { where(current_health_band: %w[low functioning]) }
  scope :for_member, ->(m) { where('member_low_id = ? OR member_high_id = ?', m.id, m.id) }

  def display_name
    "#{member_low.name} & #{member_high.name}"
  end

  def assessed?
    current_health_score.present?
  end

  def health_color_hsl
    return 'hsl(0, 0%, 70%)' unless assessed?
    hue = (current_health_score / 100.0) * 120
    "hsl(#{hue.round}, 70%, 45%)"
  end

  def health_label
    case current_health_band
    when 'high' then 'High Functioning'
    when 'functioning' then 'Functioning'
    when 'low' then 'Low Functioning'
    else 'Not Assessed'
    end
  end

  def update_health_from_assessment!(assessment)
    new_pct = (assessment.total_score / 6.0) * 100

    if current_health_score.nil?
      updated_score = new_pct
    else
      updated_score = (0.5 * new_pct) + (0.5 * current_health_score)
    end

    band = case assessment.total_score
           when 5..6 then 'high'
           when 3..4 then 'functioning'
           else 'low'
           end

    update!(
      current_health_score: updated_score.round,
      current_health_band: band,
      last_assessed_at: Time.current
    )
  end

  def self.ensure_all_for_family(family)
    member_ids = family.members.pluck(:id).sort
    member_ids.each_with_index do |low_id, i|
      member_ids[(i + 1)..].each do |high_id|
        find_or_create_by!(family: family, member_low_id: low_id, member_high_id: high_id)
      end
    end
  end

  private

  def normalize_member_order
    return unless member_low_id && member_high_id
    if member_low_id > member_high_id
      self.member_low_id, self.member_high_id = member_high_id, member_low_id
    end
  end
end
