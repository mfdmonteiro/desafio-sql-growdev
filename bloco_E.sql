Bloco E — CASE WHEN

-- 1. Classificar pedidos por prazo de entrega: "adiantado", "no prazo" ou "atrasado".
SELECT 
    order_id,
    order_estimated_delivery_date AS data_estimada,
    order_delivered_customer_date AS data_real,
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'atrasado'
        WHEN order_delivered_customer_date = order_estimated_delivery_date THEN 'no prazo'
        ELSE 'adiantado'
    END AS status_prazo
FROM public.olist_orders_dataset
WHERE order_status = 'delivered';
--Permite o time de logística identificar gargalos.


-- 2. Classificar clientes por faixa de gasto total: "bronze", "prata", "ouro".
/*SELECT AVG(gasto_top50.gasto_total) AS media_dos_50_mais_caros
FROM (
    SELECT SUM(i.price) AS gasto_total
    FROM public.olist_orders_dataset o
    INNER JOIN public.olist_order_items_dataset i ON o.order_id = i.order_id
    GROUP BY o.customer_id
    ORDER BY gasto_total DESC
    LIMIT 50
) gasto_top50;

SELECT AVG(gasto_bottom50.gasto_total) AS media_dos_50_mais_baratos
FROM (
    SELECT SUM(i.price) AS gasto_total
    FROM public.olist_orders_dataset o
    INNER JOIN public.olist_order_items_dataset i ON o.order_id = i.order_id
    GROUP BY o.customer_id
    ORDER BY gasto_total ASC
    LIMIT 50
) gasto_bottom50;

SELECT AVG(gasto_cliente.total) AS media_total_da_base
FROM (
    SELECT SUM(items.price) AS total
    FROM public.olist_orders_dataset ord
    INNER JOIN public.olist_order_items_dataset items ON ord.order_id = items.order_id
    GROUP BY ord.customer_id
) gasto_cliente;*/

SELECT 
    o.customer_id,
    SUM(i.price) AS gasto_total,
    CASE 
        WHEN SUM(i.price) >= 500 THEN 'ouro'
        WHEN SUM(i.price) >= 150 AND SUM(i.price) < 500 THEN 'prata'
        ELSE 'bronze'
    END AS categoria_cliente
FROM public.olist_orders_dataset o
INNER JOIN public.olist_order_items_dataset i 
    ON o.order_id = i.order_id
GROUP BY o.customer_id
ORDER BY gasto_total DESC;

--Permite o time de vendas melhorar o relacionamento com os clientes e criar programas de incentivos.

-- 3. Classificar produtos por faixa de peso: "leve", "médio", "pesado" (com base em product_weight_g).
SELECT 
    product_id,
    product_category_name,
    product_weight_g,
    CASE 
        WHEN product_weight_g >= 10000 THEN 'pesado'
        WHEN product_weight_g >= 2000 AND product_weight_g < 10000 THEN 'médio'
        ELSE 'leve'
    END AS classificacao_peso
FROM public.olist_products_dataset
WHERE product_weight_g IS NOT NULL;


-- 4. Classificar pagamentos como "à vista" ou "parcelado", e dentro de parcelado sinalizar parcelamentos longos.
SELECT 
    order_id,
    payment_type,
    payment_installments,
    CASE 
        WHEN payment_installments = 1 THEN 'à vista'
        WHEN payment_installments > 1 AND payment_installments <= 6 THEN 'parcelado curto'
        ELSE 'parcelado longo'
    END AS tipo_parcelamento
FROM public.olist_order_payments_dataset;
--Permite observar padrões de pagamento e melhorar negociações com intermediárias e consumidores.
