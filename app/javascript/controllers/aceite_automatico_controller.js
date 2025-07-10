import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { status: Boolean }

  initialize() {
    console.log('🎯 Aceite Automático Controller inicializado');
  }

  connect() {
    console.log('🎯 Aceite Automático Controller conectado');
    console.log('📊 Status inicial:', this.statusValue);
    console.log('🔗 Elemento:', this.element);
    console.log('🔍 Data attributes:', {
      controller: this.element.dataset.controller,
      statusValue: this.element.dataset.aceiteAutomaticoStatusValue,
      action: this.element.dataset.action
    });
    
    // Adicionar classe para animações
    this.element.classList.add('aceite-automatico-button');
  }

  async toggle(event) {
    event.preventDefault();
    event.stopPropagation();
    
    console.log('🔄 Toggle iniciado');
    console.log('🔍 Evento:', event);
    
    const button = this.element;
    const currentStatus = this.statusValue;
    const newStatus = !currentStatus;
    
    console.log(`🔄 Toggle: ${currentStatus} -> ${newStatus}`);
    console.log('🔍 Button element:', button);
    
    // Confirmação simples
    const actionText = newStatus ? 'ATIVAR' : 'DESATIVAR';
    if (!confirm(`Confirma ${actionText} o aceite automático?`)) {
      console.log('❌ Usuário cancelou');
      return;
    }
    
    // Animar botão
    this.animateButton(true);
    
    try {
      const token = this.getCSRFToken();
      console.log('🔑 CSRF Token:', token);
      
      const response = await fetch('/admin/toggle_aceite_automatico', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': token,
          'Accept': 'application/json'
        },
        body: `status=${newStatus ? 'on' : 'off'}`
      });

      console.log('📡 Resposta:', response.status);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('✅ Sucesso:', data);
      
      // Atualizar estado
      this.statusValue = newStatus;
      this.updateButton(newStatus);
      
      // Mostrar mensagem de sucesso
      this.showMessage('success', data.message || 'Status atualizado com sucesso!');
      
    } catch (error) {
      console.error('❌ Erro:', error);
      this.showMessage('danger', 'Erro ao atualizar status: ' + error.message);
    } finally {
      this.animateButton(false);
    }
  }

  animateButton(loading) {
    const button = this.element;
    const buttonText = button.querySelector('.button-text');
    const spinner = button.querySelector('.spinner-border');
    
    if (loading) {
      // Estado de loading
      button.disabled = true;
      button.classList.add('btn-loading');
      buttonText.style.display = 'none';
      spinner.classList.remove('d-none');
      
      // Adicionar animação de pulse
      button.style.animation = 'pulse 1s infinite';
    } else {
      // Estado normal
      button.disabled = false;
      button.classList.remove('btn-loading');
      buttonText.style.display = 'inline';
      spinner.classList.add('d-none');
      button.style.animation = '';
    }
  }

  updateButton(status) {
    const button = this.element;
    const buttonText = button.querySelector('.button-text');
    const card = button.closest('.card');
    const icon = card.querySelector('i');
    const badge = card.querySelector('.badge');
    
    console.log('🎨 Atualizando botão para status:', status);
    
    // Atualizar classes do botão
    button.classList.remove('btn-outline-success', 'btn-outline-danger');
    button.classList.add(status ? 'btn-outline-danger' : 'btn-outline-success');
    
    // Atualizar texto
    buttonText.textContent = status ? 'Desativar Aceite Automático' : 'Ativar Aceite Automático';
    
    // Atualizar ícone
    icon.className = status ? 'fas fa-toggle-on text-danger me-2 fs-4' : 'fas fa-toggle-off text-success me-2 fs-4';
    
    // Atualizar badge
    badge.className = status ? 'badge bg-danger bg-opacity-10 text-danger' : 'badge bg-success bg-opacity-10 text-success';
    badge.textContent = status ? 'ON' : 'OFF';
    
    // Adicionar animação de transição
    card.style.transition = 'all 0.3s ease';
    card.style.transform = 'scale(1.05)';
    setTimeout(() => {
      card.style.transform = 'scale(1)';
    }, 300);
  }

  showMessage(type, message) {
    console.log('💬 Mostrando mensagem:', type, message);
    
    // Criar toast personalizado
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    
    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">${message}</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    `;
    
    // Container para toasts
    let container = document.querySelector('.toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container position-fixed top-0 end-0 p-3';
      container.style.zIndex = '1055';
      document.body.appendChild(container);
    }
    
    container.appendChild(toast);
    
    // Mostrar toast
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    // Remover após 5 segundos
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 5000);
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }
}
