class AddThemeColorsToFamilies < ActiveRecord::Migration[7.1]
  def change
    add_column :families, :primary_color, :string
    add_column :families, :secondary_color, :string
  end
end
