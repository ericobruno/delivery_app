import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = { 
    orderId: Number,
    currentStatus: String,
    url: String
  }

  connect() {
    console.log("Order actions controller conectado")
  }

  async approve() {
    if (!confirm('Aprovar este pedido? Isso o colocará como NOVO para produção.')) {
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = 'Aprovando...'

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      // Turbo Stream irá atualizar o frame automaticamente
      this.showNotification('Pedido aprovado com sucesso!', 'success')
    } catch (error) {
      console.error('Erro ao aprovar pedido:', error)
      this.showNotification('Erro ao aprovar pedido: ' + error.message, 'error')
      this.buttonTarget.textContent = 'Aprovar'
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  showNotification(message, type) {
    const toast = document.createElement('div')
    toast.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : 'danger'} border-0`
    toast.setAttribute('role', 'alert')
    toast.setAttribute('aria-live', 'assertive')
    toast.setAttribute('aria-atomic', 'true')
    
    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">
          ${message}
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    `
    
    const container = document.querySelector('.toast-container') || this.createToastContainer()
    container.appendChild(toast)
    
    const bsToast = new bootstrap.Toast(toast)
    bsToast.show()
    
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast)
      }
    }, 5000)
  }

  createToastContainer() {
    const container = document.createElement('div')
    container.className = 'toast-container position-fixed top-0 end-0 p-3'
    container.style.zIndex = '1055'
    document.body.appendChild(container)
    return container
  }
}