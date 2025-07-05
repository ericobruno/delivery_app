#!/bin/bash
read -p "Nome da loja (slug): " loja

cp -r delivery_app "loja_${loja}"
cd "loja_${loja}"

echo "Personalize o .env e config/settings.yml da nova loja" 