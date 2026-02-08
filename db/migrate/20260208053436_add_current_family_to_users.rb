class AddCurrentFamilyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :current_family, foreign_key: { to_table: :families }
  end
end
