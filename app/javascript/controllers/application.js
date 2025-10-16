import { Application } from "@hotwired/stimulus"
import { createIcons, icons } from "lucide"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// Initialize Lucide icons
document.addEventListener("DOMContentLoaded", () => {
  createIcons({ icons });
});

// Re-initialize icons after Turbo navigation
document.addEventListener("turbo:load", () => {
  createIcons({ icons });
});
