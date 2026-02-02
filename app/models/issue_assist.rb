class IssueAssist < ApplicationRecord
  belongs_to :family
  belongs_to :user

  DAILY_LIMIT = 20

  def self.remaining_today(family)
    used = where(family: family).where("created_at >= ?", Time.current.beginning_of_day).count
    [DAILY_LIMIT - used, 0].max
  end
end
