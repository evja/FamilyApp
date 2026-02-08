class AddSubscriptionStatusToFamilies < ActiveRecord::Migration[7.1]
  def change
    add_column :families, :subscription_status, :string, default: 'free'
    add_column :families, :stripe_subscription_id, :string
    add_index :families, :subscription_status
  end
end
