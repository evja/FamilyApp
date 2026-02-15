class MaturityPrivilege < ApplicationRecord
  belongs_to :maturity_level

  CATEGORIES = %w[money bedtime screen_time food social independence].freeze

  CATEGORY_LABELS = {
    "money" => "Allowance / Money",
    "bedtime" => "Bedtime",
    "screen_time" => "Screen Time",
    "food" => "Food & Snacks",
    "social" => "Social / Friends",
    "independence" => "Independence"
  }.freeze

  validates :description, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :ordered, -> { order(position: :asc) }
  scope :by_category, ->(category) { where(category: category) }

  def category_label
    CATEGORY_LABELS[category] || category&.titleize || "General"
  end
end
