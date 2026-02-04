class RenameOwnerToAdminParent < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE members SET role = 'admin_parent' WHERE role = 'owner'"
  end

  def down
    execute "UPDATE members SET role = 'owner' WHERE role = 'admin_parent'"
  end
end
