// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import 'controllers';
// import "./confirmations"

// Fix modal backdrop stacking issue - only remove duplicates
document.addEventListener('shown.bs.modal', function(event) {
  // After modal is shown, check for duplicate backdrops and remove extras
  // Keep only the first backdrop (Bootstrap's default)
  const backdrops = document.querySelectorAll('.modal-backdrop');
  if (backdrops.length > 1) {
    // Remove all but the first backdrop
    for (let i = 1; i < backdrops.length; i++) {
      backdrops[i].remove();
    }
  }
});

document.addEventListener('hidden.bs.modal', function(event) {
  // Only clean up if this was the last modal
  const openModals = document.querySelectorAll('.modal.show');
  if (openModals.length === 0) {
    // Remove all backdrops when no modals are open
    const backdrops = document.querySelectorAll('.modal-backdrop');
    backdrops.forEach(backdrop => backdrop.remove());
    
    // Clean up body classes
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';
  } else {
    // If other modals are still open, just remove duplicate backdrops
    const backdrops = document.querySelectorAll('.modal-backdrop');
    if (backdrops.length > 1) {
      for (let i = 1; i < backdrops.length; i++) {
        backdrops[i].remove();
      }
    }
  }
});

// Clean up dropdowns before Turbo caches the page
document.addEventListener('turbo:before-cache', () => {
  if (window.bootstrap && window.bootstrap.Dropdown) {
    document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((dropdownToggle) => {
      const instance = bootstrap.Dropdown.getInstance(dropdownToggle);
      if (instance) {
        instance.dispose();
      }
      dropdownToggle.setAttribute('aria-expanded', 'false');
    });
  }
});

document.addEventListener('turbo:load', () => {
  // Initialize Bootstrap dropdowns
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((dropdownToggle) => {
    // Ensure dropdown is properly initialized
    if (window.bootstrap && window.bootstrap.Dropdown) {
      // Dispose of existing instance if it exists to prevent conflicts
      const existingInstance = bootstrap.Dropdown.getInstance(dropdownToggle);
      if (existingInstance) {
        existingInstance.dispose();
      }
      
      // Reset aria-expanded state before creating new instance
      dropdownToggle.setAttribute('aria-expanded', 'false');
      
      // Create new dropdown instance
      new bootstrap.Dropdown(dropdownToggle);
    }
  });
});

  // Carousel initialization
  document.querySelectorAll('.carousel').forEach((carousel) => {
    const counter = carousel.querySelector('.current-index');
    const nameElement = carousel.querySelector('.carousel-name');
    const labelElement = carousel.querySelector('.carousel-label');

    // Update counter, name, and label on slide change
    const updateCarouselInfo = () => {
      const items = carousel.querySelectorAll('.carousel-item');
      const active = carousel.querySelector('.carousel-item.active');
      const index = Array.from(items).indexOf(active) + 1;

      if (counter) {
        counter.textContent = index;
      }

      if (active) {
        const name = active.getAttribute('data-name') || 'No Name';
        const label = active.getAttribute('data-label');

        if (nameElement) {
          nameElement.textContent = name;
        }

        if (labelElement) {
          if (label && label.trim() !== '') {
            labelElement.textContent = label;
            labelElement.style.display = 'block';
          } else {
            labelElement.style.display = 'none';
          }
        }
      }
    };

    // Update on slide event
    carousel.addEventListener('slid.bs.carousel', updateCarouselInfo);

    // Initial update
    updateCarouselInfo();
  });
});

import 'trix';
import '@rails/actiontext';
