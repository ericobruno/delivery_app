#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

class ToggleTester
  BASE_URL = 'http://localhost:3000'
  
  def initialize
    @cookies = {}
    @csrf_token = nil
  end

  def test_toggle
    puts "🧪 Testando toggle manual..."
    
    # Obter CSRF token
    response = make_request('GET', '/admin')
    if response.code == '200'
      extract_csrf_token(response.body)
      puts "✅ CSRF token obtido: #{@csrf_token[0..20]}..."
    else
      puts "❌ Falha ao obter dashboard"
      return
    end
    
    # Testar toggle ON
    puts "\n🔄 Testando toggle ON..."
    response = make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'on',
      'authenticity_token' => @csrf_token
    }, { 'Accept' => 'application/json' })
    
    puts "📡 Status: #{response.code}"
    puts "📡 Body: #{response.body}"
    
    # Testar toggle OFF
    puts "\n🔄 Testando toggle OFF..."
    response = make_request('POST', '/admin/toggle_aceite_automatico', {
      'status' => 'off',
      'authenticity_token' => @csrf_token
    }, { 'Accept' => 'application/json' })
    
    puts "📡 Status: #{response.code}"
    puts "📡 Body: #{response.body}"
  end

  private

  def make_request(method, path, data = nil, extra_headers = {})
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
    
    # Adicionar headers extras
    extra_headers.each { |key, value| request[key] = value }
    
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

  def extract_csrf_token(html)
    doc = Nokogiri::HTML(html)
    csrf_input = doc.css('input[name="authenticity_token"]').first
    @csrf_token = csrf_input['value'] if csrf_input
    
    unless @csrf_token
      meta = doc.css('meta[name="csrf-token"]').first
      @csrf_token = meta['content'] if meta
    end
  end
end

if __FILE__ == $0
  tester = ToggleTester.new
  tester.test_toggle
end 