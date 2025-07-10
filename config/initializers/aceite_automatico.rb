# CRÍTICO: Garantir que aceite automático sempre existe
# Este initializer é executado no boot da aplicação

Rails.application.config.after_initialize do
  begin
    # Verificar se o banco está acessível
    ActiveRecord::Base.connection.execute("SELECT 1")
    
    # Garantir que a setting existe
    unless Setting.exists?(key: 'aceite_automatico')
      Rails.logger.warn "⚠️ INICIALIZAÇÃO: Criando setting aceite_automatico com valor padrão 'off'"
      Setting.create!(key: 'aceite_automatico', value: 'off')
    end
    
    current_value = Setting.find_by(key: 'aceite_automatico')&.value
    Rails.logger.info "✅ INICIALIZAÇÃO: Aceite automático configurado como: #{current_value}"
    
  rescue ActiveRecord::StatementInvalid => e
    # Banco não está pronto (ex: durante migrations)
    Rails.logger.warn "⚠️ INICIALIZAÇÃO: Banco não acessível, pulando verificação de aceite automático: #{e.message}"
  rescue => e
    Rails.logger.error "❌ INICIALIZAÇÃO: Erro ao verificar aceite automático: #{e.message}"
  end
end 