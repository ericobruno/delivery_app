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
    
    // Remover mensagens existentes
    const existingAlerts = document.querySelectorAll('.aceite-automatico-alert');
    existingAlerts.forEach(alert => alert.remove());
    
    // Criar alerta temporário
    const alert = document.createElement('div');
    alert.className = `alert alert-${type} alert-dismissible fade show position-fixed aceite-automatico-alert`;
    alert.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);';
    alert.innerHTML = `
      <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2"></i>
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alert);
    
    // Auto-remove após 4 segundos
    setTimeout(() => {
      if (alert.parentNode) {
        alert.style.opacity = '0';
        alert.style.transform = 'translateX(100%)';
        setTimeout(() => alert.remove(), 300);
      }
    }, 4000);
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    if (!token) {
      console.error('❌ CSRF token não encontrado!');
    }
    return token;
  }
} 