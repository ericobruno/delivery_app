# API de Agendamento - Sistema de Delivery

Esta documentação descreve as funcionalidades de agendamento implementadas no sistema de delivery, seguindo as boas práticas SOLID e DDD.

## Arquitetura

### Princípios SOLID Aplicados

1. **Single Responsibility Principle (SRP)**: Cada classe tem uma responsabilidade única
   - `SchedulingService`: Gerencia a lógica de agendamento
   - `OrderSchedulingService`: Gerencia pedidos agendados
   - `SchedulingConfiguration`: Gerencia configurações
   - `SchedulingAvailability`: Gerencia disponibilidade

2. **Open/Closed Principle (OCP)**: Extensível sem modificação
   - Concerns reutilizáveis (`Schedulable`)
   - Serviços que podem ser estendidos

3. **Liskov Substitution Principle (LSP)**: Substituição transparente
   - Interfaces bem definidas entre serviços

4. **Interface Segregation Principle (ISP)**: Interfaces específicas
   - Cada serviço tem interface específica

5. **Dependency Inversion Principle (DIP)**: Dependências abstratas
   - Serviços dependem de abstrações, não implementações

### Padrões DDD Aplicados

1. **Entidades**: `Order`, `SchedulingConfiguration`
2. **Value Objects**: Configurações de tempo, disponibilidade
3. **Serviços de Domínio**: `SchedulingService`, `OrderSchedulingService`
4. **Repositórios**: `Setting` (como repositório de configurações)

## Funcionalidades Implementadas

### 1. Aceitar Agendamento
- **Toggle**: Ativar/desativar funcionalidade de agendamento
- **Persistência**: Estado salvo nas configurações
- **Impacto**: Controla se clientes podem agendar

### 2. Disponibilidade do Agendamento
- **Configuração**: Número de dias à frente (1-365)
- **Validação**: Número inteiro positivo
- **Impacto**: Define janela de agendamento

### 3. Agendamento para o Mesmo Dia
- **Toggle**: Habilitar/desabilitar
- **Intervalos**: Configurável (1-5 intervalos)
- **Cálculo**: Baseado na hora atual

### 4. Agendamento com Estabelecimento Fechado
- **Toggle**: Permitir agendamento fora do expediente
- **Impacto**: Flexibilidade de horários

### 5. Modo Aceite
- **Manual**: Pedido aceito manualmente
- **Automático**: Pedido aceito automaticamente
- **Configuração**: Radio button

### 6. Intervalo de Tempo
- **Unidade**: Minuto/Hora
- **Intervalo**: Valor configurável
- **Validação**: Valor válido para unidade

### 7. Seleção de Intervalos Disponíveis
- **Interface**: Tabela com dias da semana
- **Seleção**: Checkboxes para cada intervalo
- **Flexibilidade**: Diferentes intervalos por dia
- **Persistência**: Salvamento automático

### 8. Cancelamento de Pedido
- **Unidade**: Horas/Dias
- **Valor**: Tempo antes da entrega
- **Validação**: Número inteiro positivo

### 9. Passar Pedido para Produção
- **Unidade**: Minutos/Horas
- **Intervalo**: Tempo antes do agendamento
- **Validação**: Número inteiro positivo

## Modelos e Serviços

### SchedulingConfiguration
```ruby
# Gerencia todas as configurações de agendamento
class SchedulingConfiguration
  attribute :scheduling_enabled, :boolean
  attribute :max_days_ahead, :integer
  attribute :same_day_scheduling_enabled, :boolean
  # ... outros atributos
end
```

### SchedulingAvailability
```ruby
# Gerencia disponibilidade por dia da semana
class SchedulingAvailability
  DAYS_OF_WEEK = %w[sunday monday tuesday wednesday thursday friday saturday]
  TIME_SLOTS = %w[06:00 07:00 08:00 ... 23:00]
end
```

### SchedulingService
```ruby
# Serviço principal de agendamento
class SchedulingService
  def available_slots_for_date(date)
  def can_schedule_for_same_day?
  def can_schedule_when_closed?
  # ... outros métodos
end
```

### OrderSchedulingService
```ruby
# Serviço específico para pedidos agendados
class OrderSchedulingService
  def schedule_order(order, scheduled_time)
  def cancel_scheduled_order(order)
  def move_orders_to_production
  # ... outros métodos
end
```

## Rotas da API

### Configurações de Agendamento
```
GET    /admin/scheduling                    # Página de configurações
PATCH  /admin/scheduling/configuration     # Atualizar configurações
PATCH  /admin/scheduling/availability      # Atualizar disponibilidade
POST   /admin/scheduling/move_orders_to_production  # Mover para produção
```

### Pedidos Agendados
```
POST   /admin/orders/:id/cancel_scheduled_order  # Cancelar agendamento
```

## Jobs e Automação

### MoveScheduledOrdersToProductionJob
```ruby
# Job para mover pedidos automaticamente para produção
class MoveScheduledOrdersToProductionJob < ApplicationJob
  def perform
    service = OrderSchedulingService.new
    moved_count = service.move_orders_to_production
  end
end
```

## Validações e Regras de Negócio

### Validações de Agendamento
- Horário não pode ser no passado
- Deve estar dentro da janela de agendamento
- Horário deve estar disponível na configuração
- Deve respeitar intervalos configurados

### Regras de Cancelamento
- Só pode cancelar dentro do prazo configurado
- Pedidos em produção não podem ser cancelados
- Pedidos entregues não podem ser cancelados

### Regras de Produção
- Pedidos agendados vão para produção automaticamente
- Tempo configurável antes do horário agendado
- Job automático para mover pedidos

## Interface do Usuário

### Configurações de Agendamento
- Formulário completo com todas as opções
- Tabela de disponibilidade por dia da semana
- Validações em tempo real
- Feedback visual de status

### Visualização de Pedidos
- Indicador visual de agendamento
- Informações de data/hora agendada
- Botão de cancelamento (quando permitido)
- Status de disponibilidade do horário

## Testes

### Cobertura de Testes
- Testes unitários para todos os modelos
- Testes de integração para serviços
- Testes de validação de regras de negócio
- Testes de interface do usuário

### Exemplo de Teste
```ruby
RSpec.describe OrderSchedulingService do
  it 'agenda pedido com sucesso' do
    result = service.schedule_order(order, scheduled_time)
    expect(result).to be true
    expect(order.scheduled_for).to eq(scheduled_time)
  end
end
```

## Configuração e Deploy

### Variáveis de Ambiente
```bash
# Configurações padrão
SCHEDULING_ENABLED=true
SCHEDULING_MAX_DAYS=90
SCHEDULING_SAME_DAY_ENABLED=true
```

### Migração de Dados
```ruby
# As configurações são salvas na tabela settings
# Não são necessárias migrações adicionais
```

## Monitoramento e Logs

### Logs Importantes
- Agendamento de pedidos
- Cancelamento de pedidos
- Movimentação para produção
- Erros de validação

### Métricas
- Número de pedidos agendados
- Taxa de cancelamento
- Tempo médio de agendamento
- Horários mais populares

## Segurança

### Validações de Segurança
- Validação de entrada em todos os formulários
- Sanitização de dados
- Controle de acesso por usuário
- Logs de auditoria

### Boas Práticas
- Uso de strong parameters
- Validações no modelo
- Sanitização de HTML
- Controle de CSRF

## Performance

### Otimizações
- Cache de configurações (5 minutos)
- Índices no banco de dados
- Queries otimizadas
- Paginação de resultados

### Monitoramento
- Tempo de resposta das queries
- Uso de memória
- CPU usage
- Database connections

## Conclusão

A implementação segue rigorosamente os princípios SOLID e padrões DDD, resultando em:

1. **Código Manutenível**: Estrutura clara e bem organizada
2. **Extensível**: Fácil adição de novas funcionalidades
3. **Testável**: Cobertura completa de testes
4. **Escalável**: Arquitetura preparada para crescimento
5. **Robusto**: Validações e tratamento de erros

O sistema está pronto para produção e pode ser facilmente estendido com novas funcionalidades de agendamento.