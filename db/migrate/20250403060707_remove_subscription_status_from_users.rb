class RemoveSubscriptionStatusFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :subscription_status, :string
  end
end
