class RitualComponent < ApplicationRecord
  belongs_to :ritual

  COMPONENT_TYPES = %w[prepare begin perform end].freeze

  COMPONENT_TYPE_LABELS = {
    "prepare" => "Preparation",
    "begin" => "Opening",
    "perform" => "Main Activity",
    "end" => "Closing"
  }.freeze

  validates :title, presence: true, length: { maximum: 200 }
  validates :component_type, inclusion: { in: COMPONENT_TYPES }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(position: :asc) }
  scope :by_type, ->(type) { where(component_type: type) }

  def component_type_label
    COMPONENT_TYPE_LABELS[component_type] || component_type&.titleize || "Step"
  end

  def duration_display
    return nil unless duration_minutes.present? && duration_minutes.positive?

    if duration_minutes >= 60
      hours = duration_minutes / 60
      remaining = duration_minutes % 60
      remaining.positive? ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{duration_minutes} min"
    end
  end
end
