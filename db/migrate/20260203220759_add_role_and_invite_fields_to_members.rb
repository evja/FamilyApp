class AddRoleAndInviteFieldsToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :role, :string, default: 'child', null: false
    add_column :members, :email, :string
    add_column :members, :invited_at, :datetime
    add_column :members, :joined_at, :datetime
    add_index :members, :email
    add_index :members, [:family_id, :role]
  end
end
