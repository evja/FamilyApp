import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "modal"]
  static values = { phrase: String }

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleKeydown)
  }

  handleKeydown(event) {
    if (event.key === 'Escape' && !this.modalTarget.classList.contains('hidden')) {
      this.close()
    }
  }

  open() {
    this.modalTarget.classList.remove('hidden')
    this.inputTarget.value = ''
    this.inputTarget.focus()
    this.updateButton()
  }

  close() {
    this.modalTarget.classList.add('hidden')
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  checkPhrase() {
    this.updateButton()
  }

  updateButton() {
    const matches = this.inputTarget.value.trim() === this.phraseValue
    this.buttonTarget.disabled = !matches
    this.buttonTarget.classList.toggle('opacity-50', !matches)
    this.buttonTarget.classList.toggle('cursor-not-allowed', !matches)
  }
}
