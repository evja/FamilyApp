class IssueValue < ApplicationRecord
  belongs_to :issue
  belongs_to :family_value
end
