#!/usr/bin/env ruby

puts "🔧 Corrigindo problemas do frontend..."

# 1. Criar um pedido com status ag_aprovacao para testar botões de aprovação
puts "📋 Criando pedido para teste de aprovação..."

require_relative 'config/environment'

begin
  customer = Customer.first
  product = Product.first
  
  if customer && product
    order = Order.new(
      customer: customer,
      status: 'ag_aprovacao',
      scheduled_for: 2.hours.from_now,
      description: 'Pedido para teste de aprovação - Frontend'
    )
    
    order.order_items.build(
      product: product,
      quantity: 1,
      price: product.price
    )
    
    if order.save
      puts "✅ Pedido de teste criado com ID: #{order.id}"
    else
      puts "❌ Erro ao criar pedido: #{order.errors.full_messages.join(', ')}"
    end
  else
    puts "❌ Customer ou Product não encontrados"
  end
rescue => e
  puts "❌ Erro: #{e.message}"
end

puts "✅ Script de correção finalizado!" 