# Script para criar pedidos de mock com produtos reais
# Execute com: rails runner db/create_mock_orders.rb

puts "Criando pedidos de mock com produtos reais..."

# Limpar pedidos existentes (opcional)
# Order.destroy_all
# OrderItem.destroy_all

# Buscar produtos reais da base
products = Product.all
customers = Customer.all

if products.empty?
  puts "❌ Nenhum produto encontrado na base. Execute primeiro o script de produtos!"
  exit
end

if customers.empty?
  puts "❌ Nenhum cliente encontrado na base. Crie alguns clientes primeiro!"
  exit
end

# Status possíveis
statuses = %w[novo ag_aprovacao em_preparacao pronto entregue cancelado]

# Criar pedidos de mock
total_orders = 0

# Pedidos para hoje e próximos dias
(0..7).each do |day_offset|
  scheduled_date = Date.current + day_offset.days
  
  # Criar 2-4 pedidos por dia
  rand(2..4).times do |order_index|
    customer = customers.sample
    status = statuses.sample
    scheduled_time = scheduled_date.to_time + rand(8..20).hours + rand(0..59).minutes
    
    order = Order.create!(
      customer: customer,
      status: status,
      description: "Pedido mock ##{total_orders + 1} - #{scheduled_date.strftime('%d/%m/%Y')}",
      scheduled_for: scheduled_time,
      scheduled_notes: "Agendamento mock - #{scheduled_time.strftime('%H:%M')}",
      created_at: scheduled_time - rand(1..24).hours,
      updated_at: scheduled_time - rand(1..24).hours
    )
    
    # Adicionar 1-3 itens por pedido
    rand(1..3).times do
      product = products.sample
      quantity = rand(1..3)
      price = product.price
      
      OrderItem.create!(
        order: order,
        product: product,
        quantity: quantity,
        price: price
      )
    end
    
    total_orders += 1
    puts "✓ Pedido ##{order.id} criado - Cliente: #{customer.name}, Status: #{status}, Data: #{scheduled_date.strftime('%d/%m')}"
  end
end

# Criar alguns pedidos com status específicos para demonstração
puts "\nCriando pedidos com status específicos..."

# Pedidos aguardando aprovação
3.times do |i|
  customer = customers.sample
  scheduled_time = Date.current.to_time + rand(1..7).days + rand(8..20).hours
  
  order = Order.create!(
    customer: customer,
    status: 'ag_aprovacao',
    description: "Pedido aguardando aprovação ##{i + 1}",
    scheduled_for: scheduled_time,
    scheduled_notes: "Aguardando aprovação - #{scheduled_time.strftime('%d/%m %H:%M')}"
  )
  
  # Adicionar produtos
  rand(1..2).times do
    product = products.sample
    OrderItem.create!(
      order: order,
      product: product,
      quantity: rand(1..2),
      price: product.price
    )
  end
  
  puts "✓ Pedido aguardando aprovação ##{order.id} criado"
end

# Pedidos em preparação
2.times do |i|
  customer = customers.sample
  scheduled_time = Date.current.to_time + rand(1..3).hours
  
  order = Order.create!(
    customer: customer,
    status: 'em_preparacao',
    description: "Pedido em preparação ##{i + 1}",
    scheduled_for: scheduled_time,
    scheduled_notes: "Em preparação - #{scheduled_time.strftime('%H:%M')}"
  )
  
  # Adicionar produtos
  rand(1..3).times do
    product = products.sample
    OrderItem.create!(
      order: order,
      product: product,
      quantity: rand(1..2),
      price: product.price
    )
  end
  
  puts "✓ Pedido em preparação ##{order.id} criado"
end

# Pedidos prontos para entrega
2.times do |i|
  customer = customers.sample
  scheduled_time = Date.current.to_time + rand(30..120).minutes
  
  order = Order.create!(
    customer: customer,
    status: 'pronto',
    description: "Pedido pronto ##{i + 1}",
    scheduled_for: scheduled_time,
    scheduled_notes: "Pronto para entrega - #{scheduled_time.strftime('%H:%M')}"
  )
  
  # Adicionar produtos
  rand(1..2).times do
    product = products.sample
    OrderItem.create!(
      order: order,
      product: product,
      quantity: rand(1..2),
      price: product.price
    )
  end
  
  puts "✓ Pedido pronto ##{order.id} criado"
end

puts "\n✅ Criação de pedidos concluída!"
puts "Total de pedidos criados: #{total_orders + 7}"
puts "Status distribuídos: #{Order.group(:status).count}" 