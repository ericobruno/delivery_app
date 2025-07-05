class Admin::OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]

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
    status = Setting.aceite_automatico? ? 'novo' : 'ag_aprovacao'
    @order = Order.new(order_params.merge(status: status))
    if @order.save
      redirect_to admin_order_path(@order), notice: 'Pedido criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
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
    if @order.status == 'ag_aprovacao'
      @order.update!(status: 'novo')
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

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:customer_id, :status, :scheduled_for, :scheduled_notes, order_items_attributes: [:id, :product_id, :quantity, :price, :_destroy])
  end
end
