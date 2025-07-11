class MoveScheduledOrdersToProductionJob < ApplicationJob
  queue_as :default

  def perform
    service = OrderSchedulingService.new
    moved_count = service.move_orders_to_production
    
    Rails.logger.info "MoveScheduledOrdersToProductionJob: #{moved_count} pedidos movidos para produção"
    
    # Notificar administradores se muitos pedidos foram movidos
    if moved_count > 10
      # Aqui você pode implementar notificação por email ou outros meios
      Rails.logger.warn "MoveScheduledOrdersToProductionJob: #{moved_count} pedidos movidos para produção - verificar se há problemas"
    end
  end
end