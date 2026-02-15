import { Controller } from "@hotwired/stimulus"

// Nested form controller for adding/removing nested form fields
// Usage:
//   <div data-controller="nested-form">
//     <div data-nested-form-target="container">
//       <div data-nested-form-target="item">...</div>
//     </div>
//     <template data-nested-form-target="template">
//       <div data-nested-form-target="item">...</div>
//     </template>
//     <button data-action="nested-form#add">Add</button>
//   </div>
//
// Each item should have:
//   - A _destroy hidden field with data-nested-form-target="destroy"
//   - A remove button with data-action="nested-form#remove"
export default class extends Controller {
  static targets = ["container", "template", "item", "destroy"]

  add(event) {
    event.preventDefault()

    // Get template content and replace NEW_RECORD with a unique timestamp
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())

    // Insert the new fields
    this.containerTarget.insertAdjacentHTML("beforeend", content)

    // Update positions
    this.updatePositions()
  }

  remove(event) {
    event.preventDefault()

    // Find the parent item element
    const item = event.target.closest('[data-nested-form-target="item"]')

    if (item) {
      // Find the _destroy field within this item
      const destroyField = item.querySelector('[data-nested-form-target="destroy"]')

      if (destroyField) {
        // Mark for destruction and hide (for persisted records)
        destroyField.value = "1"
        item.classList.add("hidden")
        item.style.display = "none"
      } else {
        // Remove from DOM (for new records)
        item.remove()
      }

      // Update positions
      this.updatePositions()
    }
  }

  updatePositions() {
    // Update position values for visible items
    const visibleItems = this.itemTargets.filter(item =>
      !item.classList.contains("hidden") && item.style.display !== "none"
    )

    visibleItems.forEach((item, index) => {
      const positionField = item.querySelector('input[name*="[position]"]')
      if (positionField) {
        positionField.value = index
      }
    })
  }
}
