class CreateFamilyInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :family_invitations do |t|
      t.references :family, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.string :status
      t.datetime :expires_at

      t.timestamps
    end
  end
end
