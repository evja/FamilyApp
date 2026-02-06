class AddProfileFieldsToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :theme_color, :string
    add_column :members, :nickname, :string
    add_column :members, :bio, :text
    add_column :members, :avatar_emoji, :string
    add_column :members, :strengths, :text
    add_column :members, :growth_areas, :text
  end
end
