namespace :kanban do
  desc "Criar dados de demonstração para o Kanban"
  task demo: :environment do
    puts "🎯 CRIANDO DADOS DE DEMONSTRAÇÃO PARA O KANBAN"
    puts "=" * 50
    
    # Limpar dados existentes (opcional)
    if Rails.env.development?
      puts "🧹 Limpando dados existentes..."
      Order.destroy_all
      OrderItem.destroy_all
      Customer.destroy_all
      Product.destroy_all
      Category.destroy_all
    end
    
    # Criar categorias
    puts "📦 Criando categorias..."
    categorias = [
      { name: "Pizzas", description: "Pizzas artesanais" },
      { name: "Bebidas", description: "Refrigerantes e sucos" },
      { name: "Sobremesas", description: "Doces e sobremesas" }
    ]
    
    categorias.each do |cat_data|
      Category.find_or_create_by!(cat_data)
    end
    
    # Criar produtos
    puts "🍕 Criando produtos..."
    produtos = [
      { name: "Pizza Margherita", price: 35.90, category: Category.find_by(name: "Pizzas") },
      { name: "Pizza Pepperoni", price: 42.90, category: Category.find_by(name: "Pizzas") },
      { name: "Pizza Portuguesa", price: 39.90, category: Category.find_by(name: "Pizzas") },
      { name: "Coca-Cola 2L", price: 8.90, category: Category.find_by(name: "Bebidas") },
      { name: "Guaraná Antarctica 2L", price: 7.90, category: Category.find_by(name: "Bebidas") },
      { name: "Brownie com Sorvete", price: 15.90, category: Category.find_by(name: "Sobremesas") },
      { name: "Pudim de Leite", price: 12.90, category: Category.find_by(name: "Sobremesas") }
    ]
    
    produtos.each do |prod_data|
      Product.find_or_create_by!(name: prod_data[:name]) do |product|
        product.price = prod_data[:price]
        product.category = prod_data[:category]
      end
    end
    
    # Criar clientes
    puts "👥 Criando clientes..."
    clientes = [
      { name: "João Silva", phone: "(11) 99999-1111" },
      { name: "Maria Santos", phone: "(11) 99999-2222" },
      { name: "Pedro Oliveira", phone: "(11) 99999-3333" },
      { name: "Ana Costa", phone: "(11) 99999-4444" },
      { name: "Carlos Ferreira", phone: "(11) 99999-5555" },
      { name: "Luciana Lima", phone: "(11) 99999-6666" }
    ]
    
    clientes.each do |cliente_data|
      Customer.find_or_create_by!(cliente_data)
    end
    
    # Criar pedidos para demonstrar o Kanban
    puts "📋 Criando pedidos para demonstração do Kanban..."
    
    customers = Customer.all
    products = Product.all
    statuses = ['novo', 'ag_aprovacao', 'producao', 'pronto', 'entregue', 'cancelado']
    
    # Criar 3-4 pedidos para cada status
    statuses.each_with_index do |status, index|
      puts "   📝 Criando pedidos para status: #{status}"
      
      rand(3..5).times do |i|
        customer = customers.sample
        scheduled_time = Time.current + (index * 2).hours + rand(0..120).minutes
        
        # Criar pedido com itens em uma transação
        order = nil
        Order.transaction do
          order = Order.new(
            customer: customer,
            status: status,
            description: "Pedido demo #{status} ##{i + 1}",
            scheduled_for: scheduled_time,
            scheduled_notes: case status
                            when 'novo' then "Pedido recém-chegado"
                            when 'ag_aprovacao' then "Aguardando confirmação"
                            when 'producao' then "Em preparação na cozinha"
                            when 'pronto' then "Saiu para entrega"
                            when 'entregue' then "Entregue com sucesso"
                            when 'cancelado' then "Cliente cancelou"
                            end,
            created_at: Time.current - rand(1..48).hours,
            updated_at: Time.current - rand(0..24).hours
          )
          
          # Adicionar itens aleatórios ao pedido
          rand(1..3).times do
            product = products.sample
            quantity = rand(1..2)
            
            order.order_items.build(
              product: product,
              quantity: quantity,
              price: product.price
            )
          end
          
          order.save!
        end
        
        puts "     ✅ Pedido ##{order.id} criado - Cliente: #{customer.name}"
      end
    end
    
    # Estatísticas finais
    puts "\n🎉 DADOS DE DEMONSTRAÇÃO CRIADOS COM SUCESSO!"
    puts "=" * 50
    puts "📊 ESTATÍSTICAS:"
    puts "   👥 Clientes: #{Customer.count}"
    puts "   📦 Categorias: #{Category.count}" 
    puts "   🍕 Produtos: #{Product.count}"
    puts "   📋 Pedidos: #{Order.count}"
    puts "   📝 Itens de Pedido: #{OrderItem.count}"
    puts ""
    puts "📈 PEDIDOS POR STATUS:"
    statuses.each do |status|
      count = Order.where(status: status).count
      puts "   #{status.ljust(15)}: #{count} pedidos"
    end
    
    puts "\n🚀 AGORA VOCÊ PODE:"
    puts "   1️⃣  Iniciar o servidor: rails server"
    puts "   2️⃣  Acessar: http://localhost:3000/admin"
    puts "   3️⃣  Testar o Kanban drag & drop!"
    puts "   4️⃣  Arrastar pedidos entre as colunas"
    puts ""
    puts "💡 DICA: Os pedidos foram criados com dados realistas"
    puts "   e horários variados para demonstrar o sistema!"
  end
  
  desc "Limpar dados de demonstração"
  task clean: :environment do
    puts "🧹 LIMPANDO DADOS DE DEMONSTRAÇÃO..."
    
    if Rails.env.development?
      Order.destroy_all
      OrderItem.destroy_all
      Customer.destroy_all
      Product.destroy_all
      Category.destroy_all
      
      puts "✅ Dados limpos com sucesso!"
    else
      puts "❌ Esta tarefa só pode ser executada em desenvolvimento!"
    end
  end
end 