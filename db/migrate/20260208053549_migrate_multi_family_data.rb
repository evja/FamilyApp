class MigrateMultiFamilyData < ActiveRecord::Migration[7.1]
  def up
    # Set current_family_id = family_id for existing users
    execute <<-SQL
      UPDATE users
      SET current_family_id = family_id
      WHERE family_id IS NOT NULL
    SQL

    # Copy subscription status from subscribed users to their families
    execute <<-SQL
      UPDATE families
      SET subscription_status = 'active'
      WHERE id IN (
        SELECT DISTINCT family_id
        FROM users
        WHERE is_subscribed = true AND family_id IS NOT NULL
      )
    SQL
  end

  def down
    # Clear current_family_id
    execute <<-SQL
      UPDATE users
      SET current_family_id = NULL
    SQL

    # Reset subscription status to free
    execute <<-SQL
      UPDATE families
      SET subscription_status = 'free'
    SQL
  end
end
