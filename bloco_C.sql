-- BLOCO C - FUNÇÕES AGREGADAS + GROUP BY + HAVING
-- 1. Faturamento total por estado do cliente.
SELECT 
    c.customer_state AS estado_cliente,
    SUM(i.price) AS faturamento_total
FROM public.olist_orders_dataset o
INNER JOIN public.olist_customers_dataset c 
    ON o.customer_id = c.customer_id
INNER JOIN public.olist_order_items_dataset i 
    ON o.order_id = i.order_id
GROUP BY c.customer_state
ORDER BY faturamento_total DESC;

--Consulta que permite um direcionamento de marketing, logística e infraestrutura
--para os estados que faturam mais.

-- 2. Top 10 vendedores por faturamento.
SELECT 
    seller_id,
    SUM(price) AS faturamento_vendedor
FROM public.olist_order_items_dataset
GROUP BY seller_id
ORDER BY faturamento_vendedor DESC
LIMIT 10;
--Identificar os maiores vendedores permite fortalecer a parceria com intermediários.

-- 3. Ticket médio por categoria de produto.
SELECT 
    p.product_category_name AS categoria_produto,
    AVG(i.price) AS ticket_medio
FROM public.olist_order_items_dataset i
INNER JOIN public.olist_products_dataset p 
    ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY ticket_medio DESC;
--Essa consulta permite saber qual nicho traz mais retorno fincanceiro
--o que é valioso para marketing.

-- 4. Vendedores com nota média de avaliação abaixo de 3
SELECT 
    i.seller_id,
    AVG(r.review_score) AS nota_media
FROM public.olist_order_items_dataset i
INNER JOIN public.olist_order_reviews_dataset r 
    ON i.order_id = r.order_id
GROUP BY i.seller_id
HAVING AVG(r.review_score) < 3
ORDER BY nota_media ASC;
--Essa consulta permite que o time direcione os vendedores, afim de preservar
--a reputação da marca e satisfação do cliente.

-- 5. Quantidade de pedidos por forma de pagamento (GROUP BY payment_type).
SELECT 
    payment_type AS forma_pagamento,
    COUNT(order_id) AS quantidade_pedidos
FROM public.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY quantidade_pedidos DESC;
--Essa consulta permite promover a otimização de formas de pagamento mais recorrentes.

-- 6. Peso médio dos produtos por categoria.
SELECT 
    product_category_name AS categoria_produto,
    AVG(product_weight_g) AS peso_medio_gramas
FROM public.olist_products_dataset
GROUP BY product_category_name;
--Essa consulta permite fazer um link entre o cálculo do frete e tipo de produto.

-- 7. Número médio de parcelas (AVG(payment_installments)) por categoria de produto.
SELECT 
    p.product_category_name AS categoria_produto,
    AVG(pay.payment_installments) AS media_parcelas
FROM public.olist_order_items_dataset i
INNER JOIN public.olist_products_dataset p 
    ON i.product_id = p.product_id
INNER JOIN public.olist_order_payments_dataset pay 
    ON i.order_id = pay.order_id
GROUP BY p.product_category_name
ORDER BY media_parcelas DESC;
--Essa consulta permite otimizar taxa de juros junto ás intermediárias de pagamento.





