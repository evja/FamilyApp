class Member < ApplicationRecord
  belongs_to :family
  has_many :issue_members, dependent: :destroy
  has_many :issues, through: :issue_members
  
  def paid?
    subscription_status == "active"
  end

  scope :parents, -> { where(is_parent: true) }
  scope :children, -> { where(is_parent: false) }
end
