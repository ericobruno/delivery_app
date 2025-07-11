#!/usr/bin/env ruby

puts "=== TESTE DE ROTAS DE AGENDAMENTO ==="
puts "Data: #{Time.now}"
puts ""

# Verificar se o arquivo de rotas existe
routes_file = "config/routes.rb"
if File.exist?(routes_file)
  puts "✓ Arquivo de rotas encontrado: #{routes_file}"
  
  # Ler o conteúdo do arquivo
  content = File.read(routes_file)
  
  # Verificar se as rotas de agendamento estão definidas
  if content.include?("scheduling")
    puts "✓ Rotas de agendamento encontradas no arquivo"
    
    # Extrair linhas relacionadas ao scheduling
    scheduling_lines = content.split("\n").select { |line| line.include?("scheduling") }
    puts "\nLinhas relacionadas ao scheduling:"
    scheduling_lines.each_with_index do |line, index|
      puts "  #{index + 1}. #{line.strip}"
    end
  else
    puts "✗ Rotas de agendamento NÃO encontradas no arquivo"
  end
else
  puts "✗ Arquivo de rotas não encontrado: #{routes_file}"
end

puts ""

# Verificar se o controller existe
controller_file = "app/controllers/admin/scheduling_controller.rb"
if File.exist?(controller_file)
  puts "✓ Controller de agendamento encontrado: #{controller_file}"
  
  # Verificar se o controller tem os métodos necessários
  controller_content = File.read(controller_file)
  methods = ["index", "update_configuration", "update_availability", "move_orders_to_production"]
  
  methods.each do |method|
    if controller_content.include?("def #{method}")
      puts "  ✓ Método '#{method}' encontrado"
    else
      puts "  ✗ Método '#{method}' NÃO encontrado"
    end
  end
else
  puts "✗ Controller de agendamento não encontrado: #{controller_file}"
end

puts ""
puts "=== ROTAS ESPERADAS ==="
puts "GET    /admin/scheduling                           -> Admin::SchedulingController#index"
puts "PATCH  /admin/scheduling/configuration            -> Admin::SchedulingController#update_configuration"
puts "PATCH  /admin/scheduling/availability             -> Admin::SchedulingController#update_availability"
puts "POST   /admin/scheduling/move_orders_to_production -> Admin::SchedulingController#move_orders_to_production"
puts ""
puts "=== INSTRUÇÕES ==="
puts "1. Reinicie o servidor Rails se estiver rodando"
puts "2. Acesse: http://localhost:3000/admin/scheduling"
puts "3. Se ainda não funcionar, verifique se há erros no log do servidor"
puts "4. Teste também: http://localhost:3000/admin/test"