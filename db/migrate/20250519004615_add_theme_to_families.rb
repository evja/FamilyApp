class AddThemeToFamilies < ActiveRecord::Migration[7.0]
  def up
    add_column :families, :theme, :string

    # Migrate existing data
    Family.find_each do |family|
      if family.primary_color.present?
        # Find the closest matching theme based on primary color
        matching_theme = Family::THEME_PRESETS.find do |key, preset|
          preset[:primary].downcase == family.primary_color.downcase
        end
        
        family.update_column(:theme, (matching_theme&.first || :forest).to_s)
      else
        family.update_column(:theme, 'forest')
      end
    end

    # Remove old columns
    remove_column :families, :primary_color
    remove_column :families, :secondary_color
  end

  def down
    add_column :families, :primary_color, :string
    add_column :families, :secondary_color, :string

    # Restore color values from themes
    Family.find_each do |family|
      theme_preset = Family::THEME_PRESETS[family.theme&.to_sym || :forest]
      family.update_columns(
        primary_color: theme_preset[:primary],
        secondary_color: theme_preset[:secondary]
      )
    end

    remove_column :families, :theme
  end
end
