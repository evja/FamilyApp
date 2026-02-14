class AddFieldsToLeads < ActiveRecord::Migration[7.1]
  def change
    add_column :leads, :first_name, :string
    add_column :leads, :last_name, :string
    add_column :leads, :source, :string
    add_column :leads, :campaign, :string
    add_column :leads, :referral_source, :string
    add_column :leads, :signal_strength, :integer, default: 1
    add_column :leads, :family_size, :integer
    add_column :leads, :biggest_challenge, :string
    add_column :leads, :survey_completed, :boolean, default: false

    add_index :leads, :email, unique: true
    add_index :leads, :signal_strength
  end
end
