import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import { createIcons, icons } from "lucide";

document.addEventListener("DOMContentLoaded", () => {
  createIcons({ icons });
});
