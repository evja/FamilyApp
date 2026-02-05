class CompletionItem < ApplicationRecord
  belongs_to :rhythm_completion
  belongs_to :agenda_item

  validates :rhythm_completion_id, uniqueness: { scope: :agenda_item_id }

  scope :checked, -> { where(checked: true) }
  scope :unchecked, -> { where(checked: false) }

  def check!
    update!(checked: true, checked_at: Time.current)
  end

  def uncheck!
    update!(checked: false, checked_at: nil)
  end

  def toggle!
    checked? ? uncheck! : check!
  end
end
