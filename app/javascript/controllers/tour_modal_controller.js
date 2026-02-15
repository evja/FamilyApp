import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { module: String }

  connect() {
    // Prevent body scroll while modal is open
    document.body.style.overflow = "hidden"

    // Add escape key listener
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.dismiss()
    }
  }

  dismiss() {
    // POST to mark tour as complete
    const csrfToken = document.querySelector("[name='csrf-token']")?.content

    fetch(`/module_tours/${this.moduleValue}/complete`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      }
    })

    // Remove modal from DOM
    this.element.remove()

    // Restore body scroll
    document.body.style.overflow = ""
  }
}
