module ThemeHelper
  def current_theme
    if user_signed_in? && current_user.family
      current_user.family.theme
    else
      'default'
    end
  end

  def theme_data_attribute
    "data-theme=\"#{current_theme}\""
  end
end 