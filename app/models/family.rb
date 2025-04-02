class Family < ApplicationRecord
  has_many :users
  has_many :members, dependent: :destroy
  has_many :family_values, dependent: :destroy
  has_many :issues, dependent: :destroy
end