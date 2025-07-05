require 'rails_helper'

RSpec.describe 'Admin::Orders Aceite Manual', type: :request do
  let!(:customer) { Customer.create!(name: 'Cliente Admin', phone: '88888888') }
  let!(:product) { Product.create!(name: 'Produto Admin', price: 20.0) }
  let!(:order) do
    Order.create!(customer: customer, status: 'ag_aprovacao', scheduled_for: 1.day.from_now).tap do |o|
      OrderItem.create!(order: o, product: product, quantity: 1, price: 20.0)
    end
  end

  it 'aceita um pedido e muda o status para NOVO' do
    post accept_admin_order_path(order)
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.status).to eq('novo')
  end

  it 'não aceita um pedido já aceito' do
    order.update!(status: 'novo')
    post accept_admin_order_path(order)
    expect(response).to redirect_to(admin_order_path(order))
    expect(order.reload.status).to eq('novo')
  end
end 