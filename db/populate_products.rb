# Script para popular produtos do Paladar Frios
# Execute com: rails runner db/populate_products.rb

puts "Iniciando população do banco de dados com produtos..."

# Limpar produtos existentes (opcional - descomente se quiser limpar)
# Product.destroy_all
# Category.destroy_all

# Criar categorias
categories = {
  'Combos' => Category.find_or_create_by!(name: 'Combos'),
  'Tábuas' => Category.find_or_create_by!(name: 'Tábuas'),
  'Barcas' => Category.find_or_create_by!(name: 'Barcas'),
  'Monte sua Tábua' => Category.find_or_create_by!(name: 'Monte sua Tábua'),
  'Monte sua Barca' => Category.find_or_create_by!(name: 'Monte sua Barca'),
  'Frios para presentear' => Category.find_or_create_by!(name: 'Frios para presentear'),
  'Opções para eventos' => Category.find_or_create_by!(name: 'Opções para eventos'),
  'Outros' => Category.find_or_create_by!(name: 'Outros'),
  'Pães' => Category.find_or_create_by!(name: 'Pães'),
  'Bebidas' => Category.find_or_create_by!(name: 'Bebidas'),
  'Geléias e molhos' => Category.find_or_create_by!(name: 'Geléias e molhos'),
  'Castanhas' => Category.find_or_create_by!(name: 'Castanhas'),
  'Adic. quantidade Gold' => Category.find_or_create_by!(name: 'Adic. quantidade Gold'),
  'Adicionais (Porção de 100 g)' => Category.find_or_create_by!(name: 'Adicionais (Porção de 100 g)')
}

# Função para limpar descrição (remover informações de pagamento, desconto, etc)
def clean_description(description)
  return "" if description.nil?
  
  # Remove informações de pagamento e promoções
  description = description.gsub(/PARA PAGAMENTO VIA LINK, ACRESCIMO DE 5% NO VALOR\.?/, '')
  description = description.gsub(/\(R\$ [\d,\.]+ na sexta-feira\)/, '')
  description = description.gsub(/No dia da promoção SEXTA DA BARCA, não é possível agendar a retirada\/entrega para outro dia, a promoção é válida somenre pra sexta-feira\.?/, '')
  description = description.gsub(/No dia da promoção SEXTA DA BARCA, não é possível agendar a retirada\/entrega para outro dia, a promoção é válida somente pra sexta-feira\.?/, '')
  description = description.gsub(/ATENÇÃO: ACRESCENTAREMOS O VALOR DE R\$ 200,00 PARA CADA ATENDENTE\. 1 ATENDENTE A CADA 100 PESSOAS\. ANTECEDÊNCIA DE 10 DIAS PARA EFETUAR O PEDIDO\./, '')
  description = description.gsub(/ESSE TIPO DE PEDIDO NOS PEDIMOS O PRAZO MÍNIMO DE 2 DIAS, POR SE TRATAR DE ALGO PERSONALIZADO\. NÃO VENDEMOS SOMENTE A TÁBUA\./, '')
  description = description.gsub(/SOMENTE SOB ENCOMENDA \(Pelo menos 5 dias de antecedência\)\./, '')
  description = description.gsub(/CASO O PEDIDO SEJA PARA O MESMO DIA, FAVOR VERIFICAR A DISPONIBILIDADE ANTES DE EFETUAR A COMPRA\./, '')
  description = description.gsub(/DISPONIBILIZAMOS A TÁBUA SEM CUSTO\. ESSA TÁBUA É RETORNÁVEL, O CUIDADO E A DEVOLUÇÃO É RESPONSABILIDADE DO CLEINTE\./, '')
  description = description.gsub(/A BARCA DE \d+ KG SUPORTA APENAS \d+ ADICIONAL DE \d+ g/, '')
  description = description.gsub(/Serve duas pessoas\./, '')
  description = description.gsub(/Servindo como ENTRADA - Atende \d+ pessoas\. Servindo com PRATO PRINCIPAL - Atende \d+ pessoas\./, '')
  description = description.gsub(/Serve \d+ pessoas como entrada\. Serve \d+ pessoas como prato principal\./, '')
  description = description.gsub(/Serve \d+ pessoas\./, '')
  description = description.gsub(/Atende \d+ pessoas\./, '')
  description = description.gsub(/Atende \d+ pessoas como entrada\. Atende \d+ pessoas como prato principal\./, '')
  description = description.gsub(/Nesse COMBO você encontra uma combinação perfeita\. ATENDE 2 PESSOAS\./, '')
  description = description.gsub(/Essa é a nossa tábua para eventos acima de \d+ pessoas\. A capacidade máxima dela é de \d+ kg, sendo assim você pode acrescentar até \d+ adicionais de \d+g\./, '')
  description = description.gsub(/Essa é a nossa tábua para eventos acima de \d+ pessoas\. A capacidade máxima dela é de \d+ kg, sendo assim vc pode acrescentar até \d+ adicionais de \d+ g, caso queira\./, '')
  description = description.gsub(/A tábua "P" mínimo \d+ g e máximo de \d+ g\. Lembrando que cada adicional contém \d+g, ou seja, você pode escolher entre \d+ \(\d+g\) a \d+ \(\d+g\) produtos\./, '')
  description = description.gsub(/A tábua "M" suporta de \d+ kg até \d+ kg\. Lembrando que cada adicional contém \d+g\. O cálculo baseado na quantidade de pessoas funciona assim: Servindo como ENTRADA \(\d+ g por pessoa\)\. Servindo como PRATO PRINCIPAL \(\d+ g por pessoa\)\. Pra saber a quantidade que irá precisar baseado na quantidade de pessoas, você precisa fazer o seguinte cálculo: Qntd de pessoas X entrada \(\d+\) ou Prato Principal \(\d+\)\. EXEMPLOS: \d+ pessoas X \d+ \(entrada\) = \d+ kg\. \d+ pessoas X \d+ \(P\.Principal\) = \d+ kg\./, '')
  description = description.gsub(/A tábua "G" suporta de \d+,\d+ kg até \d+,\d+ kg\. Lembrando que cada adicional contém \d+g\. O cálculo baseado na quantidade de pessoas funciona assim: Servindo como ENTRADA \(\d+ g por pessoa\)\. Servindo como PRATO PRINCIPAL \(\d+ g por pessoa\)\. Pra saber a quantidade que irá precisar baseado na quantidade de pessoas, você precisa fazer o seguinte cálculo: Qntd de pessoas X entrada \(\d+\) ou Prato Principal \(\d+\)\. EXEMPLOS: \d+ pessoas X \d+ \(entrada\) = \d+,\d+ kg\. \d+ pessoas X \d+ \(P\.Principal\) = \d+,\d+ kg\./, '')
  description = description.gsub(/Na barca P você TEM que colocar exatamente \d+ produtos, não pode ser mais, pq a barca não suporta mais de \d+ g e não pode ser menos, pq a montagem\/visual não fica legal\. \(Embalagem descartável\)\./, '')
  description = description.gsub(/Na barca G você TEM que colocar entre \d+ a \d+ produtos, não pode ser mais pq a barca não suporta mais de \d+,\d+ kg e não pode ser menos, pq a montagem\/visual com menos de \d+ kg nessa embalagem não fica bacana\. \(Embalagem descartável\)\./, '')
  description = description.gsub(/Na barca G você TEM que colocar entre \d+ a \d+ produtos, não pode ser mais pq a barca não suporta mais de \d+,\d+ kg e não pode ser menos, pq a montagem\/visual com menos de \d+ kg nessa embalagem não fica bacana\. \(Embalagem descartável\)\./, '')
  description = description.gsub(/Funciona assim: Você escolhe o tamanho da tábua P - \d+ g, M - De \d+ kg até \d+,\d+ kg, G - De \d+,\d+ kg até \d+,\d+ kg\. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja \(Tradicional, Gold ou de Queijos\)\. Caso queira escolher os produtos, nessa tábua P vc tem que escolher \d+ adicionais que no total dará \d+g\./, '')
  description = description.gsub(/Funciona assim: Você escolhe o tamanho da tábua P - \d+ g, M - De \d+ kg até \d+,\d+ kg, G - De \d+,\d+ kg até \d+,\d+ kg\. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja \(Tradicional, Gold ou de Queijos\)\. Caso queira escolher os produtos, nessa tábua M você pode escolher de \d+ a \d+ adicionais\./, '')
  description = description.gsub(/Funciona assim: Você escolhe o tamanho da tábua P - \d+ g, M - De \d+ kg até \d+,\d+ kg, G - De \d+,\d+ kg até \d+,\d+ kg\. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja \(Tradicional, Gold ou de Queijos\)\. Caso queira escolher os produtos, nessa tábua G você terá que escolher entre \d+ a \d+ adicionais\./, '')
  description = description.gsub(/Serve 1 pessoa\. Quantidade: \d+ g\./, '')
  description = description.gsub(/Espeto com \d+ cm \(pacote com \d+ unidades\)\./, '')
  description = description.gsub(/Embalagem com \d+ unidades\./, '')
  description = description.gsub(/Torrada feita com fermentação natural\. Qualidade Bauducco\./, '')
  description = description.gsub(/Grissini, pacote com aproximadamente \d+ g\./, '')
  description = description.gsub(/Vinho Malbec - Chileno\. Aroma fresco de morango e amora\. As frutas são complementadas perfeitamente por uma acidez equilibrada\. Harmoniza perfeitamente com a nossa tábua Gold\./, '')
  description = description.gsub(/Vinho tinto seco\./, '')
  description = description.gsub(/Vinho Malbec - Chileno\./, '')
  description = description.gsub(/Harmoniza muito com os queijos, torradas e palitinho com orégano\./, '')
  description = description.gsub(/Harmoniza perfeitamente com os queijos, torradas e palitinho com orégano\./, '')
  description = description.gsub(/Amêndoa crua, amendoim torrado sem sal, castanha de caju sem sal, castanha do Pará, nozes e uva passa\. NÃO CONTÉM GLÚTEN E LACTOSE\./, '')
  description = description.gsub(/Aproximadamente \d+ g\./, '')
  description = description.gsub(/\(Embalagem descartável\)\./, '')
  description = description.gsub(/------ ATENÇÃO -------/, '')
  
  # Remove informações de harmonização com bebidas
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A TÁBUA GOLD: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A BARCA GOLD: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A OPÇÃO GOLD: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  description = description.gsub(/HARMONIZA BEM COM CERVEJA, CHOPP, CAIPIRINHA, SUCO, REFRIGERANTE E OUTROS\./, '')
  description = description.gsub(/HARMONIZA MELHOR COM: CERVEJA, CHOPP, CAIPIRINHA, REFRIGERANTE, SUCO E OUTROS\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A TÁBUA DE QUEIJOS: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A BARCA DE QUEIJOS: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A ILHA TRADICIONAL: Cerveja, chopp, refrigerante, suco, água e outros\./, '')
  description = description.gsub(/TIPOS DE BEBIDAS QUE HARMONIZAM COM A ILHA GOLD: Vinho, champanhe, frisante, espumante, whisky e outros\./, '')
  
  # Remove informações de acompanhamentos
  description = description.gsub(/ACOMPANHAMENTOS: Torrada, Grissini, Geléia de pimenta, Mel\./, '')
  
  # Limpa espaços extras e pontuação
  description = description.strip.gsub(/\s+/, ' ').gsub(/\.+$/, '')
  
  description
end

# Produtos organizados por categoria
products_data = {
  'Combos' => [
    { name: 'Tábua Gold 500g + Geléia de pimenta TAI + Torrada tradicional', price: 215.7, description: 'Produtos que compõe a tábua: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Tábua tradicional 500g + Geléia de pimenta TAI + Torrada tradicional', price: 165.7, description: 'Produtos que compõem a tábua: Provolone, Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca tradicional 500g + Geléia de Pimenta Tai + Torrada tradicional', price: 123.7, description: 'Produtos que compõem a barca: Provolone, Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca Gold 500g + Geléia de pimenta Tai + Torrada tradicional', price: 180.7, description: 'Produtos que compõe a barca: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Tábua gold 500g + Molho de mostarda com pimenta e mel 230g + torrada tradicional', price: 216.7, description: 'Produtos que compõe a tábua: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Tábua tradicional 500g + Molho de mostarda, pimenta e mel 230g + torrada tradicional', price: 166.7, description: 'Produtos que compõem a tábua: Provolone, Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca Gold 500g + Molho de mostarda com pimenta e mel 230g + torrada tradicional', price: 181.7, description: 'Produtos que compõe a barca: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Barca tradicional 500g + Molho de mostarda com pimenta e mel 230g + Torrada tradicional', price: 124.7, description: 'Produtos que compõem a barca: Provolone, Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' }
  ],
  'Tábuas' => [
    { name: 'Tábua Gold 1 kg', price: 299.7, description: 'Produtos que compõe a tábua: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona Preta.' },
    { name: 'Tábua Gold 500 g', price: 179.7, description: 'Produtos que compõe a tábua: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Tábua Tradicional 1 kg', price: 199.7, description: 'Produtos que compõem a tábua: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Tábua Tradicional 500 g', price: 129.7, description: 'Produtos que compõem a barca: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Tábua de Queijos 1 kg', price: 255.7, description: 'Produtos que compõem a tábua: Queijo Brie com favo de mel, Queijo gouda, Queijo gorgonzola, Queijo provolone, Queijo parmesão, Queijo muçarela, Queijo nozinho, Queijo palitinho temperado, Tâmara jumbo, Damasco, Castanha, Azeitona preta.' },
    { name: 'Tábua de Queijos 500 g', price: 164.7, description: 'Produtos que compõem a tábua: Queijo Brie com favo de mel, Queijo gouda, Queijo gorgonzola, Queijo provolone, Queijo parmesão, Queijo muçarela, Queijo nozinho, Queijo palitinho temperado, Tâmara jumbo, Damasco, Castanha, Azeitona preta.' }
  ],
  'Barcas' => [
    { name: 'Barca Gold 500 g', price: 144.7, description: 'Produtos que compõem a Barca: Brie com favo de mel, Gouda, Gorgonzola, Presunto parma, Copa, Salaminho, Provolone, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Barca Gold 1 kg', price: 232.7, description: 'Produtos que compõem a Barca: Brie com favo de mel, Gouda, Gorgonzola, Presunto parma, Copa, Salaminho, Provolone, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Barca Gold 2 kg', price: 465.4, description: 'Produtos que compõem a Barca: Brie com favo de mel, Gouda, Gorgonzola, Presunto parma, Copa, Salaminho, Provolone, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Barca Tradicional 500 g', price: 87.7, description: 'Produtos que compõem a barca: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca Tradicional 1 kg', price: 137.7, description: 'Produtos que compõem a barca: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca tradicional 2 kg', price: 275.4, description: 'Produtos que compõem a barca: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado/Nozinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Barca de Queijos 500 g', price: 114.7, description: 'Produtos que compõem a barca: Queijo Brie com favo de mel, Queijo gouda, Queijo gorgonzola, Queijo provolone, Queijo parmesão, Queijo muçarela, Queijo nozinho, Queijo palitinho temperado, Tâmara jumbo, Damasco, Castanha, Azeitona preta.' },
    { name: 'Barca de Queijos 1 kg', price: 188.7, description: 'Produtos que compõem a barca: Queijo Brie com favo de mel, Queijo gouda, Queijo gorgonzola, Queijo provolone, Queijo parmesão, Queijo muçarela, Queijo nozinho, Queijo palitinho temperado, Tâmara jumbo, Damasco, Castanha, Azeitona preta.' },
    { name: 'Barca de Queijos 2 kg', price: 377.4, description: 'Produtos que compõem a barca: Queijo Brie com favo de mel, Queijo gouda, Queijo gorgonzola, Queijo provolone, Queijo parmesão, Queijo muçarela, Queijo nozinho, Queijo palitinho temperado / nozinho temperado, Tâmara jumbo, Damasco, Castanha, Azeitona preta.' }
  ],
  'Monte sua Tábua' => [
    { name: 'Tábua tamanho P (500 g)', price: 30.7, description: 'Tábua "P" mínimo 500 g e máximo de 700 g. Lembrando que cada adicional contém 50g, ou seja, você pode escolher entre 10 (500g) a 14 (700g) produtos.' },
    { name: 'Tábua tamanho M (Entre 1kg até 1,3 kg)', price: 40.7, description: 'A tábua "M" suporta de 1 kg até 1,3 kg. Lembrando que cada adicional contém 100g.' },
    { name: 'Tábua tamanho G (De 1,4 kg até 2,1 kg)', price: 50.7, description: 'A tábua "G" suporta de 1,4 kg até 2,2 kg. Lembrando que cada adicional contém 100g.' }
  ],
  'Monte sua Barca' => [
    { name: 'Barca P - 500 g', price: 8.7, description: 'Atende 2 pessoas (Barca casal). Na barca P você TEM que colocar exatamente 10 produtos, não pode ser mais, pq a barca não suporta mais de 500 g e não pode ser menos, pq a montagem/visual não fica legal.' },
    { name: 'Barca M - 1 kg', price: 10.7, description: 'Atende 5 pessoas como entrada. Atende 3 pessoas como prato principal. Na barca G você TEM que colocar entre 10 a 11 produtos, não pode ser mais pq a barca não suporta mais de 1,1 kg e não pode ser menos, pq a montagem/visual com menos de 1 kg nessa embalagem não fica bacana.' },
    { name: 'Barca G - 2 kg - Cópia', price: 12.7, description: 'Atende 5 pessoas como entrada. Atende 3 pessoas como prato principal. Na barca G você TEM que colocar entre 20 a 21 produtos, não pode ser mais pq a barca não suporta mais de 2,1 kg e não pode ser menos, pq a montagem/visual com menos de 2 kg nessa embalagem não fica bacana.' }
  ],
  'Frios para presentear' => [
    { name: 'Tábua personalizada com gravação - Tamanho P (500 g)', price: 70.0, description: 'ESSE TIPO DE PEDIDO NOS PEDIMOS O PRAZO MÍNIMO DE 2 DIAS, POR SE TRATAR DE ALGO PERSONALIZADO. NÃO VENDEMOS SOMENTE A TÁBUA. Funciona assim: Você escolhe o tamanho da tábua P - 500 g, M - De 1 kg até 1,3 kg, G - De 1,4 kg até 2,2 kg. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja (Tradicional, Gold ou de Queijos). Caso queira escolher os produtos, nessa tábua P vc tem que escolher 10 adicionais que no total dará 500g.' },
    { name: 'Tábua personalizada com gravação - Tamanho M (De 1 kg a 1,3 kg)', price: 90.0, description: 'ESSE TIPO DE PEDIDO NOS PEDIMOS O PRAZO MÍNIMO DE 2 DIAS, POR SE TRATAR DE ALGO PERSONALIZADO. NÃO VENDEMOS SOMENTE A TÁBUA. Funciona assim: Você escolhe o tamanho da tábua P - 500 g, M - De 1 kg até 1,3 kg, G - De 1,4 kg até 2,2 kg. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja (Tradicional, Gold ou de Queijos). Caso queira escolher os produtos, nessa tábua M você pode escolher de 10 a 14 adicionais.' },
    { name: 'Tábua personalizada com gravação - Tamanho G (1,4 kg até 2,1 kg)', price: 110.0, description: 'ESSE TIPO DE PEDIDO NOS PEDIMOS O PRAZO MÍNIMO DE 2 DIAS, POR SE TRATAR DE ALGO PERSONALIZADO. NÃO VENDEMOS SOMENTE A TÁBUA. Funciona assim: Você escolhe o tamanho da tábua P - 500 g, M - De 1 kg até 1,3 kg, G - De 1,4 kg até 2,2 kg. Ai você adiciona no carrinho e depois vai lá em tábuas e escolhe a opcão de produto você deseja (Tradicional, Gold ou de Queijos). Caso queira escolher os produtos, nessa tábua G você terá que escolher entre 20 a 23 adicionais.' }
  ],
  'Opções para eventos' => [
    { name: 'Tábua Gold 3 kg', price: 899.1, description: 'Serve 15 pessoas como entrada. Serve 10 pessoas como prato principal. Essa é a nossa tábua para eventos acima de 15 pessoas. A capacidade máxima dela é de 4 kg, sendo assim você pode acrescentar até 10 adicionais de 100g. DISPONIBILIZAMOS A TÁBUA SEM CUSTO. ESSA TÁBUA É RETORNÁVEL, O CUIDADO E A DEVOLUÇÃO É RESPONSABILIDADE DO CLEINTE. Produtos que compõe a tábua: Queijo brie com favo de mel, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta.' },
    { name: 'Tábua Tradicional 3 kg', price: 599.1, description: 'Serve 15 pessoas como entrada. Serve 10 pessoas como prato principal. Essa é a nossa tábua para eventos acima de 15 pessoas. A capacidade máxima dela é de 4 kg, sendo assim vc pode acrescentar até 10 adicionais de 100 g, caso queira. DISPONIBILIZAMOS A TÁBUA SEM CUSTO. ESSA TÁBUA É RETORNÁVEL, O CUIDADO E A DEVOLUÇÃO É RESPONSABILIDADE DO CLEINTE. Produtos que compõem a tábua: Provolone, Peito de peru, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna.' },
    { name: 'Ilha de Frios Tradicional - VALOR POR PESSOA', price: 37.94, description: 'ATENÇÃO: ACRESCENTAREMOS O VALOR DE R$ 200,00 PARA CADA ATENDENTE. 1 ATENDENTE A CADA 100 PESSOAS. ANTECEDÊNCIA DE 10 DIAS PARA EFETUAR O PEDIDO. Produtos que compõe a ilha: Provolone, Peito de peru / Lombo, Salaminho, Presunto, Muçarela, Palitinho temperado, Nozinho, Tomate cereja, Azeitona verde, Ovo de codorna. ACOMPANHAMENTOS: Torrada, Grissini, Geléia de pimenta, Mel.' },
    { name: 'Ilha de Frios Gold - VALOR POR PESSOA', price: 57.94, description: 'ATENÇÃO: ACRESCENTAREMOS O VALOR DE R$ 200,00 PARA CADA ATENDENTE. 1 ATENDENTE A CADA 100 PESSOAS. ANTECEDÊNCIA DE 10 DIAS PARA EFETUAR O PEDIDO. Produtos que compõe a ilha: Queijo brie, Queijo gouda, Queijo gorgonzola, Presunto parma, Copa, Provolone, Salaminho, Damasco, Tâmara jumbo, Azeitona preta. ACOMPANHAMENTOS: Torrada, Grissini, Geléia de pimenta, Mel.' },
    { name: 'Finger Food (Valor unitário)', price: 16.7, description: 'SOMENTE SOB ENCOMENDA (Pelo menos 5 dias de antecedência). Produtos: Tomate cereja, Muçarela, Palitinho temperado, Salame, Palitinho com orégano, Manjericão, Alecrim. Aproximadamente 140 g.' }
  ],
  'Outros' => [
    { name: 'Copão de Frios', price: 25.7, description: 'Serve 1 pessoa. Quantidade: 220 g. PRODUTOS: Muçarela, Provolone, Presunto, Peito de peru ou lombo, Salame, Tomate cereja, Manjericão, Alecrim.' },
    { name: 'Espeto de bambu', price: 12.7, description: 'Espeto com 9 cm (pacote com 50 unidades).' },
    { name: 'Ferrero Rocher', price: 13.87, description: 'Embalagem com 3 unidades.' }
  ],
  'Pães' => [
    { name: 'Torrada Bauducco 110g', price: 17.7, description: 'Torrada feita com fermentação natural. Qualidade Bauducco.' },
    { name: 'Grissini', price: 21.24, description: 'Grissini, pacote com aproximadamente 140 g.' }
  ],
  'Bebidas' => [
    { name: 'Vinho Casillero del Diablo - Rosé', price: 139.7, description: 'Vinho Malbec - Chileno. Aroma fresco de morango e amora. As frutas são complementadas perfeitamente por uma acidez equilibrada. Harmoniza perfeitamente com a nossa tábua Gold.' },
    { name: 'Vinho Santa Helena (Carmenére)', price: 81.7, description: 'Vinho tinto seco.' },
    { name: 'Vinho Casillero del Diablo - Malbec', price: 139.7, description: 'Vinho Malbec - Chileno.' }
  ],
  'Geléias e molhos' => [
    { name: 'Geléia de pimenta TAI', price: 27.7, description: 'Harmoniza muito com os queijos, torradas e palitinho com orégano.' },
    { name: 'Molho de mostarda, pimenta e mel', price: 28.7, description: 'Harmoniza perfeitamente com os queijos, torradas e palitinho com orégano.' }
  ],
  'Castanhas' => [
    { name: 'Mix de castanhas 130 g', price: 19.4, description: 'Amêndoa crua, amendoim torrado sem sal, castanha de caju sem sal, castanha do Pará, nozes e uva passa. NÃO CONTÉM GLÚTEN E LACTOSE.' }
  ],
  'Adic. quantidade Gold' => [
    { name: 'Adicional de 100 g', price: 29.97, description: '' },
    { name: 'Adicional de 200 g', price: 59.94, description: '' },
    { name: 'Adicional de 50 g', price: 14.98, description: '' }
  ],
  'Adicionais (Porção de 100 g)' => [
    { name: 'Adicional de queijo Brie (100 g)', price: 26.7, description: '' },
    { name: 'Adicional de queijo Gorgonzola (100 g)', price: 26.7, description: '' },
    { name: 'Adicional de queijo Gouda (100 g)', price: 26.7, description: '' },
    { name: 'Adicional de queijo Parmesão (100 g)', price: 26.7, description: '' }
  ]
}

# Criar produtos
total_products = 0
products_data.each do |category_name, products|
  category = categories[category_name]
  puts "Criando produtos para categoria: #{category_name}"
  
  products.each do |product_data|
    # Limpar a descrição
    clean_desc = clean_description(product_data[:description])
    
    # Criar ou atualizar o produto
    product = Product.find_or_create_by!(name: product_data[:name]) do |p|
      p.price = product_data[:price]
      p.description = clean_desc
      p.category = category
    end
    
    # Se o produto já existia, atualizar
    if product.persisted? && (product.price != product_data[:price] || product.description != clean_desc || product.category != category)
      product.update!(
        price: product_data[:price],
        description: clean_desc,
        category: category
      )
    end
    
    total_products += 1
    puts "  ✓ #{product.name} - R$ #{product.price}"
  end
end

puts "\n✅ População concluída!"
puts "Total de produtos criados/atualizados: #{total_products}"
puts "Total de categorias: #{categories.count}" 