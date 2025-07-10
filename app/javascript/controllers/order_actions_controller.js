import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('📋 OrderActions controller connected');
  }

  approve(event) {
    console.log('✅ Approve order action called');
    
    const button = event.currentTarget;
    const originalText = button.textContent;
    const confirmMessage = button.dataset.turboConfirm || button.dataset.confirm;
    
    // Mostrar confirmação se definida
    if (confirmMessage && !confirm(confirmMessage)) {
      console.log('❌ User canceled approval');
      event.preventDefault();
      return false;
    }
    
    // Feedback visual
    button.disabled = true;
    button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Aprovando...';
    
    console.log('📤 Button disabled, showing loading state');
    
    // O Rails/Turbo vai processar automaticamente
    // Não tentamos interceptar ou processar manualmente
  }
} 