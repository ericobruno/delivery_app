import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = { 
    currentStatus: String,
    url: String
  }

  connect() {
    console.log("Aceite automático controller conectado")
  }

  async toggle() {
    const newStatus = this.currentStatusValue === 'on' ? 'off' : 'on'
    const confirmMessage = this.currentStatusValue === 'on' 
      ? 'Tem certeza que deseja DESATIVAR o aceite automático?'
      : 'Tem certeza que deseja ATIVAR o aceite automático?'
    
    if (!confirm(confirmMessage)) {
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = 'Processando...'

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: `status=${newStatus}`
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      
      if (data.success) {
        this.currentStatusValue = data.status
        this.updateButton(data.status)
        this.showNotification(data.message, 'success')
      } else {
        throw new Error(data.message || 'Erro desconhecido')
      }
    } catch (error) {
      console.error('Erro na requisição:', error)
      this.showNotification('Erro ao alterar configuração: ' + error.message, 'error')
      this.buttonTarget.textContent = `Aceite automático ${this.currentStatusValue.toUpperCase()}`
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  updateButton(status) {
    this.buttonTarget.setAttribute('data-status', status)
    this.buttonTarget.textContent = `Aceite automático ${status.toUpperCase()}`
    
    if (status === 'on') {
      this.buttonTarget.classList.remove('btn-outline-secondary')
      this.buttonTarget.classList.add('btn-success')
    } else {
      this.buttonTarget.classList.remove('btn-success')
      this.buttonTarget.classList.add('btn-outline-secondary')
    }
  }

  showNotification(message, type) {
    // Criar notificação toast
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
    
    // Remover após 5 segundos
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