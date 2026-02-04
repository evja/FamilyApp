class MigrateExistingMembersToRoles < ActiveRecord::Migration[7.1]
  def up
    # Convert is_parent=true to role='parent', is_parent=false to role='child'
    execute <<-SQL
      UPDATE members SET role = 'parent' WHERE is_parent = true;
      UPDATE members SET role = 'child' WHERE is_parent = false OR is_parent IS NULL;
    SQL

    # Create owner member for first user in each family that doesn't have one
    # and link existing users to members by email
    Family.find_each do |family|
      first_user = family.users.order(:created_at).first
      next unless first_user

      # Check if there's already an owner member
      owner_member = family.members.find_by(role: 'owner')

      if owner_member.nil?
        # Try to find a member that matches the user's email or name
        existing_member = family.members.find_by(email: first_user.email) ||
                         family.members.find_by("LOWER(name) = ?", first_user.email.split('@').first.downcase)

        if existing_member
          # Upgrade existing member to owner and link to user
          existing_member.update_columns(
            role: 'owner',
            user_id: first_user.id,
            email: first_user.email,
            joined_at: first_user.created_at
          )
        else
          # Create a new owner member for this user
          family.members.create!(
            name: first_user.email.split('@').first.titleize,
            role: 'owner',
            user_id: first_user.id,
            email: first_user.email,
            joined_at: first_user.created_at,
            is_parent: true
          )
        end
      end

      # Link other users to members by email
      family.users.where.not(id: first_user.id).find_each do |user|
        member = family.members.find_by(email: user.email)
        if member && member.user_id.nil?
          member.update_columns(
            user_id: user.id,
            joined_at: user.created_at
          )
        end
      end
    end
  end

  def down
    # Revert roles back to is_parent
    execute <<-SQL
      UPDATE members SET is_parent = true WHERE role IN ('owner', 'parent');
      UPDATE members SET is_parent = false WHERE role IN ('teen', 'child');
    SQL

    # Clear role-related fields
    execute <<-SQL
      UPDATE members SET role = 'child', email = NULL, invited_at = NULL, joined_at = NULL;
    SQL
  end
end
