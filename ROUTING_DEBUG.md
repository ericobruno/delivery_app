# Guia de Debug para Rotas de Agendamento

## Problema Identificado
As rotas de agendamento (`/admin/scheduling`) não estão sendo reconhecidas pelo Rails, retornando erro "No route matches".

## Status Atual
- ✅ Dashboard `/admin/` funciona corretamente
- ❌ Rota de teste `/admin/test` não funciona
- ❌ Rota de agendamento `/admin/scheduling` não funciona

## Arquivos Verificados

### 1. Routes File (`config/routes.rb`)
```ruby
Rails.application.routes.draw do
  devise_for :users
  
  namespace :admin do
    root to: 'dashboard#index'
    post 'toggle_aceite_automatico', to: 'dashboard#toggle_aceite_automatico', as: :toggle_aceite_automatico
    get 'test', to: 'dashboard#index'  # Rota de teste simples
    
    # Configurações de agendamento
    get 'scheduling', to: 'scheduling#index'
    patch 'scheduling/configuration', to: 'scheduling#update_configuration'
    patch 'scheduling/availability', to: 'scheduling#update_availability'
    post 'scheduling/move_orders_to_production', to: 'scheduling#move_orders_to_production'
    get 'test-scheduling', to: 'scheduling#index'
    
    # ... outros resources
  end
end
```

### 2. Controller (`app/controllers/admin/scheduling_controller.rb`)
```ruby
class Admin::SchedulingController < ApplicationController
  # Temporarily removing authentication to test routes
  # before_action :authenticate_user!

  def index
    render plain: "Página de Configurações de Agendamento - Funcionando! Timestamp: #{Time.current}"
  end

  def update_configuration
    render plain: "Configuração atualizada! Timestamp: #{Time.current}"
  end

  def update_availability
    render plain: "Disponibilidade atualizada! Timestamp: #{Time.current}"
  end

  def move_orders_to_production
    render plain: "Pedidos movidos para produção! Timestamp: #{Time.current}"
  end
end
```

## Possíveis Causas

### 1. Servidor Rails não foi reiniciado
**Solução**: Reinicie o servidor Rails após adicionar novas rotas.

### 2. Erro de sintaxe no arquivo de rotas
**Verificação**: Execute `rails routes` para verificar se há erros de sintaxe.

### 3. Problema com namespace
**Verificação**: Certifique-se de que o controller está no namespace correto.

### 4. Problema com autenticação
**Solução**: Temporariamente removemos a autenticação para testar.

### 5. Problema com carregamento de classes
**Verificação**: Verifique se há erros no log do servidor.

## Passos para Debug

### 1. Verificar arquivos
```bash
# Execute este script para verificar se os arquivos estão corretos
ruby test_routes_debug.rb
```

### 2. Reiniciar servidor
```bash
# Pare o servidor atual (Ctrl+C)
# Inicie novamente
rails server
```

### 3. Verificar rotas carregadas
```bash
# Liste todas as rotas para verificar se as de agendamento estão lá
rails routes | grep admin
```

### 4. Verificar logs
```bash
# Monitore os logs enquanto acessa as rotas
tail -f log/development.log
```

### 5. Testar rotas progressivamente
1. Primeiro teste: `/admin/` (deve funcionar)
2. Segundo teste: `/admin/test` (deve mostrar se rotas simples funcionam)
3. Terceiro teste: `/admin/scheduling` (rota principal)

## Soluções Aplicadas

### 1. Simplificação do Controller
- Removemos dependências de models que podem não existir
- Removemos autenticação temporariamente
- Adicionamos timestamps para verificar se o código está sendo executado

### 2. Rotas Explícitas
- Adicionamos todas as rotas de agendamento explicitamente
- Incluímos rotas de teste para verificação

### 3. Debug Information
- Adicionamos informações de debug no controller
- Criamos script de verificação

## Próximos Passos

1. **Reiniciar o servidor Rails**
2. **Testar a rota `/admin/test`** - se funcionar, o problema era específico do scheduling
3. **Testar a rota `/admin/scheduling`** - deve mostrar mensagem de sucesso
4. **Verificar logs** para identificar qualquer erro não visível

## Rotas Esperadas

Após a correção, estas rotas devem funcionar:

```
GET    /admin/scheduling                           -> Admin::SchedulingController#index
PATCH  /admin/scheduling/configuration            -> Admin::SchedulingController#update_configuration  
PATCH  /admin/scheduling/availability             -> Admin::SchedulingController#update_availability
POST   /admin/scheduling/move_orders_to_production -> Admin::SchedulingController#move_orders_to_production
```

## Teste Final

Para verificar se tudo está funcionando:

```bash
# 1. Reiniciar servidor
rails server

# 2. Testar no navegador:
http://localhost:3000/admin/scheduling

# 3. Deve mostrar:
"Página de Configurações de Agendamento - Funcionando! Timestamp: [timestamp]"
```

Se ainda não funcionar, verifique se há erros no log do servidor e se o Rails está carregando corretamente todos os arquivos.