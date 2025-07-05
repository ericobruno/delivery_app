# API de Pedidos - DeliveryApp

## Endpoint

`POST /api/orders`

---

## Autenticação

- **Obrigatória** via header:
  - `Authorization: Bearer <seu_token>`
- O token é definido pela variável de ambiente `API_ORDER_TOKEN`.

---

## Payload (JSON)

```json
{
  "order": {
    "customer_id": 1,
    "status": "agendado",
    "scheduled_for": "2024-08-10T15:00:00",
    "scheduled_notes": "Entregar na portaria",
    "order_items_attributes": [
      { "product_id": 2, "quantity": 1, "price": 50.0 }
    ]
  }
}
```

- **customer_id**: ID do cliente (obrigatório)
- **status**: status do pedido (ex: "agendado")
- **scheduled_for**: data/hora agendada (opcional)
- **scheduled_notes**: observações do agendamento (opcional)
- **order_items_attributes**: array de itens do pedido (obrigatório)

---

## Exemplo de requisição CURL

```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "status": "agendado",
      "scheduled_for": "2024-08-10T15:00:00",
      "scheduled_notes": "Entregar na portaria",
      "order_items_attributes": [
        { "product_id": 2, "quantity": 1, "price": 50.0 }
      ]
    }
  }'
```

---

## Respostas

### Sucesso (201)
```json
{
  "status": "sucesso",
  "mensagem": "Pedido criado com sucesso.",
  "pedido_id": 123,
  "dados": {
    "cliente_id": 1,
    "status": "agendado",
    "agendado_para": "2024-08-10T15:00:00"
  }
}
```

### Erro de autenticação (401)
```json
{
  "erro": "não autorizado",
  "mensagem": "Token de autenticação inválido ou ausente."
}
```

### Erro de validação (422)
```json
{
  "status": "erro",
  "mensagem": "Não foi possível criar o pedido.",
  "erros": [
    "Cliente deve existir",
    "Itens do pedido não podem estar vazios"
  ]
}
```

---

## Observações
- Sempre envie o token correto no header Authorization.
- Datas devem estar no formato ISO8601 (ex: `2024-08-10T15:00:00`).
- IDs de cliente e produto devem existir no banco.
- Use HTTPS em produção para segurança. 