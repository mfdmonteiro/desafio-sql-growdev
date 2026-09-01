--Bloco B — JOINs

--1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.

SELECT 
    t.product_category_name AS categoria_traduzida,
    i.price AS valor_item,
    s.seller_city AS cidade_vendedor
FROM public.olist_order_items_dataset i
INNER JOIN public.olist_products_dataset p 
    ON i.product_id = p.product_id
INNER JOIN public.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
INNER JOIN public.olist_sellers_dataset s 
    ON i.seller_id = s.seller_id;

--Esta consulta permite um estudo de onde implantar centros 
--de logística e também aprimoramento do procesos logísticos
--em geral na empresa.

-- 2. Identificar pedidos com atraso na entrega, comparando data estimada com data real de entrega (join entre orders e customers).
SELECT 
    o.order_id,
    c.customer_id,
    c.customer_city,
    o.order_estimated_delivery_date AS data_prometida,
    o.order_delivered_customer_date AS data_real_entrega
FROM public.olist_orders_dataset o
INNER JOIN public.olist_customers_dataset c 
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date;

-- Com essa consulta pode ser estudado como resolver gargalos de atrasos.


-- 3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de uma parcela.
SELECT 
    o.order_id,
    o.order_status,
    p.payment_type AS forma_pagamento,
    p.payment_installments AS numero_parcelas
FROM public.olist_orders_dataset o
INNER JOIN public.olist_order_payments_dataset p 
    ON o.order_id = p.order_id;

--Essa consulta auxilia o time financeiro nas previsões de fluxo de caixa e preferências de pagamento.

-- 4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria não possui tradução cadastrada.
SELECT 
    p.product_id,
    p.product_category_name AS categoria_original,
    t.product_category_name_english AS categoria_ingles
FROM public.olist_products_dataset p
LEFT JOIN public.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;
--Essa consulta permite fazer manutenção dos dados, colocando a tradução onde está "null"

-- 5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado.
SELECT 
    o.order_id,
    c.customer_id,
    c.customer_state AS estado_cliente,
    s.seller_id,
    s.seller_state AS estado_vendedor
FROM public.olist_orders_dataset o
INNER JOIN public.olist_customers_dataset c 
    ON o.customer_id = c.customer_id
INNER JOIN public.olist_order_items_dataset i 
    ON o.order_id = i.order_id
INNER JOIN public.olist_sellers_dataset s 
    ON i.seller_id = s.seller_id
WHERE c.customer_state = s.seller_state;
 
--Essa consulta permite aprimoramento logístico.
