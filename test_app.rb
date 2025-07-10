#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

class DeliveryAppTester
  BASE_URL = 'http://localhost:3001'
  
  def initialize
    @cookies = {}
    @csrf_token = nil
    @issues = []
    puts "🧪 Iniciando teste sistemático do DeliveryApp"
    puts "=" * 50
  end

  def run_all_tests
    login_test
    dashboard_test
    categories_test
    products_test
    customers_test
    orders_test
    print_issues_summary
  end

  private

  def login_test
    puts "\n📝 Testando autenticação..."
    
    # Tentar acessar a página de login
    response = make_request('GET', '/users/sign_in')
    if response.code == '200'
      puts "✅ Página de login acessível"
      extract_csrf_token(response.body)
    else
      add_issue("Login", "Página de login retornou código #{response.code}")
      return false
    end

    # Tentar fazer login
    login_data = {
      'user[email]' => 'admin@example.com',
      'user[password]' => 'password123',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/users/sign_in', login_data)
    if response.code == '302' && response['location']&.include?('admin')
      puts "✅ Login realizado com sucesso"
      return true
    else
      add_issue("Login", "Falha no login - código: #{response.code}")
      return false
    end
  end

  def dashboard_test
    puts "\n📊 Testando Dashboard..."
    
    response = make_request('GET', '/admin')
    if response.code == '200'
      puts "✅ Dashboard acessível"
      test_toggle_aceite_automatico
    else
      add_issue("Dashboard", "Dashboard retornou código #{response.code}")
    end
  end

  def test_toggle_aceite_automatico
    puts "  🔄 Testando toggle aceite automático..."
    
    response = make_request('PATCH', '/admin/dashboard/toggle_aceite_automatico', {'status' => 'on'})
    if [200, 302].include?(response.code.to_i)
      puts "  ✅ Toggle aceite automático funcionando"
    else
      add_issue("Dashboard", "Toggle aceite automático falhou - código: #{response.code}")
    end
  end

  def categories_test
    puts "\n📂 Testando Categorias..."
    
    # Listar categorias
    response = make_request('GET', '/admin/categories')
    if response.code == '200'
      puts "✅ Listagem de categorias OK"
    else
      add_issue("Categorias", "Listagem falhou - código: #{response.code}")
    end

    # Criar nova categoria
    get_csrf_from_new_form('/admin/categories/new')
    category_data = {
      'category[name]' => 'Categoria Teste',
      'category[description]' => 'Descrição da categoria teste',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/admin/categories', category_data)
    if [200, 201, 302].include?(response.code.to_i)
      puts "✅ Criação de categoria OK"
      @test_category_id = extract_id_from_location(response['location'])
    else
      add_issue("Categorias", "Criação falhou - código: #{response.code}")
    end

    # Testar outras operações se a categoria foi criada
    if @test_category_id
      test_category_operations(@test_category_id)
    end
  end

  def test_category_operations(id)
    # Visualizar categoria
    response = make_request('GET', "/admin/categories/#{id}")
    if response.code == '200'
      puts "✅ Visualização de categoria OK"
    else
      add_issue("Categorias", "Visualização falhou - código: #{response.code}")
    end

    # Editar categoria
    get_csrf_from_new_form("/admin/categories/#{id}/edit")
    update_data = {
      'category[name]' => 'Categoria Teste Editada',
      'authenticity_token' => @csrf_token,
      '_method' => 'patch'
    }

    response = make_request('PATCH', "/admin/categories/#{id}", update_data)
    if [200, 302].include?(response.code.to_i)
      puts "✅ Edição de categoria OK"
    else
      add_issue("Categorias", "Edição falhou - código: #{response.code}")
    end

    # Deletar categoria
    delete_data = {
      'authenticity_token' => @csrf_token,
      '_method' => 'delete'
    }

    response = make_request('DELETE', "/admin/categories/#{id}", delete_data)
    if [200, 302].include?(response.code.to_i)
      puts "✅ Exclusão de categoria OK"
    else
      add_issue("Categorias", "Exclusão falhou - código: #{response.code}")
    end
  end

  def products_test
    puts "\n📦 Testando Produtos..."
    
    # Listar produtos
    response = make_request('GET', '/admin/products')
    if response.code == '200'
      puts "✅ Listagem de produtos OK"
    else
      add_issue("Produtos", "Listagem falhou - código: #{response.code}")
    end

    # Criar produto (precisa de categoria)
    create_test_category_for_product
    if @product_category_id
      test_product_creation
    end
  end

  def create_test_category_for_product
    get_csrf_from_new_form('/admin/categories/new')
    category_data = {
      'category[name]' => 'Categoria para Produto',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/admin/categories', category_data)
    @product_category_id = extract_id_from_location(response['location']) if response.code == '302'
  end

  def test_product_creation
    get_csrf_from_new_form('/admin/products/new')
    product_data = {
      'product[name]' => 'Produto Teste',
      'product[description]' => 'Descrição do produto teste',
      'product[price]' => '10.50',
      'product[category_id]' => @product_category_id,
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/admin/products', product_data)
    if [200, 201, 302].include?(response.code.to_i)
      puts "✅ Criação de produto OK"
      @test_product_id = extract_id_from_location(response['location'])
      test_product_operations(@test_product_id) if @test_product_id
    else
      add_issue("Produtos", "Criação falhou - código: #{response.code}")
    end
  end

  def test_product_operations(id)
    # Testar confirm_destroy (modal)
    response = make_request('GET', "/admin/products/#{id}/confirm_destroy")
    if response.code == '200'
      puts "✅ Modal de confirmação de produto OK"
    else
      add_issue("Produtos", "Modal de confirmação falhou - código: #{response.code}")
    end

    # Testar exclusão
    delete_data = {
      'authenticity_token' => @csrf_token,
      '_method' => 'delete'
    }

    response = make_request('DELETE', "/admin/products/#{id}", delete_data)
    if [200, 302].include?(response.code.to_i)
      puts "✅ Exclusão de produto OK"
    else
      add_issue("Produtos", "Exclusão falhou - código: #{response.code}")
    end
  end

  def customers_test
    puts "\n👥 Testando Clientes..."
    
    response = make_request('GET', '/admin/customers')
    if response.code == '200'
      puts "✅ Listagem de clientes OK"
    else
      add_issue("Clientes", "Listagem falhou - código: #{response.code}")
    end

    # Criar cliente
    get_csrf_from_new_form('/admin/customers/new')
    customer_data = {
      'customer[name]' => 'Cliente Teste',
      'customer[phone]' => '(11) 99999-9999',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/admin/customers', customer_data)
    if [200, 201, 302].include?(response.code.to_i)
      puts "✅ Criação de cliente OK"
      @test_customer_id = extract_id_from_location(response['location'])
    else
      add_issue("Clientes", "Criação falhou - código: #{response.code}")
    end
  end

  def orders_test
    puts "\n📋 Testando Pedidos..."
    
    response = make_request('GET', '/admin/orders')
    if response.code == '200'
      puts "✅ Listagem de pedidos OK"
    else
      add_issue("Pedidos", "Listagem falhou - código: #{response.code}")
    end

    # Para testar criação de pedidos, precisamos de cliente e produto
    if @test_customer_id && @test_product_id
      test_order_creation
    else
      puts "⚠️  Pulando teste de criação de pedido (faltam cliente/produto)"
    end
  end

  def test_order_creation
    get_csrf_from_new_form('/admin/orders/new')
    order_data = {
      'order[customer_id]' => @test_customer_id,
      'order[scheduled_for]' => (Time.now + 1.day).strftime('%Y-%m-%d %H:%M'),
      'order[order_items_attributes][0][product_id]' => @test_product_id,
      'order[order_items_attributes][0][quantity]' => '2',
      'order[order_items_attributes][0][price]' => '10.50',
      'authenticity_token' => @csrf_token
    }

    response = make_request('POST', '/admin/orders', order_data)
    if [200, 201, 302].include?(response.code.to_i)
      puts "✅ Criação de pedido OK"
      @test_order_id = extract_id_from_location(response['location'])
      test_order_operations(@test_order_id) if @test_order_id
    else
      add_issue("Pedidos", "Criação falhou - código: #{response.code}")
    end
  end

  def test_order_operations(id)
    # Testar accept
    accept_data = {
      'authenticity_token' => @csrf_token,
      '_method' => 'patch'
    }

    response = make_request('PATCH', "/admin/orders/#{id}/accept", accept_data)
    if [200, 302].include?(response.code.to_i)
      puts "✅ Aceitar pedido OK"
    else
      add_issue("Pedidos", "Aceitar pedido falhou - código: #{response.code}")
    end
  end

  # Métodos auxiliares
  def make_request(method, path, data = nil)
    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    
    case method.upcase
    when 'GET'
      request = Net::HTTP::Get.new(uri)
    when 'POST'
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(data) if data
    when 'PATCH'
      request = Net::HTTP::Patch.new(uri)
      request.set_form_data(data) if data
    when 'DELETE'
      request = Net::HTTP::Delete.new(uri)
      request.set_form_data(data) if data
    end

    request['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ') if @cookies.any?
    
    response = http.request(request)
    update_cookies(response)
    response
  rescue => e
    add_issue("Conexão", "Erro ao fazer requisição #{method} #{path}: #{e.message}")
    OpenStruct.new(code: '500', body: '', headers: {})
  end

  def update_cookies(response)
    return unless response['set-cookie']
    
    response.get_fields('set-cookie').each do |cookie|
      name, value = cookie.split('=', 2)
      @cookies[name] = value.split(';').first
    end
  end

  def extract_csrf_token(html)
    doc = Nokogiri::HTML(html)
    token = doc.at('meta[name="csrf-token"]')&.attr('content')
    @csrf_token = token if token
  end

  def get_csrf_from_new_form(path)
    response = make_request('GET', path)
    extract_csrf_token(response.body) if response.code == '200'
  end

  def extract_id_from_location(location)
    return nil unless location
    match = location.match(/\/(\d+)/)
    match[1] if match
  end

  def add_issue(section, description)
    @issues << "❌ #{section}: #{description}"
    puts "❌ #{section}: #{description}"
  end

  def print_issues_summary
    puts "\n" + "=" * 50
    puts "📋 RESUMO DOS TESTES"
    puts "=" * 50
    
    if @issues.empty?
      puts "🎉 Todos os testes passaram! A aplicação está funcionando corretamente."
    else
      puts "❌ Foram encontrados #{@issues.length} problema(s):"
      @issues.each_with_index do |issue, index|
        puts "#{index + 1}. #{issue}"
      end
    end
    puts "=" * 50
  end
end

# Executar os testes
tester = DeliveryAppTester.new
tester.run_all_tests 