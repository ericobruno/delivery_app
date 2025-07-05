import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    console.log("Aceite controller conectado")
  }

  toggle() {
    const button = this.buttonTarget
    const currentStatus = button.getAttribute('data-status')
    const newStatus = currentStatus === 'on' ? 'off' : 'on'
    
    // Confirmar ação
    const confirmMessage = currentStatus === 'on' 
      ? 'Tem certeza que deseja DESATIVAR o aceite automático?'
      : 'Tem certeza que deseja ATIVAR o aceite automático?'
    
    if (!confirm(confirmMessage)) {
      return
    }

    fetch('/admin/toggle_aceite_automatico', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: `status=${newStatus}`
    })
    .then(response => response.json())
    .then(data => {
      button.setAttribute('data-status', newStatus)
      button.textContent = `Aceite automático ${newStatus.toUpperCase()}`
      
      // Atualizar classes do botão
      if (newStatus === 'on') {
        button.classList.remove('btn-outline-secondary')
        button.classList.add('btn-success')
      } else {
        button.classList.remove('btn-success')
        button.classList.add('btn-outline-secondary')
      }
    })
    .catch(error => {
      console.error('Erro:', error)
      alert('Erro ao alterar configuração')
    })
  }
} 