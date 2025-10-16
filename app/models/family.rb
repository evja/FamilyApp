class Family < ApplicationRecord
  include Themeable
  
  has_many :users, dependent: :nullify
  has_many :members, dependent: :destroy
  has_many :family_values, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :invitations, class_name: 'FamilyInvitation', dependent: :destroy
  has_one :vision, class_name: "FamilyVision", dependent: :destroy

  validates :name, presence: true

  before_destroy :check_last_family

  def invite_user(email)
    invitations.create(email: email)
  end

  def can_be_accessed_by?(user)
    return false unless user
    users.include?(user) || invitations.valid.exists?(email: user.email)
  end

  private

  def check_last_family
    throw(:abort) if users.count > 1
  end
end