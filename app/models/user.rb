class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family, optional: true


  scope :subscribed, -> { where(is_subscribed: true) }
  scope :unsubscribed, -> { where(is_subscribed: false) }
  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }

  before_destroy :destroy_family_if_last_user
  private

  def destroy_family_if_last_user
    return unless family && family.users.count == 1

    last_family = family                     # ✅ capture before nullifying
    update_column(:family_id, nil)          # ✅ break foreign key constraint
    last_family.destroy                      # ✅ now safe to destroy
  end
end
