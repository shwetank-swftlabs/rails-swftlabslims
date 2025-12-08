import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static classes = ["open"]

  connect() {
    // Close dropdown when clicking outside
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
    
    // Close dropdown when pressing Escape
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
    this.close()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen) {
      this.close()
    } else {
      // Close all other dropdowns first
      this.closeAllOtherDropdowns()
      this.open()
    }
  }

  open() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("show")
      this.element.classList.add("show")
    }
    
    if (this.hasOpenClass) {
      this.openClasses.forEach(className => {
        this.element.classList.add(className)
        if (this.hasMenuTarget) {
          this.menuTarget.classList.add(className)
        }
      })
    }
    
    // Update aria-expanded
    const toggle = this.element.querySelector('[data-action*="dropdown#toggle"]') || this.element
    toggle.setAttribute("aria-expanded", "true")
    
    this.isOpen = true
  }

  close() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.remove("show")
      this.element.classList.remove("show")
    }
    
    if (this.hasOpenClass) {
      this.openClasses.forEach(className => {
        this.element.classList.remove(className)
        if (this.hasMenuTarget) {
          this.menuTarget.classList.remove(className)
        }
      })
    }
    
    // Update aria-expanded
    const toggle = this.element.querySelector('[data-action*="dropdown#toggle"]') || this.element
    toggle.setAttribute("aria-expanded", "false")
    
    this.isOpen = false
  }

  handleClickOutside(event) {
    // If dropdown is open and click is outside, close it
    if (this.isOpen && !this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }

  closeAllOtherDropdowns() {
    // Find all other open dropdowns and close them
    document.querySelectorAll('.dropdown.show').forEach(dropdown => {
      if (dropdown !== this.element) {
        const menu = dropdown.querySelector('.dropdown-menu')
        if (menu) {
          menu.classList.remove('show')
          dropdown.classList.remove('show')
          const toggle = dropdown.querySelector('[data-action*="dropdown#toggle"]') || dropdown
          toggle.setAttribute('aria-expanded', 'false')
        }
      }
    })
  }

  get isOpen() {
    if (this.hasMenuTarget) {
      return this.menuTarget.classList.contains("show") || this.element.classList.contains("show")
    }
    return this.element.classList.contains("show")
  }

  set isOpen(value) {
    // This is just for internal tracking, actual state is in DOM classes
  }
}

