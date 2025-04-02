class Issue < ApplicationRecord
  belongs_to :family
  belongs_to :root_issue, class_name: "Issue", optional: true
  has_many :symptom_issues, class_name: "Issue", foreign_key: "root_issue_id"

  has_many :issue_members
  has_many :members, through: :issue_members
  has_many :issue_values
  has_many :family_values, through: :issue_values
end