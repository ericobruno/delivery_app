# Configuração para jobs recorrentes de agendamento
# Este arquivo configura jobs que devem ser executados periodicamente

if Rails.env.production?
  # Configurar job para mover pedidos agendados para produção
  # Executar a cada 15 minutos
  Rails.application.config.after_initialize do
    unless defined?(Rails::Console) || defined?(Rails::Server)
      # Usar Sidekiq ou outro scheduler se disponível
      # Por enquanto, vamos usar um thread simples
      Thread.new do
        loop do
          begin
            MoveScheduledOrdersToProductionJob.perform_later
            sleep(15.minutes)
          rescue => e
            Rails.logger.error "Erro no job de agendamento: #{e.message}"
            sleep(1.minute)
          end
        end
      end
    end
  end
end