class RhythmCompletion < ApplicationRecord
  belongs_to :rhythm
  belongs_to :completed_by, class_name: "User", optional: true
  has_many :completion_items, dependent: :destroy

  STATUSES = %w[in_progress completed abandoned].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :completed, -> { where(status: "completed") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :abandoned, -> { where(status: "abandoned") }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  def progress_percentage
    total = completion_items.count
    return 0 if total.zero?

    checked = completion_items.where(checked: true).count
    ((checked.to_f / total) * 100).round
  end

  def checked_count
    completion_items.where(checked: true).count
  end

  def total_count
    completion_items.count
  end

  def all_items_checked?
    total_count.positive? && checked_count == total_count
  end

  def duration_minutes
    return nil unless started_at.present? && completed_at.present?

    ((completed_at - started_at) / 60).round
  end

  def duration_display
    minutes = duration_minutes
    return nil unless minutes

    if minutes >= 60
      hours = minutes / 60
      remaining = minutes % 60
      remaining.positive? ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{minutes} min"
    end
  end

  def abandon!
    update!(status: "abandoned")
  end
end
