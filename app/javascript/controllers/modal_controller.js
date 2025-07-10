import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "backdrop"]
  static values = { 
    title: String,
    content: String
  }

  connect() {
    console.log("Modal controller conectado")
  }

  show() {
    this.createModal()
    this.modalTarget.classList.add('show')
    this.modalTarget.style.display = 'block'
    document.body.classList.add('modal-open')
    
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add('show')
    }
  }

  hide() {
    this.modalTarget.classList.remove('show')
    this.modalTarget.style.display = 'none'
    document.body.classList.remove('modal-open')
    
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('show')
    }
  }

  createModal() {
    if (!this.hasModalTarget) {
      const modal = document.createElement('div')
      modal.className = 'modal fade'
      modal.setAttribute('tabindex', '-1')
      modal.setAttribute('aria-labelledby', 'modalLabel')
      modal.setAttribute('aria-hidden', 'true')
      modal.setAttribute('data-modal-target', 'modal')
      
      modal.innerHTML = `
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="modalLabel">${this.titleValue || 'Confirmação'}</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              ${this.contentValue || 'Tem certeza que deseja continuar?'}
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-action="click->modal#hide">Cancelar</button>
              <button type="button" class="btn btn-primary" data-action="click->modal#confirm">Confirmar</button>
            </div>
          </div>
        </div>
      `
      
      document.body.appendChild(modal)
      this.modalTarget = modal
    }
  }

  confirm() {
    this.hide()
    this.dispatch('confirmed')
  }

  // Método para mostrar confirmação customizada
  showConfirmation(title, content, onConfirm) {
    this.titleValue = title
    this.contentValue = content
    this.show()
    
    this.element.addEventListener('modal:confirmed', onConfirm, { once: true })
  }
}