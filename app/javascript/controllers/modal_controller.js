import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('🔥 Modal controller connected - WORKING!');
    console.log('Modal element:', this.element);
    
    // Add backdrop when modal is shown
    document.body.classList.add('modal-open')
    document.body.style.overflow = 'hidden'
    
    // Add event listener for ESC key
    this.escapeListener = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.escapeListener)
  }

  disconnect() {
    console.log('Modal controller disconnected');
    
    // Remove backdrop when modal is disconnected
    document.body.classList.remove('modal-open')
    document.body.style.overflow = ''
    
    // Remove ESC key listener
    if (this.escapeListener) {
      document.removeEventListener('keydown', this.escapeListener)
    }
  }

  close(event) {
    console.log('🚀 Modal close called - button clicked', event);
    
    // Close modal by removing the turbo frame content
    const modalFrame = document.getElementById('modal')
    if (modalFrame) {
      console.log('Modal frame found, clearing content');
      modalFrame.innerHTML = ''
    } else {
      console.log('❌ Modal frame not found');
    }
  }

  closeBackground(event) {
    console.log('Modal closeBackground called', event.target, event.currentTarget);
    
    // Close modal when clicking on backdrop (only if clicking the backdrop itself)
    if (event.target === this.element) {
      console.log('Clicked on backdrop, closing modal');
      this.close(event)
    } else {
      console.log('Clicked inside modal content, not closing');
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      console.log('ESC key pressed, closing modal');
      this.close(event)
    }
  }
} 