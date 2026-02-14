import { Controller } from "@hotwired/stimulus"

// Modal controller for waitlist and other modal dialogs
// Usage:
//   <div data-controller="modal">
//     <button data-action="modal#open">Open Modal</button>
//     <div data-modal-target="dialog" class="hidden">...</div>
//   </div>
export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  open(event) {
    event?.preventDefault()
    this.dialogTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close(event) {
    event?.preventDefault()
    this.dialogTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeOnOutsideClick(event) {
    // Only close if clicking directly on the backdrop (not on modal content)
    if (event.target === this.dialogTarget) {
      this.close(event)
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && !this.dialogTarget.classList.contains("hidden")) {
      this.close(event)
    }
  }
}
