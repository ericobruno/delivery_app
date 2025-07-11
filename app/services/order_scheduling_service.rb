class OrderSchedulingService
  def initialize(scheduling_service = SchedulingService.new)
    @scheduling_service = scheduling_service
  end

  def schedule_order(order, scheduled_time)
    return false unless valid_scheduling_time?(scheduled_time)

    order.scheduled_for = scheduled_time
    order.status = determine_initial_status(order)
    
    if order.save
      notify_order_scheduled(order)
      true
    else
      false
    end
  end

  def cancel_scheduled_order(order)
    return false unless @scheduling_service.can_cancel_order?(order)

    order.status = 'cancelado'
    
    if order.save
      notify_order_cancelled(order)
      true
    else
      false
    end
  end

  def move_orders_to_production
    orders_to_move = Order.where(status: 'novo')
                         .where.not(scheduled_for: nil)
                         .select { |order| @scheduling_service.should_move_order_to_production?(order) }

    orders_to_move.each do |order|
      order.update_column(:status, 'producao')
      notify_order_moved_to_production(order)
    end

    orders_to_move.count
  end

  def get_available_slots_for_date_range(start_date, end_date)
    available_slots = {}
    
    (start_date..end_date).each do |date|
      slots = @scheduling_service.available_slots_for_date(date)
      available_slots[date] = slots if slots.any?
    end
    
    available_slots
  end

  def validate_scheduling_time(scheduled_time)
    return false unless scheduled_time.present?
    return false if scheduled_time < Time.current
    
    # Verificar se está dentro da janela de agendamento
    max_date = Date.current + @scheduling_service.max_days_ahead.days
    return false if scheduled_time.to_date > max_date
    
    # Verificar se o horário está disponível
    SchedulingAvailability.is_available_for_date_and_time?(
      scheduled_time.to_date, 
      scheduled_time
    )
  end

  private

  def valid_scheduling_time?(scheduled_time)
    validate_scheduling_time(scheduled_time)
  end

  def determine_initial_status(order)
    if @scheduling_service.acceptance_mode == 'automatic'
      'producao'
    else
      'novo'
    end
  end

  def notify_order_scheduled(order)
    # Aqui você pode implementar notificações (email, SMS, etc.)
    Rails.logger.info "Pedido #{order.id} agendado para #{order.scheduled_for}"
  end

  def notify_order_cancelled(order)
    # Aqui você pode implementar notificações (email, SMS, etc.)
    Rails.logger.info "Pedido #{order.id} cancelado"
  end

  def notify_order_moved_to_production(order)
    # Aqui você pode implementar notificações (email, SMS, etc.)
    Rails.logger.info "Pedido #{order.id} movido para produção"
  end
end