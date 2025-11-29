// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import 'controllers';
// import "./confirmations"

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('.carousel').forEach((carousel) => {
    const counter = carousel.querySelector('.current-index');
    const label = carousel.querySelector('.carousel-label');

    // Update counter and label on slide change
    const updateCarouselInfo = () => {
      const items = carousel.querySelectorAll('.carousel-item');
      const active = carousel.querySelector('.carousel-item.active');
      const index = Array.from(items).indexOf(active) + 1;

      if (counter) {
        counter.textContent = index;
      }

      if (label && active) {
        const labelText = active.getAttribute('data-label') || 'No Label';
        label.textContent = labelText;
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
