#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

puts "🔄 TESTE DO TOGGLE SWITCH - ACEITE AUTOMÁTICO"
puts "=" * 50

# Configurações
BASE_URL = "http://localhost:3000"
HEADERS = {
  'Content-Type' => 'application/x-www-form-urlencoded',
  'Accept' => 'application/json'
}

def make_request(method, path, data = nil)
  uri = URI("#{BASE_URL}#{path}")
  
  case method.upcase
  when 'GET'
    Net::HTTP.get_response(uri)
  when 'POST'
    Net::HTTP.post_form(uri, data || {})
  else
    raise "Método #{method} não suportado"
  end
end

def test_dashboard_access
  puts "\n📋 1. Testando acesso ao dashboard..."
  
  begin
    response = make_request('GET', '/admin/dashboard')
    
    if response.code == '200'
      puts "   ✅ Dashboard acessível"
      
      # Verificar se o toggle switch está presente
      if response.body.include?('aceite-automatico-container')
        puts "   ✅ Toggle switch encontrado no HTML"
      else
        puts "   ❌ Toggle switch NÃO encontrado no HTML"
      end
      
      if response.body.include?('form-switch-lg')
        puts "   ✅ Classes CSS do switch presentes"
      else
        puts "   ❌ Classes CSS do switch ausentes"
      end
      
    else
      puts "   ❌ Dashboard inacessível - Status: #{response.code}"
    end
    
  rescue => e
    puts "   ❌ Erro ao acessar dashboard: #{e.message}"
  end
end

def test_toggle_endpoint
  puts "\n🔄 2. Testando endpoint de toggle..."
  
  ['on', 'off'].each do |status|
    begin
      puts "   Testando status: #{status}"
      
      # Simular dados do formulário
      data = { 'status' => status }
      response = make_request('POST', '/admin/toggle_aceite_automatico', data)
      
      if response.code == '200'
        begin
          json_response = JSON.parse(response.body)
          
          if json_response['success']
            puts "   ✅ Toggle para '#{status}' funcionou"
            puts "      📊 Resposta: #{json_response['message']}"
          else
            puts "   ❌ Toggle falhou: #{json_response['message']}"
          end
          
        rescue JSON::ParserError
          puts "   ⚠️  Resposta não é JSON válido"
        end
      else
        puts "   ❌ Endpoint retornou status: #{response.code}"
      end
      
    rescue => e
      puts "   ❌ Erro no teste: #{e.message}"
    end
  end
end

def test_static_files
  puts "\n📁 3. Testando arquivos estáticos..."
  
  files_to_test = [
    '/assets/aceite_automatico.css',
    '/assets/application.js'
  ]
  
  files_to_test.each do |file|
    begin
      response = make_request('GET', file)
      
      if response.code == '200'
        puts "   ✅ #{file} - Carregado"
      else
        puts "   ❌ #{file} - Status: #{response.code}"
      end
      
    rescue => e
      puts "   ❌ #{file} - Erro: #{e.message}"
    end
  end
end

def test_controller_registration
  puts "\n🎮 4. Verificando registro do controller..."
  
  begin
    # Ler arquivo index.js
    index_path = File.join(Dir.pwd, 'app/javascript/controllers/index.js')
    
    if File.exist?(index_path)
      content = File.read(index_path)
      
      if content.include?('aceite-automatico')
        puts "   ✅ Controller registrado no index.js"
      else
        puts "   ❌ Controller NÃO registrado no index.js"
      end
      
      if content.include?('AceiteAutomaticoController')
        puts "   ✅ Import do controller presente"
      else
        puts "   ❌ Import do controller ausente"
      end
      
    else
      puts "   ❌ Arquivo index.js não encontrado"
    end
    
  rescue => e
    puts "   ❌ Erro ao verificar controller: #{e.message}"
  end
end

def test_css_files
  puts "\n🎨 5. Verificando arquivos CSS..."
  
  css_path = File.join(Dir.pwd, 'app/assets/stylesheets/aceite_automatico.css')
  
  if File.exist?(css_path)
    puts "   ✅ Arquivo CSS existe"
    
    content = File.read(css_path)
    
    required_classes = [
      '.aceite-automatico-container',
      '.form-switch-lg',
      '.toggle-switch',
      '.loading-overlay'
    ]
    
    required_classes.each do |css_class|
      if content.include?(css_class)
        puts "   ✅ Classe #{css_class} encontrada"
      else
        puts "   ❌ Classe #{css_class} ausente"
      end
    end
    
  else
    puts "   ❌ Arquivo CSS não encontrado"
  end
end

def run_all_tests
  puts "🚀 Iniciando testes do Toggle Switch..."
  puts "⏰ #{Time.now}"
  
  test_dashboard_access
  test_toggle_endpoint  
  test_static_files
  test_controller_registration
  test_css_files
  
  puts "\n" + "=" * 50
  puts "✅ TESTES CONCLUÍDOS"
  puts "📝 Verifique os resultados acima"
  puts "🌐 Abra http://localhost:3000/admin/dashboard para testar manualmente"
end

# Executar testes se o script for chamado diretamente
if __FILE__ == $0
  run_all_tests
end