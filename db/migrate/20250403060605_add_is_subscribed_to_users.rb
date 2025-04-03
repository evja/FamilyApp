class AddIsSubscribedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_subscribed, :boolean
  end
end
