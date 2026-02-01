class IssueMember < ApplicationRecord
  belongs_to :issue
  belongs_to :member
end