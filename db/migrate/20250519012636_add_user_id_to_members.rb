class AddUserIdToMembers < ActiveRecord::Migration[7.1]
  def change
    add_reference :members, :user, foreign_key: true
  end
end
