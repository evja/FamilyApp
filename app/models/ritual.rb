class Ritual < ApplicationRecord
  belongs_to :family
  has_many :components, class_name: 'RitualComponent', dependent: :destroy
  has_many :ritual_values, dependent: :destroy
  has_many :family_values, through: :ritual_values

  accepts_nested_attributes_for :components, allow_destroy: true, reject_if: :all_blank

  RITUAL_TYPES = %w[connection special_person community coming_of_age celebration].freeze
  FREQUENCIES = %w[daily weekly monthly yearly milestone].freeze

  RITUAL_TYPE_LABELS = {
    "connection" => "Connection Ritual",
    "special_person" => "Special Person Ritual",
    "community" => "Community Ritual",
    "coming_of_age" => "Coming of Age",
    "celebration" => "Celebration"
  }.freeze

  RITUAL_TYPE_DESCRIPTIONS = {
    "connection" => "Regular rituals that strengthen family bonds",
    "special_person" => "Rituals that honor individual family members",
    "community" => "Rituals involving extended family or community",
    "coming_of_age" => "Milestone rituals marking growth and maturity",
    "celebration" => "Holiday and celebration traditions"
  }.freeze

  FREQUENCY_LABELS = {
    "daily" => "Daily",
    "weekly" => "Weekly",
    "monthly" => "Monthly",
    "yearly" => "Yearly",
    "milestone" => "Milestone-based"
  }.freeze

  validates :name, presence: true, length: { maximum: 200 }
  validates :ritual_type, presence: true, inclusion: { in: RITUAL_TYPES }
  validates :frequency, inclusion: { in: FREQUENCIES }, allow_blank: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_type, ->(type) { where(ritual_type: type) }
  scope :ordered, -> { order(position: :asc) }

  def ritual_type_label
    RITUAL_TYPE_LABELS[ritual_type] || ritual_type&.titleize
  end

  def ritual_type_description
    RITUAL_TYPE_DESCRIPTIONS[ritual_type]
  end

  def frequency_label
    FREQUENCY_LABELS[frequency] || frequency&.titleize
  end

  def total_duration_minutes
    components.sum(:duration_minutes)
  end

  def duration_display
    total = total_duration_minutes
    return nil unless total.present? && total.positive?

    if total >= 60
      hours = total / 60
      remaining = total % 60
      remaining.positive? ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{total} min"
    end
  end

  def components_by_type
    components.ordered.group_by(&:component_type)
  end
end
