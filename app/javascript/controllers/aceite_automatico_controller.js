import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    status: Boolean,
    url: String
  }
  
  static targets = ["toggle", "label", "icon", "statusText"]

  connect() {
    console.log('🎯 Aceite Automático Toggle Controller conectado');
    console.log('📊 Status inicial:', this.statusValue);
    console.log('🔗 Elemento:', this.element);
    console.log('🔍 Data attributes:', {
      controller: this.element.dataset.controller,
      statusValue: this.element.dataset.aceiteAutomaticoStatusValue,
      urlValue: this.element.dataset.aceiteAutomaticoUrlValue
    });
    this.updateToggleDisplay();
  }

  disconnect() {
    console.log('🔌 Aceite Automático Controller desconectado');
  }

  test(event) {
    console.log('🧪 TESTE: Stimulus está funcionando!');
    alert('✅ Stimulus funcionando! Controller conectado com sucesso.');
    console.log('🧪 TESTE: Evento recebido:', event);
    console.log('🧪 TESTE: Status atual:', this.statusValue);
  }

  async toggle(event) {
    event.preventDefault();
    event.stopPropagation();
    
    console.log('🔄 Toggle aceite automático iniciado');
    console.log('🔍 Evento:', event);
    console.log('🔍 Checkbox checked:', this.toggleTarget.checked);
    
    // Obter o novo status baseado no estado do checkbox
    const newStatus = this.toggleTarget.checked;
    const actionText = newStatus ? 'ATIVAR' : 'DESATIVAR';
    
    console.log(`🔄 Toggle: ${this.statusValue} -> ${newStatus}`);
    
    // Confirmação com mensagem mais clara
    if (!confirm(`Confirma ${actionText} o aceite automático?\n\nQuando ATIVADO: Pedidos novos entram com status "NOVO"\nQuando DESATIVADO: Pedidos novos entram com status "AG. APROVAÇÃO"`)) {
      console.log('❌ Usuário cancelou toggle');
      // Reverter o toggle se cancelado
      this.toggleTarget.checked = !newStatus;
      return;
    }
    
    // Animar toggle durante processamento
    this.animateToggle(true);
    
    try {
      const token = this.getCSRFToken();
      console.log('🔑 CSRF Token obtido:', token ? 'OK' : 'FALHOU');
      
      const response = await fetch('/admin/toggle_aceite_automatico', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': token,
          'Accept': 'application/json, text/vnd.turbo-stream.html'
        },
        body: `status=${newStatus ? 'on' : 'off'}`
      });

      console.log('📡 Resposta do servidor:', response.status);
      console.log('📡 Headers:', response.headers);
      
      if (!response.ok) {
        throw new Error(`Erro HTTP ${response.status}: ${response.statusText}`);
      }
      
      // Verificar se é Turbo Stream
      const contentType = response.headers.get('content-type');
      console.log('📡 Content-Type:', contentType);
      
      if (contentType && contentType.includes('text/vnd.turbo-stream.html')) {
        // Processar Turbo Stream
        const html = await response.text();
        console.log('📡 Turbo Stream HTML:', html);
        Turbo.renderStreamMessage(html);
        console.log('✅ Turbo Stream processado');
      } else {
        // Processar JSON
        const data = await response.json();
        console.log('✅ Toggle realizado com sucesso:', data);
        
        // Atualizar estado local
        this.statusValue = newStatus;
        this.updateToggleDisplay();
        
        // Mostrar mensagem de sucesso
        this.showSuccessMessage(data.message || `Aceite automático ${newStatus ? 'ativado' : 'desativado'} com sucesso!`);
      }
      
    } catch (error) {
      console.error('❌ Erro no toggle:', error);
      this.showErrorMessage(`Erro ao ${newStatus ? 'ativar' : 'desativar'} aceite automático: ${error.message}`);
      
      // Reverter o toggle em caso de erro
      this.toggleTarget.checked = !newStatus;
    } finally {
      this.animateToggle(false);
    }
  }

  updateToggleDisplay() {
    const isOn = this.statusValue;
    
    console.log('🎨 Atualizando display do toggle para:', isOn ? 'ON' : 'OFF');
    
    // Atualizar classes do container
    this.element.classList.remove('toggle-off', 'toggle-on');
    this.element.classList.add(isOn ? 'toggle-on' : 'toggle-off');
    
    // Atualizar ícone
    if (this.hasIconTarget) {
      this.iconTarget.className = isOn 
        ? 'fas fa-robot text-success' 
        : 'fas fa-robot text-secondary';
    }
    
    // Atualizar texto do status
    if (this.hasStatusTextTarget) {
      this.statusTextTarget.textContent = isOn ? 'ATIVADO' : 'DESATIVADO';
      this.statusTextTarget.className = isOn 
        ? 'badge bg-success bg-opacity-10 text-success' 
        : 'badge bg-secondary bg-opacity-10 text-secondary';
    }
    
    // Atualizar label
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = isOn 
        ? 'Aceite Automático ATIVADO' 
        : 'Aceite Automático DESATIVADO';
    }
    
    // Atualizar estado do toggle
    if (this.hasToggleTarget) {
      this.toggleTarget.checked = isOn;
    }
    
    // Adicionar animação de transição
    this.element.style.transition = 'all 0.3s ease';
    this.element.style.transform = 'scale(1.05)';
    setTimeout(() => {
      this.element.style.transform = 'scale(1)';
    }, 300);
  }

  animateToggle(loading) {
    const toggle = this.hasToggleTarget ? this.toggleTarget : this.element;
    
    if (loading) {
      // Estado de loading
      toggle.disabled = true;
      toggle.classList.add('toggle-switch-loading');
      console.log('⏳ Toggle em loading...');
    } else {
      // Estado normal
      toggle.disabled = false;
      toggle.classList.remove('toggle-switch-loading');
      console.log('✅ Toggle saiu do loading');
    }
  }

  showSuccessMessage(message) {
    this.showToast('success', '✅ ' + message);
  }

  showErrorMessage(message) {
    this.showToast('danger', '❌ ' + message);
  }

  showToast(type, message) {
    console.log('💬 Mostrando toast:', type, message);
    
    // Criar toast moderno
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    
    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body d-flex align-items-center">
          <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-triangle'} me-2"></i>
          ${message}
        </div>
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
    const bsToast = new bootstrap.Toast(toast, { delay: 4000 });
    bsToast.show();
    
    // Remover após 4 segundos
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 4000);
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }
}
