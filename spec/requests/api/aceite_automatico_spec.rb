require 'rails_helper'

RSpec.describe 'API::Orders Aceite Automático', type: :request do
  let(:token) { ENV.fetch('API_ORDER_TOKEN', 'supersecreto') }
  let!(:customer) { Customer.create!(name: 'Cliente API', phone: '99999999') }
  let!(:product) { Product.create!(name: 'Produto API', price: 10.0) }

  def auth_headers
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  it 'cria pedido com status NOVO se aceite automático está ativado' do
    Setting.set('aceite_automatico', 'on')
    post '/api/orders',
      params: {
        order: {
          customer_id: customer.id,
          scheduled_for: 2.days.from_now,
          scheduled_notes: 'Teste aceite ON',
          order_items_attributes: [
            { product_id: product.id, quantity: 1, price: 10.0 }
          ]
        }
      }.to_json,
      headers: auth_headers
    expect(response).to have_http_status(:created)
    expect(Order.last.status).to eq('novo')
  end

  it 'cria pedido com status AG_APROVACAO se aceite automático está desativado' do
    Setting.set('aceite_automatico', 'off')
    post '/api/orders',
      params: {
        order: {
          customer_id: customer.id,
          scheduled_for: 2.days.from_now,
          scheduled_notes: 'Teste aceite OFF',
          order_items_attributes: [
            { product_id: product.id, quantity: 1, price: 10.0 }
          ]
        }
      }.to_json,
      headers: auth_headers
    expect(response).to have_http_status(:created)
    expect(Order.last.status).to eq('ag_aprovacao')
  end
end 