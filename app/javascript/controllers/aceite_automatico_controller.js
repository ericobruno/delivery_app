import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "loading"]
  static values = { 
    url: String,
    currentStatus: String 
  }

  connect() {
    console.log('🎯 Aceite Automático Toggle Controller conectado');
    console.log('📊 Status inicial:', this.currentStatusValue);
    console.log('🔗 URL:', this.urlValue);
    
    // Sincronizar estado inicial do toggle
    this.syncToggleState();
  }

  async handleToggle(event) {
    const toggle = this.toggleTarget;
    const newStatus = toggle.checked;
    const actionText = newStatus ? 'ATIVAR' : 'DESATIVAR';
    
    console.log(`🔄 Toggle acionado: ${this.currentStatusValue} -> ${newStatus ? 'on' : 'off'}`);
    
    // Confirmação com design mais amigável
    const confirmMessage = `
      ${actionText} o aceite automático?
      
      ${newStatus ? 
        '✅ Novos pedidos serão aceitos automaticamente' : 
        '⏳ Novos pedidos aguardarão aprovação manual'
      }
    `;
    
    if (!confirm(confirmMessage)) {
      console.log('❌ Usuário cancelou - revertendo toggle');
      // Reverter o toggle sem disparar o evento
      toggle.checked = !newStatus;
      return;
    }
    
    // Mostrar loading
    this.showLoading(true);
    this.animateToggle();
    
    try {
      const response = await this.makeToggleRequest(newStatus);
      
      if (response.success) {
        // Atualizar estado interno
        this.currentStatusValue = response.status;
        
        // Atualizar UI
        this.updateUI(response.status === 'on');
        
        // Mostrar mensagem de sucesso
        this.showNotification('success', response.message);
        
        console.log('✅ Toggle atualizado com sucesso:', response.status);
      } else {
        throw new Error(response.message || 'Erro desconhecido');
      }
      
    } catch (error) {
      console.error('❌ Erro ao alterar aceite automático:', error);
      
      // Reverter toggle em caso de erro
      toggle.checked = !newStatus;
      
      // Mostrar erro
      this.showNotification('error', `Erro: ${error.message}`);
      
    } finally {
      this.showLoading(false);
    }
  }

  async makeToggleRequest(newStatus) {
    const token = this.getCSRFToken();
    const statusValue = newStatus ? 'on' : 'off';
    
    console.log('📡 Enviando requisição:', { status: statusValue });
    
    const response = await fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': token,
        'Accept': 'application/json'
      },
      body: `status=${statusValue}`
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return await response.json();
  }

  syncToggleState() {
    const isActive = this.currentStatusValue === 'on';
    const toggle = this.toggleTarget;
    
    toggle.checked = isActive;
    this.updateUI(isActive);
  }

  updateUI(isActive) {
    // Atualizar badge
    const badge = this.element.querySelector('.badge');
    if (badge) {
      badge.className = `badge ms-2 ${isActive ? 'bg-success' : 'bg-secondary'}`;
      badge.textContent = isActive ? 'ATIVO' : 'INATIVO';
    }
    
    // Atualizar texto descritivo
    const description = this.element.querySelector('.text-muted');
    if (description) {
      description.textContent = isActive ? 
        'Novos pedidos são aceitos automaticamente' : 
        'Novos pedidos aguardam aprovação manual';
    }
    
    // Atualizar texto do toggle
    const toggleText = this.element.querySelector('.toggle-text');
    if (toggleText) {
      toggleText.textContent = isActive ? 'ON' : 'OFF';
    }
    
    // Animar card
    this.animateCard();
  }

  animateToggle() {
    const toggle = this.toggleTarget;
    toggle.classList.add('animating');
    
    setTimeout(() => {
      toggle.classList.remove('animating');
    }, 300);
  }

  animateCard() {
    const card = this.element.querySelector('.card');
    if (card) {
      card.style.transform = 'scale(1.02)';
      setTimeout(() => {
        card.style.transform = 'scale(1)';
      }, 200);
    }
  }

  showLoading(show) {
    const loadingOverlay = this.loadingTarget;
    const toggle = this.toggleTarget;
    
    if (show) {
      loadingOverlay.classList.remove('d-none');
      toggle.disabled = true;
    } else {
      loadingOverlay.classList.add('d-none');
      toggle.disabled = false;
    }
  }

  showNotification(type, message) {
    // Criar notificação moderna
    const notification = document.createElement('div');
    notification.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show position-fixed`;
    notification.style.cssText = `
      top: 20px;
      right: 20px;
      z-index: 1055;
      min-width: 300px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.15);
      border: none;
      border-radius: 8px;
    `;
    
    const icon = type === 'success' ? '✅' : '❌';
    notification.innerHTML = `
      <div class="d-flex align-items-center">
        <span class="me-2">${icon}</span>
        <div class="flex-grow-1">${message}</div>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remover após 4 segundos
    setTimeout(() => {
      if (notification.parentNode) {
        notification.classList.remove('show');
        setTimeout(() => {
          if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
          }
        }, 150);
      }
    }, 4000);
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }
}
