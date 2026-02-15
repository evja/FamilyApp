class AddSignupCodeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :signup_code, :string
    add_index :users, :signup_code
  end
end
