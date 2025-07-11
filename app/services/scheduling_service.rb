class SchedulingService
  def initialize(configuration = SchedulingConfiguration.load_from_settings)
    @configuration = configuration
  end

  def available_slots_for_date(date)
    return [] unless @configuration.scheduling_enabled?

    slots = SchedulingAvailability.get_available_slots_for_date(date)
    
    # Filtrar slots baseado nas configurações
    slots = filter_slots_by_configuration(slots, date)
    
    slots
  end

  def can_schedule_for_same_day?
    @configuration.same_day_scheduling_enabled?
  end

  def can_schedule_when_closed?
    @configuration.closed_store_scheduling_enabled?
  end

  def time_interval_in_minutes
    @configuration.time_interval_in_minutes
  end

  def max_days_ahead
    @configuration.max_days_ahead
  end

  def acceptance_mode
    @configuration.acceptance_mode
  end

  def cancellation_deadline_for_order(order)
    return nil unless order.scheduled_for.present?
    
    hours_before = @configuration.cancellation_time_in_hours
    order.scheduled_for - hours_before.hours
  end

  def production_deadline_for_order(order)
    return nil unless order.scheduled_for.present?
    
    hours_before = @configuration.production_time_in_hours
    order.scheduled_for - hours_before.hours
  end

  def should_move_order_to_production?(order)
    return false unless order.scheduled_for.present?
    
    deadline = production_deadline_for_order(order)
    deadline && Time.current >= deadline
  end

  def can_cancel_order?(order)
    return true unless order.scheduled_for.present?
    
    deadline = cancellation_deadline_for_order(order)
    deadline && Time.current < deadline
  end

  private

  def filter_slots_by_configuration(slots, date)
    current_time = Time.current
    
    # Se é o mesmo dia e não permite agendamento para o mesmo dia
    if date.to_date == current_time.to_date && !can_schedule_for_same_day?
      return []
    end

    # Se é o mesmo dia, filtrar slots passados
    if date.to_date == current_time.to_date
      current_hour = current_time.hour
      slots = slots.select do |slot|
        slot_hour = slot.split(':').first.to_i
        slot_hour > current_hour
      end
    end

    # Aplicar intervalo de tempo
    interval_minutes = time_interval_in_minutes
    if interval_minutes > 60
      # Se o intervalo é maior que 1 hora, filtrar slots
      slots = slots.select.with_index do |slot, index|
        index % (interval_minutes / 60) == 0
      end
    end

    slots
  end
end