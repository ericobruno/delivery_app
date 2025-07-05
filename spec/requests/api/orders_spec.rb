require 'rails_helper'

RSpec.describe 'API::Orders', type: :request do
  let(:token) { ENV.fetch('API_ORDER_TOKEN', 'supersecreto') }
  let!(:customer) { Customer.create!(name: 'Cliente API', phone: '99999999') }
  let!(:product) { Product.create!(name: 'Produto API', price: 10.0) }

  def auth_headers
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  it 'cria um pedido com autenticação' do
    Setting.set('aceite_automatico', 'off')
    post '/api/orders',
      params: {
        order: {
          customer_id: customer.id,
          status: 'agendado',
          scheduled_for: 2.days.from_now,
          scheduled_notes: 'Entregar na portaria',
          order_items_attributes: [
            { product_id: product.id, quantity: 2, price: 10.0 }
          ]
        }
      }.to_json,
      headers: auth_headers

    expect(response).to have_http_status(:created)
    expect(Order.last.status).to eq('ag_aprovacao') # ou 'novo', dependendo do aceite automático
  end

  it 'retorna 401 sem autenticação' do
    post '/api/orders',
      params: { order: { customer_id: customer.id } }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'retorna 422 para dados inválidos' do
    post '/api/orders',
      params: { order: { customer_id: nil } }.to_json,
      headers: auth_headers
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)).to be_a(Hash)
    expect(JSON.parse(response.body)).to have_key('customer')
  end
end 