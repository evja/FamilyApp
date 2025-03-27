class Family < ApplicationRecord
  has_many :users
  has_many :members, dependent: :destroy
end