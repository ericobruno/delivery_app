import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    status: Boolean,
    url: String
  }

  static targets = ["button"]

  initialize() {
    console.log('🎯 Aceite Automático Controller inicializado');
  }

  connect() {
    console.log('🎯 Aceite Automático Controller conectado');
    console.log('📊 Status inicial:', this.statusValue);
    console.log('🔗 URL:', this.urlValue);
    console.log('🔍 Elemento:', this.element);
    console.log('🎯 Botão target:', this.buttonTarget);
  }

  toggle(event) {
    event.preventDefault();
    event.stopPropagation();
    
    console.log('🔄 Toggle iniciado');
    console.log('🔍 Evento:', event);
    console.log('🎯 Botão clicado:', this.buttonTarget);
    
    // Teste simples - apenas mostrar alerta
    alert('Botão clicado! Status atual: ' + this.statusValue);
    
    // Confirmação simples
    const newStatus = !this.statusValue;
    const actionText = newStatus ? 'ATIVAR' : 'DESATIVAR';
    
    if (!confirm(`Confirma ${actionText} o aceite automático?`)) {
      console.log('❌ Usuário cancelou');
      return;
    }
    
    console.log('✅ Usuário confirmou, fazendo requisição...');
    
    // Por enquanto, apenas simular sucesso
    this.statusValue = newStatus;
    this.updateButton(newStatus);
    alert('Status alterado para: ' + (newStatus ? 'ON' : 'OFF'));
  }

  updateButton(status) {
    console.log('🎨 Atualizando botão para status:', status);
    
    const buttonText = this.buttonTarget.querySelector('.button-text');
    
    // Atualizar classes do botão
    this.buttonTarget.classList.remove('btn-outline-success', 'btn-outline-danger');
    this.buttonTarget.classList.add(status ? 'btn-outline-danger' : 'btn-outline-success');
    
    // Atualizar texto
    buttonText.textContent = status ? 'Desativar Aceite Automático' : 'Ativar Aceite Automático';
    
    console.log('✅ Botão atualizado');
  }
}
