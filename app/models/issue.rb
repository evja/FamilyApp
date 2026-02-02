class Issue < ApplicationRecord
  belongs_to :family
  belongs_to :root_issue, class_name: "Issue", optional: true
  has_many :symptom_issues, class_name: "Issue", foreign_key: "root_issue_id"

  has_many :issue_members
  has_many :members, through: :issue_members
  has_many :issue_values
  has_many :family_values, through: :issue_values

  STATUSES = %w[new acknowledged working_on_it resolved].freeze

  STATUS_LABELS = {
    "new" => "New",
    "acknowledged" => "Acknowledged",
    "working_on_it" => "Working On It",
    "resolved" => "Resolved"
  }.freeze

  STATUS_COLORS = {
    "new" => "bg-blue-100 text-blue-800",
    "acknowledged" => "bg-yellow-100 text-yellow-800",
    "working_on_it" => "bg-purple-100 text-purple-800",
    "resolved" => "bg-green-100 text-green-800"
  }.freeze

  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where.not(status: "resolved") }
  scope :resolved, -> { where(status: "resolved") }
  scope :resolved_this_week, -> { where(status: "resolved").where("resolved_at >= ?", Time.current.beginning_of_week) }

  def next_status
    current_index = STATUSES.index(status)
    return nil if current_index.nil? || current_index >= STATUSES.length - 1
    STATUSES[current_index + 1]
  end

  def advance_status!
    new_status = next_status
    return false unless new_status

    attrs = { status: new_status }
    attrs[:resolved_at] = Time.current if new_status == "resolved"
    update!(attrs)
  end
end
