class Admin::SchedulingController < ApplicationController
  # Temporarily removing authentication to test routes
  # before_action :authenticate_user!

  def index
    # Temporariamente, vamos apenas renderizar uma página simples
    render plain: "Página de Configurações de Agendamento - Funcionando! Timestamp: #{Time.current}"
  end

  def update_configuration
    render plain: "Configuração atualizada! Timestamp: #{Time.current}"
  end

  def update_availability
    render plain: "Disponibilidade atualizada! Timestamp: #{Time.current}"
  end

  def move_orders_to_production
    render plain: "Pedidos movidos para produção! Timestamp: #{Time.current}"
  end
end