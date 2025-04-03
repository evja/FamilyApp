class AddIsParentToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :is_parent, :boolean, default: false
  end
end
