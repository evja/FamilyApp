class AddBirthdateToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :birthdate, :date
  end
end
