# 🎯 **KANBAN DELIVERY APP - GUIA COMPLETO**

## 🚀 **COMO USAR O SISTEMA KANBAN**

### 1. **Preparar o Ambiente**

```bash
# 1. Executar migrações (se necessário)
rails db:migrate

# 2. Compilar assets CSS
npm run build:css

# 3. Criar dados de demonstração
rails kanban:demo

# 4. Iniciar o servidor
rails server
```

### 2. **Acessar o Sistema**

- **URL:** `http://localhost:3000/admin`
- **Interface:** Dashboard administrativo com Kanban board

## 📋 **FUNCIONALIDADES DO KANBAN**

### ✅ **Colunas de Status Disponíveis:**

| Coluna | Cor | Descrição | Ações Possíveis |
|--------|-----|-----------|------------------|
| **🆕 NOVO** | Azul | Pedidos recém-criados | → Ag. Aprovação, ❌ Cancelar |
| **⚠️ AG. APROVAÇÃO** | Amarelo | Aguardando confirmação | → Produção, ❌ Cancelar |
| **🔄 PRODUÇÃO** | Azul Claro | Em preparação | → Pronto, ❌ Cancelar |
| **✅ PRONTO** | Verde | Pronto para entrega | → Entregue, ❌ Cancelar |
| **🚚 ENTREGUE** | Cinza | Entregues (Final) | *Nenhuma* |
| **❌ CANCELADO** | Vermelho | Cancelados (Final) | *Nenhuma* |

### 🎮 **Como Usar o Drag & Drop:**

1. **Clique e segure** um card de pedido
2. **Arraste** para a coluna desejada
3. **Solte** para confirmar a mudança
4. O sistema **atualiza automaticamente** o banco de dados

### 🎨 **Feedback Visual:**

- **✅ Verde:** Colunas onde você pode soltar (transição válida)
- **❌ Vermelho:** Colunas bloqueadas (transição inválida)  
- **🔄 Loading:** Spinner durante atualização no banco
- **📱 Notificações:** Toast com resultado da operação

## 🔧 **COMANDOS RAKE DISPONÍVEIS**

```bash
# Criar dados de demonstração para testar
rails kanban:demo

# Limpar todos os dados de teste
rails kanban:clean

# Ver tarefas disponíveis
rails -T kanban
```

## 📱 **COMPATIBILIDADE**

### ✅ **Desktop (Mouse):**
- Drag & drop suave com mouse
- Hover effects e feedback visual
- Todas as funcionalidades disponíveis

### ✅ **Tablet/Mobile (Touch):**
- Touch drag otimizado
- Delay configurado para evitar scroll
- Interface responsiva

### ✅ **Navegadores Suportados:**
- Chrome/Edge (latest)
- Firefox (latest)  
- Safari (latest)
- Opera (latest)

## 🎯 **FLUXO DE TRABALHO RECOMENDADO**

### **Cenário Típico de Delivery:**

1. **📞 Cliente faz pedido** → Status: `NOVO`
2. **👨‍💼 Admin revisa** → Arrasta para: `AG. APROVAÇÃO`
3. **✅ Admin aprova** → Arrasta para: `PRODUÇÃO`
4. **👨‍🍳 Cozinha prepara** → Arrasta para: `PRONTO`
5. **🚚 Saiu para entrega** → Arrasta para: `ENTREGUE`

### **Casos Especiais:**
- **❌ Cancelamento:** Possível a qualquer momento (exceto se já entregue)
- **🔄 Aceite Automático:** Se ativado, pula direto para `PRODUÇÃO`

## 🚨 **VALIDAÇÕES DE NEGÓCIO**

### **Transições Permitidas:**
```
NOVO → AG_APROVACAO ✅
NOVO → CANCELADO ✅

AG_APROVACAO → PRODUCAO ✅
AG_APROVACAO → CANCELADO ✅

PRODUCAO → PRONTO ✅
PRODUCAO → CANCELADO ✅

PRONTO → ENTREGUE ✅
PRONTO → CANCELADO ✅

ENTREGUE → (nenhuma) ❌
CANCELADO → (nenhuma) ❌
```

### **Movimentos Bloqueados:**
- ❌ Voltar status (ex: PRONTO → PRODUCAO)
- ❌ Pular etapas (ex: NOVO → PRONTO)
- ❌ Modificar pedidos entregues/cancelados

## 🎛️ **Funcionalidades Extras**

### **Filtros por Data:**
- Usar os campos "De:" e "Até:" no topo
- Filtra pedidos por data de agendamento
- Atualiza automaticamente via Turbo

### **Aceite Automático:**
- Botão toggle no dashboard
- Quando ativo: novos pedidos vão direto para `PRODUÇÃO`
- Quando inativo: novos pedidos ficam em `NOVO`

### **Informações dos Cards:**
- 👤 **Cliente:** Nome e telefone
- 🛍️ **Itens:** Produtos e quantidades
- 💰 **Valor:** Total do pedido
- 📅 **Data:** Criação e agendamento
- 📝 **Notas:** Observações da entrega

## 🔍 **Troubleshooting**

### **Card não move:**
- ✅ Verifique se a transição é válida
- ✅ Confirme que o JavaScript está carregado
- ✅ Abra o console para ver logs detalhados

### **Erro ao atualizar:**
- ✅ Verifique conexão com o servidor
- ✅ Confirme que o CSRF token está presente
- ✅ Veja se a rota `/admin/orders/:id/update_status` existe

### **Estilos não carregam:**
```bash
# Recompilar CSS
npm run build:css

# Reiniciar servidor
rails server
```

## 🎉 **Pronto para Usar!**

Agora você tem um **Kanban completo como o Trello**, mas específico para delivery:

- ✅ **Drag & Drop** fluido e responsivo
- ✅ **Validações** de negócio integradas  
- ✅ **Interface** moderna e profissional
- ✅ **Tempo real** com Hotwire/Turbo
- ✅ **Mobile-first** design

### 💡 **Dicas Finais:**
1. **Teste primeiro** com os dados demo
2. **Personalize** cores e textos conforme sua marca
3. **Monitore** os logs do console para debug
4. **Faça backup** antes de mudanças grandes

**🚀 Bom uso do seu novo sistema Kanban!** 