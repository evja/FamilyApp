class Rhythm < ApplicationRecord
  belongs_to :family
  has_many :agenda_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :completions, class_name: "RhythmCompletion", dependent: :destroy

  accepts_nested_attributes_for :agenda_items, allow_destroy: true, reject_if: :all_blank

  FREQUENCY_TYPES = %w[daily weekly biweekly monthly quarterly annually].freeze

  FREQUENCY_DAYS = {
    "daily" => 1,
    "weekly" => 7,
    "biweekly" => 14,
    "monthly" => 30,
    "quarterly" => 90,
    "annually" => 365
  }.freeze

  FREQUENCY_LABELS = {
    "daily" => "Daily",
    "weekly" => "Weekly",
    "biweekly" => "Every 2 Weeks",
    "monthly" => "Monthly",
    "quarterly" => "Quarterly",
    "annually" => "Annually"
  }.freeze

  CATEGORIES = %w[parent_sync family_huddle retreat check_in custom].freeze

  CATEGORY_LABELS = {
    "parent_sync" => "Parent Sync",
    "family_huddle" => "Family Huddle",
    "retreat" => "Retreat",
    "check_in" => "1-on-1 Check-in",
    "custom" => "Custom"
  }.freeze

  validates :name, presence: true, length: { maximum: 100 }
  validates :frequency_type, inclusion: { in: FREQUENCY_TYPES }
  validates :frequency_days, presence: true, numericality: { greater_than: 0 }
  validates :rhythm_category, inclusion: { in: CATEGORIES }

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :overdue, -> { active.where("next_due_at < ?", Time.current) }
  scope :due_soon, -> { active.where("next_due_at >= ? AND next_due_at <= ?", Time.current, 3.days.from_now) }
  scope :on_track, -> { active.where("next_due_at > ?", 3.days.from_now) }
  scope :by_category, ->(category) { where(rhythm_category: category) }

  def overdue?
    is_active && next_due_at.present? && next_due_at < Time.current
  end

  def due_soon?
    is_active && next_due_at.present? && next_due_at >= Time.current && next_due_at <= 3.days.from_now
  end

  def status
    return "inactive" unless is_active
    return "overdue" if overdue?
    return "due_soon" if due_soon?
    "on_track"
  end

  def status_label
    case status
    when "overdue" then "Overdue"
    when "due_soon" then "Due Soon"
    when "on_track" then "On Track"
    when "inactive" then "Inactive"
    end
  end

  def status_color
    case status
    when "overdue" then "bg-red-100 text-red-800"
    when "due_soon" then "bg-yellow-100 text-yellow-800"
    when "on_track" then "bg-green-100 text-green-800"
    when "inactive" then "bg-gray-100 text-gray-500"
    end
  end

  def frequency_label
    FREQUENCY_LABELS[frequency_type] || frequency_type.titleize
  end

  def category_label
    CATEGORY_LABELS[rhythm_category] || rhythm_category.titleize
  end

  def total_duration_minutes
    agenda_items.sum(:duration_minutes)
  end

  def duration_display
    minutes = total_duration_minutes
    return nil if minutes.nil? || minutes.zero?

    if minutes >= 60
      hours = minutes / 60
      remaining = minutes % 60
      remaining.positive? ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{minutes}m"
    end
  end

  def start_meeting!(user)
    completion = completions.create!(
      completed_by: user,
      started_at: Time.current,
      status: "in_progress"
    )

    agenda_items.each do |item|
      completion.completion_items.create!(agenda_item: item)
    end

    completion
  end

  def current_meeting
    completions.where(status: "in_progress").order(created_at: :desc).first
  end

  def complete!(completion = nil)
    completion ||= current_meeting
    return false unless completion

    completion.update!(
      status: "completed",
      completed_at: Time.current
    )

    update!(
      last_completed_at: Time.current,
      next_due_at: calculate_next_due_at
    )

    true
  end

  def skip!
    update!(next_due_at: calculate_next_due_at)
  end

  def calculate_next_due_at
    Time.current + frequency_days.days
  end

  def schedule_first_occurrence!
    update!(next_due_at: calculate_next_due_at) if next_due_at.nil?
  end
end
