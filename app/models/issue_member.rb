class IssueMember < ApplicationRecord
  belongs_to :issue
  belongs_to :member
  has_many :issue_members
  has_many :issues, through: :issue_members
end