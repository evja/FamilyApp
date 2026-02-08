class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Legacy single-family association (kept for backward compatibility)
  belongs_to :family, optional: true

  # Multi-family support
  belongs_to :current_family, class_name: 'Family', optional: true
  has_many :members, dependent: :nullify
  has_many :families, through: :members

  scope :subscribed, -> { where(is_subscribed: true) }
  scope :unsubscribed, -> { where(is_subscribed: false) }
  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }

  after_destroy :destroy_family_if_last_user

  # Returns the user's active family (current_family, or first family, or legacy family)
  def active_family
    current_family || families.first || family
  end

  # Switch to a different family
  def switch_family!(new_family)
    raise ArgumentError, "Not a member of that family" unless member_of?(new_family)
    update!(current_family: new_family)
  end

  # Check if user is a member of a family
  def member_of?(family)
    return false unless family
    families.include?(family)
  end

  # Get the user's member record in a specific family
  def member_in(family)
    return nil unless family
    members.find_by(family: family)
  end

  # Get the user's member record in their active family
  def member
    member_in(active_family)
  end

  def family_admin?
    member&.admin_parent?
  end

  def family_parent?
    member&.parent_or_above?
  end

  def family_role
    member&.role
  end

  private

  def destroy_family_if_last_user
    return unless family

    family.with_lock do
      if family.users.where.not(id: id).empty?
        family.destroy
      end
    end
  end
end
