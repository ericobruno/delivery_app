class Admin::SchedulingController < ApplicationController
  before_action :authenticate_user!
  before_action :load_configuration
  before_action :load_availability

  def index
    @scheduling_service = SchedulingService.new(@configuration)
  end

  def update_configuration
    if @configuration.update(configuration_params)
      @configuration.save_to_settings
      redirect_to admin_scheduling_index_path, notice: 'Configurações de agendamento atualizadas com sucesso!'
    else
      @scheduling_service = SchedulingService.new(@configuration)
      render :index
    end
  end

  def update_availability
    if update_availability_params
      SchedulingAvailability.save_all_to_settings(@availability)
      redirect_to admin_scheduling_index_path, notice: 'Disponibilidade de horários atualizada com sucesso!'
    else
      @scheduling_service = SchedulingService.new(@configuration)
      render :index
    end
  end

  def move_orders_to_production
    service = OrderSchedulingService.new
    moved_count = service.move_orders_to_production
    
    redirect_to admin_orders_path, notice: "#{moved_count} pedidos movidos para produção."
  end

  private

  def load_configuration
    @configuration = SchedulingConfiguration.load_from_settings
  end

  def load_availability
    @availability = SchedulingAvailability.load_from_settings
  end

  def configuration_params
    params.require(:scheduling_configuration).permit(
      :scheduling_enabled,
      :max_days_ahead,
      :same_day_scheduling_enabled,
      :same_day_intervals,
      :closed_store_scheduling_enabled,
      :acceptance_mode,
      :time_unit,
      :time_interval,
      :cancellation_unit,
      :cancellation_value,
      :production_unit,
      :production_value
    )
  end

  def update_availability_params
    params.require(:availability).permit!
  end
end