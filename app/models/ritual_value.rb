class RitualValue < ApplicationRecord
  belongs_to :ritual
  belongs_to :family_value

  validates :ritual_id, uniqueness: { scope: :family_value_id, message: "already has this value" }
end
