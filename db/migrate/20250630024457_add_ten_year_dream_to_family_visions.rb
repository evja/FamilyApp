class AddTenYearDreamToFamilyVisions < ActiveRecord::Migration[7.1]
  def change
    add_column :family_visions, :ten_year_dream, :text
  end
end
