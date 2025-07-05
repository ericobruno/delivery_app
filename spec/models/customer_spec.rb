require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should have_many(:orders) }

  it 'é válido com nome e telefone' do
    customer = Customer.new(name: 'Cliente', phone: '123456789')
    expect(customer).to be_valid
  end

  it 'não é válido sem nome' do
    customer = Customer.new(phone: '123456789')
    customer.valid?
    expect(customer.errors[:name]).not_to be_empty
  end

  it 'não é válido sem telefone' do
    customer = Customer.new(name: 'Cliente')
    customer.valid?
    expect(customer.errors[:phone]).not_to be_empty
  end
end 