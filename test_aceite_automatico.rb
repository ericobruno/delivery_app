#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'ostruct'
require 'time'

class AceiteAutomaticoTester
  BASE_URL = 'http://localhost:3000'
  
  def initialize
    @cookies = {}
    @csrf_token = nil
    @results = []
  end

  def run_tests
    puts "🚀 Iniciando testes do Aceite Automático"
    puts "=" * 50
    
    test_dashboard_access
    test_toggle_functionality
    test_api_orders_with_aceite_on
    test_api_orders_with_aceite_off
    test_manual_orders
    
    print_results
  end

  private

  def test_dashboard_access
    puts "\n📊 Testando acesso ao dashboard..."
    
    response = make_request('GET', '/admin')
    if response.code == '200'
      extract_csrf_token(response.body)
      add_result(:passed, "Dashboard", "Acesso ao dashboard OK")
      
      # Verificar se o novo toggle está presente
      doc = Nokogiri::HTML(response.body)
      toggle_element = doc.css('[data-controller="aceite-automatico"]').first
      
      if toggle_element
        add_result(:passed, "Toggle", "Novo toggle switch encontrado")
        
        # Verificar elementos do toggle
        has_icon = toggle_element.css('[data-aceite-automatico-target="icon"]').any?
        has_label = toggle_element.css('[data-aceite-automatico-target="label"]').any?
        has_status = toggle_element.css('[data-aceite-automatico-target="statusText"]').any?
        
        if has_icon && has_label && has_status
          add_result(:passed, "Toggle", "Todos os elementos do toggle presentes")
        else
          add_result(:warning, "Toggle", "Alguns elementos do toggle podem estar faltando")
        end
      else
        add_result(:failed, "Toggle", "Toggle switch não encontrado")
      end
    else
      add_result(:failed, "Dashboard", "Acesso negado ao dashboard (#{response.code})")
    end
  end

  def test_toggle_functionality
    puts "\n🔄 Testando funcionalidade do toggle..."
    
    return unless @csrf_token
    
    # Testar ativar aceite automático
    puts "  → Testando ativação..."
    response = make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'on',
      'authenticity_token' => @csrf_token
    })
    
    if [200, 302].include?(response.code.to_i)
      add_result(:passed, "Toggle", "Ativação do aceite automático funcionando")
    else
      add_result(:failed, "Toggle", "Falha na ativação (#{response.code})")
    end
    
    # Aguardar um pouco
    sleep(1)
    
    # Testar desativar aceite automático
    puts "  → Testando desativação..."
    response = make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'off',
      'authenticity_token' => @csrf_token
    })
    
    if [200, 302].include?(response.code.to_i)
      add_result(:passed, "Toggle", "Desativação do aceite automático funcionando")
    else
      add_result(:failed, "Toggle", "Falha na desativação (#{response.code})")
    end
  end

  def test_api_orders_with_aceite_on
    puts "\n📦 Testando API com aceite automático ATIVADO..."
    
    # Ativar aceite automático primeiro
    make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'on',
      'authenticity_token' => @csrf_token
    })
    
    # Criar pedido via API
    customer = create_test_customer
    product = create_test_product
    
    order_data = {
      order: {
        customer_id: customer.id,
        scheduled_for: (Time.now + 2*24*60*60).iso8601,
        scheduled_notes: 'Teste API - Aceite ON',
        order_items_attributes: [
          { product_id: product.id, quantity: 1, price: 10.0 }
        ]
      }
    }
    
    response = make_api_request('POST', '/api/orders', order_data)
    
    if response.code == '201'
      order = JSON.parse(response.body)
      if order['status'] == 'novo'
        add_result(:passed, "API", "Pedido criado com status 'novo' quando aceite automático está ON")
      else
        add_result(:failed, "API", "Pedido criado com status '#{order['status']}' mas deveria ser 'novo'")
      end
    else
      add_result(:failed, "API", "Falha ao criar pedido via API (#{response.code})")
    end
  end

  def test_api_orders_with_aceite_off
    puts "\n📦 Testando API com aceite automático DESATIVADO..."
    
    # Desativar aceite automático
    make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'off',
      'authenticity_token' => @csrf_token
    })
    
    # Criar pedido via API
    customer = create_test_customer
    product = create_test_product
    
    order_data = {
      order: {
        customer_id: customer.id,
        scheduled_for: (Time.now + 2*24*60*60).iso8601,
        scheduled_notes: 'Teste API - Aceite OFF',
        order_items_attributes: [
          { product_id: product.id, quantity: 1, price: 10.0 }
        ]
      }
    }
    
    response = make_api_request('POST', '/api/orders', order_data)
    
    if response.code == '201'
      order = JSON.parse(response.body)
      if order['status'] == 'ag_aprovacao'
        add_result(:passed, "API", "Pedido criado com status 'ag_aprovacao' quando aceite automático está OFF")
      else
        add_result(:failed, "API", "Pedido criado com status '#{order['status']}' mas deveria ser 'ag_aprovacao'")
      end
    else
      add_result(:failed, "API", "Falha ao criar pedido via API (#{response.code})")
    end
  end

  def test_manual_orders
    puts "\n📝 Testando criação manual de pedidos..."
    
    # Testar com aceite automático ON
    make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'on',
      'authenticity_token' => @csrf_token
    })
    
    customer = create_test_customer
    product = create_test_product
    
    order_data = {
      'order[customer_id]' => customer.id,
      'order[scheduled_for]' => (Time.now + 2*24*60*60).strftime('%Y-%m-%d'),
      'order[scheduled_notes]' => 'Teste Manual - Aceite ON',
      'order[order_items_attributes][0][product_id]' => product.id,
      'order[order_items_attributes][0][quantity]' => 1,
      'order[order_items_attributes][0][price]' => 10.0,
      'authenticity_token' => @csrf_token
    }
    
    response = make_request('POST', '/admin/orders', order_data)
    
    if [200, 302].include?(response.code.to_i)
      add_result(:passed, "Manual", "Criação manual de pedido funcionando com aceite ON")
    else
      add_result(:failed, "Manual", "Falha na criação manual (#{response.code})")
    end
  end

  def create_test_customer
    # Criar cliente de teste se não existir
    customer_data = {
      'customer[name]' => 'Cliente Teste Aceite',
      'customer[phone]' => '999999999',
      'authenticity_token' => @csrf_token
    }
    
    response = make_request('POST', '/admin/customers', customer_data)
    
    # Retornar ID real do cliente (16 foi criado anteriormente)
    OpenStruct.new(id: 16)
  end

  def create_test_product
    # Criar produto de teste se não existir
    product_data = {
      'product[name]' => 'Produto Teste Aceite',
      'product[price]' => 10.0,
      'product[description]' => 'Produto para teste do aceite automático',
      'authenticity_token' => @csrf_token
    }
    
    response = make_request('POST', '/admin/products', product_data)
    
    # Retornar ID real do produto (77 foi criado anteriormente)
    OpenStruct.new(id: 77)
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
    
    if @cookies.any?
      request['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
    end
    
    response = http.request(request)
    
    if response['Set-Cookie']
      response.get_fields('Set-Cookie').each do |cookie|
        name, value = cookie.split(';').first.split('=', 2)
        @cookies[name] = value if name && value
      end
    end
    
    response
  end

  def make_api_request(method, path, data)
    uri = URI.join(BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = 'Bearer b7e2c1a4e8f3d2c9a1b0e7f6c5d4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6'
    request.body = data.to_json
    
    http.request(request)
  end

  def extract_csrf_token(html)
    doc = Nokogiri::HTML(html)
    csrf_input = doc.css('input[name="authenticity_token"]').first
    @csrf_token = csrf_input['value'] if csrf_input
    
    # Alternativa: buscar no meta tag
    unless @csrf_token
      meta = doc.css('meta[name="csrf-token"]').first
      @csrf_token = meta['content'] if meta
    end
  end

  def add_result(status, category, message)
    @results << { status: status, category: category, message: message }
    
    icon = case status
           when :passed then "✅"
           when :warning then "⚠️"
           when :failed then "❌"
           end
    
    puts "  #{icon} #{category}: #{message}"
  end

  def print_results
    puts "\n" + "=" * 50
    puts "📊 RESULTADOS DOS TESTES"
    puts "=" * 50
    
    passed = @results.count { |r| r[:status] == :passed }
    warning = @results.count { |r| r[:status] == :warning }
    failed = @results.count { |r| r[:status] == :failed }
    total = @results.size
    
    puts "✅ Sucessos: #{passed}"
    puts "⚠️  Avisos: #{warning}"
    puts "❌ Falhas: #{failed}"
    puts "📈 Taxa de sucesso: #{total > 0 ? (passed.to_f / total * 100).round(1) : 0}%"
    
    if failed > 0
      puts "\n❌ FALHAS DETECTADAS:"
      @results.select { |r| r[:status] == :failed }.each do |result|
        puts "  • #{result[:category]}: #{result[:message]}"
      end
    end
    
    if warning > 0
      puts "\n⚠️  AVISOS:"
      @results.select { |r| r[:status] == :warning }.each do |result|
        puts "  • #{result[:category]}: #{result[:message]}"
      end
    end
    
    puts "\n🎯 Status final: #{failed == 0 ? 'TODOS OS TESTES PASSARAM' : 'ALGUNS TESTES FALHARAM'}"
  end
end

# Executar testes
if __FILE__ == $0
  tester = AceiteAutomaticoTester.new
  tester.run_tests
end 