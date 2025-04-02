class Member < ApplicationRecord
  belongs_to :family
  has_many :issue_members, dependent: :destroy
  has_many :issues, through: :issue_members
end
