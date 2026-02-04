class AddMemberIdToFamilyInvitations < ActiveRecord::Migration[7.1]
  def change
    add_reference :family_invitations, :member, foreign_key: true
  end
end
