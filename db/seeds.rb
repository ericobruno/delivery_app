# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clientes
customer1 = Customer.find_or_create_by!(name: 'Cliente Filtro 1', phone: '111111111')
customer2 = Customer.find_or_create_by!(name: 'Cliente Filtro 2', phone: '222222222')

# Produtos
category = Category.find_or_create_by!(name: 'Mock', description: 'Categoria mock')
product1 = Product.find_or_create_by!(name: 'Produto Filtro 1', price: 10.0, category: category)
product2 = Product.find_or_create_by!(name: 'Produto Filtro 2', price: 20.0, category: category)

# Datas variadas em 2025 (mais densidade entre jan e jul)
mock_dates = [
  Time.new(2025, 1, 10, 10, 0),
  Time.new(2025, 2, 5, 14, 30),
  Time.new(2025, 3, 15, 9, 0),
  Time.new(2025, 4, 20, 16, 0),
  Time.new(2025, 5, 10, 11, 45),
  Time.new(2025, 6, 1, 8, 0),
  Time.new(2025, 6, 15, 18, 0),
  Time.new(2025, 6, 25, 13, 0),
  Time.new(2025, 7, 1, 17, 0),
  Time.new(2025, 7, 4, 12, 0)
]

statuses = %w[novo agendado entregue cancelado]

Order.destroy_all
OrderItem.destroy_all

# Gera 10 datas futuras a partir de hoje
future_dates = Array.new(10) { |i| Time.zone.now.beginning_of_day + (i+1).days + (i*2).hours }

future_dates.each_with_index do |created_at, i|
  order = Order.create!(
    customer: i.even? ? customer1 : customer2,
    status: statuses[i % statuses.size],
    description: "Pedido mock futuro #{i+1} - #{created_at.strftime('%Y-%m-%d')}",
    scheduled_for: created_at + 2.hours,
    scheduled_notes: "Agendamento mock futuro #{i+1}",
    created_at: created_at,
    updated_at: created_at
  )
  OrderItem.create!(order: order, product: i.even? ? product1 : product2, quantity: 1 + i % 3, price: (i.even? ? 10.0 : 20.0))
end

puts 'Pedidos de mock FUTUROS criados para teste de filtro!'

# Adiciona 5 pedidos de cada status com created_at hoje e scheduled_for para HOJE, sempre no futuro
mock_created_at = Time.zone.now
statuses.each do |status|
  5.times do |i|
    scheduled_time = Time.zone.now + (i + 1).hours
    order = Order.create!(
      customer: customer1,
      status: status,
      description: "Pedido #{status} entrega hoje ##{i+1}",
      scheduled_for: scheduled_time,
      scheduled_notes: "Agendamento #{status} entrega hoje ##{i+1}",
      created_at: mock_created_at,
      updated_at: mock_created_at
    )
    OrderItem.create!(order: order, product: product1, quantity: 1, price: 10.0)
  end
end

puts 'Pedidos de mock criados com created_at e entrega para HOJE (sempre no futuro)!'

Setting.find_or_create_by!(key: 'aceite_automatico', value: 'off')
