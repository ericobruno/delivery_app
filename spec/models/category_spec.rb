require 'rails_helper'

RSpec.describe Category, type: :model do
  it { should have_many(:products) }

  it 'é válido com nome' do
    category = Category.new(name: 'Categoria')
    expect(category).to be_valid
  end

  it 'não é válido sem nome' do
    category = Category.new
    category.valid?
    expect(category.errors[:name]).not_to be_empty
  end
end 