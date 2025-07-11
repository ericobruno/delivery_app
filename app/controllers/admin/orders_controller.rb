class Admin::OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy update_status]

  def index
    @orders = Order.includes(:customer, :order_items).all
  end

  def show
  end

  def new
    @order = Order.new
    @order.order_items.build
  end

  def create
    @order = Order.new(order_params)
    
    # Se o pedido tem agendamento, usar o serviço de agendamento
    if @order.scheduled_for.present?
      scheduling_service = OrderSchedulingService.new
      if scheduling_service.schedule_order(@order, @order.scheduled_for)
        redirect_to admin_order_path(@order), notice: 'Pedido agendado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      # Comportamento padrão para pedidos sem agendamento
      status = Setting.automatic_acceptance_enabled? ? 'producao' : 'novo'
      @order.status = status
      
      if @order.save
        redirect_to admin_order_path(@order), notice: 'Pedido criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: 'Pedido atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: 'Pedido removido com sucesso.'
  end

  def accept
    @order = Order.find(params[:id])
    service = OrderStatusService.new(@order)
    
    if service.approve!
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_order_path(@order), notice: 'Pedido aceito com sucesso!' }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to admin_order_path(@order), alert: 'Pedido já foi aceito ou não está aguardando aprovação.' }
      end
    end
  end

  def update_status
    new_status = params[:status]
    
    # Validar se a transição é permitida usando OrderStatusService
    service = OrderStatusService.new(@order)
    valid_transitions = service.status_transitions
    
    unless valid_transitions.include?(new_status)
      render json: { 
        error: 'Transição de status não permitida',
        valid_transitions: valid_transitions 
      }, status: :unprocessable_entity
      return
    end
    
    if @order.update(status: new_status)
      render json: { 
        success: true,
        message: "Status atualizado para #{new_status.tr('_', ' ')}", 
        order: {
          id: @order.id,
          status: @order.status
        }
      }
    else
      render json: { 
        error: 'Erro ao atualizar status',
        errors: @order.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def cancel_scheduled_order
    scheduling_service = OrderSchedulingService.new
    
    if scheduling_service.cancel_scheduled_order(@order)
      redirect_to admin_order_path(@order), notice: 'Pedido agendado cancelado com sucesso.'
    else
      redirect_to admin_order_path(@order), alert: 'Não foi possível cancelar o pedido agendado.'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:customer_id, :status, :scheduled_for, :scheduled_notes, order_items_attributes: [:id, :product_id, :quantity, :price, :_destroy])
  end
end
