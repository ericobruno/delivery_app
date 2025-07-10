#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

class FrontendTester
  BASE_URL = 'http://localhost:3001'
  
  def initialize
    @cookies = {}
    @csrf_token = nil
    @results = {
      passed: [],
      failed: [],
      warning: []
    }
    puts "🧪 TESTE COMPLETO DO FRONTEND - DELIVERY APP"
    puts "=" * 60
  end

  def run_all_tests
    puts "🔍 Iniciando bateria completa de testes..."
    
    # 1. Teste de conectividade
    test_server_connectivity
    
    # 2. Teste de autenticação
    test_authentication_flow
    
    # 3. Testes de funcionalidade
    test_dashboard_functionality
    test_order_buttons
    test_product_buttons
    test_modal_functionality
    test_aceite_automatico
    
    # 4. Relatório final
    generate_report
  end

  private

  def test_server_connectivity
    puts "\n🌐 Testando conectividade do servidor..."
    
    begin
      response = make_request('GET', '/')
      if response.code.to_i.between?(200, 399)
        add_result(:passed, "Servidor", "Conectividade OK (#{response.code})")
      else
        add_result(:failed, "Servidor", "Código inesperado: #{response.code}")
      end
    rescue => e
      add_result(:failed, "Servidor", "Erro de conexão: #{e.message}")
    end
  end

  def test_authentication_flow
    puts "\n🔐 Testando fluxo de autenticação..."
    
    # Acessar página de login
    response = make_request('GET', '/users/sign_in')
    if response.code == '200'
      add_result(:passed, "Auth", "Página de login acessível")
      extract_csrf_token(response.body)
    else
      add_result(:failed, "Auth", "Página de login indisponível")
      return false
    end

    # Tentar fazer login
    login_data = {
      'user[email]' => 'admin@example.com',
      'user[password]' => 'password123',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/users/sign_in', login_data)
    if response.code == '302'
      add_result(:passed, "Auth", "Login realizado com sucesso")
      return true
    else
      add_result(:warning, "Auth", "Login falhou - usuário pode não existir")
      # Tentar criar usuário
      attempt_user_creation
      return false
    end
  end

  def attempt_user_creation
    puts "🔧 Tentando criar usuário de teste..."
    
    response = make_request('GET', '/users/sign_up')
    if response.code == '200'
      extract_csrf_token(response.body)
      
      signup_data = {
        'user[name]' => 'Admin User',
        'user[email]' => 'admin@example.com',
        'user[password]' => 'password123',
        'user[password_confirmation]' => 'password123',
        'authenticity_token' => @csrf_token
      }

      response = make_request('POST', '/users', signup_data)
      if response.code == '302'
        add_result(:passed, "Auth", "Usuário criado com sucesso")
      else
        add_result(:failed, "Auth", "Falha na criação do usuário")
      end
    end
  end

  def test_dashboard_functionality
    puts "\n📊 Testando funcionalidades do dashboard..."
    
    response = make_request('GET', '/admin')
    if response.code == '200'
      add_result(:passed, "Dashboard", "Acesso ao dashboard OK")
      
      # Verificar se elementos essenciais estão presentes
      doc = Nokogiri::HTML(response.body)
      
      # Verificar botão de aceite automático
      aceite_button = doc.css('[data-controller="aceite-automatico"]').first
      if aceite_button
        add_result(:passed, "Dashboard", "Botão aceite automático encontrado")
      else
        add_result(:warning, "Dashboard", "Botão aceite automático não encontrado")
      end
      
      # Verificar se Stimulus está carregado
      if response.body.include?('stimulus')
        add_result(:passed, "Dashboard", "Stimulus detectado")
      else
        add_result(:warning, "Dashboard", "Stimulus não detectado")
      end
      
    else
      add_result(:failed, "Dashboard", "Acesso negado ao dashboard")
    end
  end

  def test_order_buttons
    puts "\n📋 Testando botões de pedidos..."
    
    response = make_request('GET', '/admin/orders')
    if response.code == '200'
      add_result(:passed, "Orders", "Listagem de pedidos acessível")
      
      doc = Nokogiri::HTML(response.body)
      
      # Verificar botões de aprovação
      approve_buttons = doc.css('[data-controller="order-actions"]')
      if approve_buttons.any?
        add_result(:passed, "Orders", "Botões de aprovação encontrados (#{approve_buttons.count})")
      else
        add_result(:warning, "Orders", "Botões de aprovação não encontrados")
      end
      
      # Verificar botões de delete
      delete_buttons = doc.css('a[href*="confirm_destroy"]')
      if delete_buttons.any?
        add_result(:passed, "Orders", "Botões de delete encontrados (#{delete_buttons.count})")
      else
        add_result(:warning, "Orders", "Botões de delete não encontrados")
      end
      
    else
      add_result(:failed, "Orders", "Acesso negado à listagem de pedidos")
    end
  end

  def test_product_buttons
    puts "\n🛍️ Testando botões de produtos..."
    
    response = make_request('GET', '/admin/products')
    if response.code == '200'
      add_result(:passed, "Products", "Listagem de produtos acessível")
      
      doc = Nokogiri::HTML(response.body)
      
      # Verificar botões de delete
      delete_buttons = doc.css('a[href*="confirm_destroy"]')
      if delete_buttons.any?
        add_result(:passed, "Products", "Botões de delete encontrados (#{delete_buttons.count})")
      else
        add_result(:warning, "Products", "Botões de delete não encontrados")
      end
      
    else
      add_result(:failed, "Products", "Acesso negado à listagem de produtos")
    end
  end

  def test_modal_functionality
    puts "\n🎭 Testando funcionalidade de modais..."
    
    # Testar um modal de confirmação se houver produtos
    response = make_request('GET', '/admin/products')
    if response.code == '200'
      doc = Nokogiri::HTML(response.body)
      
      delete_link = doc.css('a[href*="confirm_destroy"]').first
      if delete_link
        confirm_url = delete_link['href']
        
        # Testar carregamento do modal
        modal_response = make_request('GET', confirm_url)
        if modal_response.code == '200'
          add_result(:passed, "Modal", "Modal de confirmação carrega corretamente")
          
          modal_doc = Nokogiri::HTML(modal_response.body)
          
          # Verificar controller do modal
          modal_element = modal_doc.css('[data-controller="modal"]').first
          if modal_element
            add_result(:passed, "Modal", "Controller Stimulus do modal presente")
          else
            add_result(:warning, "Modal", "Controller Stimulus do modal ausente")
          end
          
          # Verificar ação de fechar por background
          close_action = modal_doc.css('[data-action*="modal#closeBackground"]').first
          if close_action
            add_result(:passed, "Modal", "Ação de fechar por background presente")
          else
            add_result(:warning, "Modal", "Ação de fechar por background ausente")
          end
          
        else
          add_result(:failed, "Modal", "Modal não carrega corretamente")
        end
      else
        add_result(:warning, "Modal", "Nenhum link para testar modal encontrado")
      end
    end
  end

  def test_aceite_automatico
    puts "\n⚡ Testando aceite automático..."
    
    # Obter CSRF token para a requisição
    response = make_request('GET', '/admin')
    if response.code == '200'
      extract_csrf_token(response.body)
      
      # Testar toggle do aceite automático
      toggle_data = {
        'status' => 'on',
        'authenticity_token' => @csrf_token
      }
      
      toggle_response = make_request('POST', '/admin/toggle_aceite_automatico', toggle_data)
      if [200, 302].include?(toggle_response.code.to_i)
        add_result(:passed, "AceiteAuto", "Toggle aceite automático funcionando")
      else
        add_result(:warning, "AceiteAuto", "Toggle pode não estar funcionando (#{toggle_response.code})")
      end
    end
  end

  def make_request(method, path, data = nil)
    uri = URI.join(BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = case method.upcase
              when 'GET'
                Net::HTTP::Get.new(uri)
              when 'POST'
                req = Net::HTTP::Post.new(uri)
                if data
                  req.set_form_data(data)
                end
                req
              end
    
    # Adicionar cookies se existirem
    if @cookies.any?
      request['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
    end
    
    response = http.request(request)
    
    # Armazenar cookies da resposta
    if response['Set-Cookie']
      response.get_fields('Set-Cookie').each do |cookie|
        name, value = cookie.split(';').first.split('=', 2)
        @cookies[name] = value if name && value
      end
    end
    
    response
  end

  def extract_csrf_token(html)
    doc = Nokogiri::HTML(html)
    csrf_input = doc.css('input[name="authenticity_token"]').first
    @csrf_token = csrf_input['value'] if csrf_input
  end

  def add_result(type, category, message)
    @results[type] << "#{category}: #{message}"
    
    icon = case type
           when :passed then "✅"
           when :failed then "❌"
           when :warning then "⚠️"
           end
    
    puts "  #{icon} #{category}: #{message}"
  end

  def generate_report
    puts "\n" + "=" * 60
    puts "📋 RELATÓRIO FINAL DO TESTE"
    puts "=" * 60
    
    puts "\n✅ SUCESSOS (#{@results[:passed].count}):"
    @results[:passed].each { |result| puts "  • #{result}" }
    
    puts "\n⚠️  AVISOS (#{@results[:warning].count}):"
    @results[:warning].each { |result| puts "  • #{result}" }
    
    puts "\n❌ FALHAS (#{@results[:failed].count}):"
    @results[:failed].each { |result| puts "  • #{result}" }
    
    total = @results.values.flatten.count
    success_rate = (@results[:passed].count.to_f / total * 100).round(1)
    
    puts "\n📊 RESUMO:"
    puts "  Total de testes: #{total}"
    puts "  Taxa de sucesso: #{success_rate}%"
    
    if @results[:failed].empty?
      puts "\n🎉 TODOS OS TESTES CRÍTICOS PASSARAM!"
    else
      puts "\n🔧 EXISTEM PROBLEMAS QUE PRECISAM SER CORRIGIDOS"
    end
    
    puts "=" * 60
  end
end

# Executar os testes
if __FILE__ == $0
  tester = FrontendTester.new
  tester.run_all_tests
end 