class MaturityLevel < ApplicationRecord
  belongs_to :family
  has_many :behaviors, class_name: 'MaturityBehavior', dependent: :destroy
  has_many :privileges, class_name: 'MaturityPrivilege', dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :ordered, -> { order(position: :asc) }

  # Extract just the color name from names like "Yellow (3-6)"
  def color_name
    name.split('(').first.strip
  end

  # Generate a display label for the age range
  def age_range_label
    return nil unless age_min.present? || age_max.present?

    if age_min.present? && age_max.present?
      "Ages #{age_min}-#{age_max}"
    elsif age_min.present?
      "Ages #{age_min}+"
    else
      "Up to age #{age_max}"
    end
  end

  # Behaviors grouped by category
  def behaviors_by_category
    behaviors.ordered.group_by(&:category)
  end

  # Privileges grouped by category
  def privileges_by_category
    privileges.ordered.group_by(&:category)
  end
end
