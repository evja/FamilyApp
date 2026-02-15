class MaturityBehavior < ApplicationRecord
  belongs_to :maturity_level

  CATEGORIES = %w[body things clothing responsibilities emotions].freeze

  CATEGORY_LABELS = {
    "body" => "Body Care",
    "things" => "Taking Care of Things",
    "clothing" => "Clothing & Appearance",
    "responsibilities" => "Responsibilities",
    "emotions" => "Emotional Maturity"
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
