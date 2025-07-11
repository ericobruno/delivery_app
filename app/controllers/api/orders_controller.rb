class Api::OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate_api_token!

  def create
    status = Setting.aceite_automatico? ? 'producao' : 'ag_aprovacao'
    @order = Order.new(order_params.merge(status: status))
    if @order.save
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def authenticate_api_token!
    token = request.headers['Authorization'].to_s.remove(/^Bearer /)
    unless ActiveSupport::SecurityUtils.secure_compare(token, ENV.fetch('API_ORDER_TOKEN', 'supersecreto'))
      render json: {
        erro: 'não autorizado',
        mensagem: 'Token de autenticação inválido ou ausente.'
      }, status: :unauthorized
    end
  end

  def order_params
    params.require(:order).permit(:customer_id, :status, :scheduled_for, :scheduled_notes, order_items_attributes: [:product_id, :quantity, :price])
  end
end
