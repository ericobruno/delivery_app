require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should belong_to(:category).optional }
  it { should have_many(:order_items) }
  it { should respond_to(:name) }
  it { should respond_to(:price) }

  it 'é válido com nome e preço' do
    category = Category.create!(name: 'Teste')
    product = Product.new(name: 'Produto', price: 10.0, category: category)
    expect(product).to be_valid
  end

  it 'não é válido sem nome' do
    product = Product.new(price: 10.0)
    product.valid?
    expect(product.errors[:name]).not_to be_empty
  end

  it 'não é válido sem preço' do
    product = Product.new(name: 'Produto')
    product.valid?
    expect(product.errors[:price]).not_to be_empty
  end
end 