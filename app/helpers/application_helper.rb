module ApplicationHelper
  def theme_styles
    return "" unless current_user&.family

    colors = current_user.family.theme_colors
    
    <<~CSS
      <style>
        :root {
          --primary-color: #{colors[:primary]};
          --secondary-color: #{colors[:secondary]};
          --text-color: #{colors[:text]};
          --background-color: #{colors[:background]};
        }

        body {
          background-color: var(--background-color);
          color: var(--text-color);
        }

        .theme-header {
          background-color: var(--primary-color);
        }

        .theme-button {
          background-color: var(--primary-color);
          color: white;
        }

        .theme-button:hover {
          background-color: var(--secondary-color);
        }

        .theme-text {
          color: var(--primary-color);
        }

        .theme-text-secondary {
          color: var(--secondary-color);
        }

        .theme-border {
          border-color: var(--primary-color);
        }

        .theme-border-secondary {
          border-color: var(--secondary-color);
        }

        .theme-hover:hover {
          color: var(--secondary-color);
        }
      </style>
    CSS
  end
end
