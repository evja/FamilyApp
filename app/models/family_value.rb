class FamilyValue < ApplicationRecord
  belongs_to :family
  has_many :issue_values
  has_many :issues, through: :issue_values
end