require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:customer) { Customer.create!(name: 'Cliente Teste', phone: '123456789') }

  it 'permite agendar para o futuro' do
    order = Order.new(customer: customer, scheduled_for: 1.day.from_now)
    order.valid?
    expect(order.errors[:scheduled_for]).to be_empty
  end

  it 'não permite agendar para o passado' do
    order = Order.new(customer: customer, scheduled_for: 1.day.ago)
    order.valid?
    expect(order.errors[:scheduled_for]).to include('não pode ser no passado')
  end

  it 'permite salvar sem agendamento' do
    order = Order.new(customer: customer)
    order.valid?
    expect(order.errors[:scheduled_for]).to be_empty
  end
end 