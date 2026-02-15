class AddOnboardingToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :onboarding_state, :string, default: 'pending'
    add_column :users, :onboarding_completed_at, :datetime
    add_index :users, :onboarding_state
  end
end
