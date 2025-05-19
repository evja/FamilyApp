module Themeable
  extend ActiveSupport::Concern

  THEME_PRESETS = {
    forest: {
      name: "Forest",
      primary: "#2e452d",   # Dark forest green
      secondary: "#6f885d", # Light sage
      text: "#1a1a1a",      # Almost black
      background: "#f7f9f7" # Very light sage
    },
    ocean: {
      name: "Ocean",
      primary: "#1d3557",   # Deep blue
      secondary: "#457b9d", # Medium blue
      text: "#1a1a1a",      # Almost black
      background: "#f1f8fc" # Very light blue
    },
    sunset: {
      name: "Sunset",
      primary: "#6a4c93",   # Deep purple
      secondary: "#8b5fbf", # Light purple
      text: "#1a1a1a",      # Almost black
      background: "#f8f5fc" # Very light purple
    },
    earth: {
      name: "Earth",
      primary: "#6f4e37",   # Deep brown
      secondary: "#9b6f4d", # Light brown
      text: "#1a1a1a",      # Almost black
      background: "#faf7f5" # Very light brown
    },
    olive: {
      name: "Olive",
      primary: "#606c38",   # Dark olive
      secondary: "#8a9a5b", # Light olive
      text: "#1a1a1a",      # Almost black
      background: "#f7f8f5" # Very light olive
    },
    slate: {
      name: "Slate",
      primary: "#2c3e50",   # Dark slate blue
      secondary: "#95a5a6", # Cool gray
      text: "#ffffff",      # White text
      background: "#ecf0f1" # Very light gray
    },
    rosegold: {
      name: "Rosegold",
      primary: "#b76e79",   # Muted rose
      secondary: "#e5b4a1", # Soft peach
      text: "#1a1a1a",      # Almost black
      background: "#fdf5f6" # Blush background
    }
  }.freeze

  included do
    validates :theme, presence: true, inclusion: { in: proc { THEME_PRESETS.keys.map(&:to_s) } }
    before_validation :ensure_theme
  end

  def theme_name
    THEME_PRESETS[theme.to_sym][:name]
  end

  def theme_colors
    theme_preset = THEME_PRESETS[theme.to_sym]
    {
      primary: theme_preset[:primary],
      secondary: theme_preset[:secondary],
      text: theme_preset[:text],
      background: theme_preset[:background]
    }
  end

  private

  def ensure_theme
    self.theme = 'forest' if theme.blank?
  end
end 