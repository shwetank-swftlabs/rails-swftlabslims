// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import 'controllers';
// import "./confirmations"

document.addEventListener('turbo:load', () => {
  // Initialize Bootstrap dropdowns
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((dropdownToggle) => {
    // Ensure dropdown is properly initialized
    if (window.bootstrap && window.bootstrap.Dropdown) {
      new bootstrap.Dropdown(dropdownToggle);
    }
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
