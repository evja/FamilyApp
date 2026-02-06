class AgendaItem < ApplicationRecord
  belongs_to :rhythm
  has_many :completion_items, dependent: :destroy

  LINK_TYPES = %w[none issues vision members thrive].freeze

  LINK_LABELS = {
    "none" => "No Link",
    "issues" => "Open Issues",
    "vision" => "Family Vision",
    "members" => "Family Members",
    "thrive" => "Thrive Check-in"
  }.freeze

  validates :title, presence: true, length: { maximum: 200 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :link_type, inclusion: { in: LINK_TYPES }
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true

  default_scope { order(position: :asc) }
  scope :ordered, -> { order(position: :asc) }

  def has_link?
    link_type.present? && link_type != "none"
  end

  def link_path(family)
    case link_type
    when "issues"
      Rails.application.routes.url_helpers.family_issues_path(family)
    when "vision"
      Rails.application.routes.url_helpers.family_vision_path(family)
    when "members"
      Rails.application.routes.url_helpers.family_members_path(family)
    else
      nil
    end
  end

  def link_label
    LINK_LABELS[link_type] || "View"
  end

  def link_available?
    link_type.present? && link_type != "none"
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
