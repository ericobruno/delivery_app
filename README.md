# Delivery App

Sistema de delivery desenvolvido em Ruby on Rails 7.1.

## Funcionalidades

- ✅ Dashboard administrativo
- ✅ Gestão de pedidos
- ✅ Sistema de aceite automático
- ✅ Filtros por data e status
- ✅ Interface responsiva com Bootstrap

## Tecnologias

- **Ruby** 3.2.2
- **Rails** 7.1.5
- **PostgreSQL**
- **Bootstrap** 5
- **Turbo** (Hotwire)
- **JavaScript** (Vanilla)

## Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd delivery_app
```

2. Instale as dependências:
```bash
bundle install
yarn install
```

3. Configure o banco de dados:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Inicie o servidor:
```bash
rails server
```

## Uso

Acesse `http://localhost:3000/admin` para o dashboard administrativo.

### Aceite Automático

O sistema possui uma funcionalidade de aceite automático que pode ser ativada/desativada através do botão no dashboard. Quando ativado, novos pedidos são automaticamente aprovados.

## Estrutura do Projeto

```
app/
├── controllers/
│   └── admin/
│       └── dashboard_controller.rb
├── models/
│   ├── order.rb
│   ├── customer.rb
│   └── setting.rb
└── views/
    └── admin/
        └── dashboard/
```

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT.
