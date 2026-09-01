-- BLOCO D - SUBQUERIES

-- 1. Clientes cujo gasto total está acima da média geral de gasto por cliente.
SELECT 
    o.customer_id,
    SUM(i.price) AS gasto_total
FROM public.olist_orders_dataset o
INNER JOIN public.olist_order_items_dataset i 
    ON o.order_id = i.order_id
GROUP BY o.customer_id
HAVING SUM(i.price) > (
SELECT AVG(gasto_cliente.total)
    FROM (
        SELECT SUM(items.price) AS total
        FROM public.olist_orders_dataset ord
        INNER JOIN public.olist_order_items_dataset items 
            ON ord.order_id = items.order_id
        GROUP BY ord.customer_id
    ) gasto_cliente
)
ORDER BY gasto_total DESC;
--Essa consulta permite o time de vendas melhorar o relacionamento com os clientes.

-- 2. Produtos que nunca receberam avaliação (NOT EXISTS / NOT IN).
SELECT product_id, product_category_name
FROM public.olist_products_dataset
WHERE product_id NOT IN (
	SELECT DISTINCT i.product_id
    FROM public.olist_order_items_dataset i
    INNER JOIN public.olist_order_reviews_dataset r 
        ON i.order_id = r.order_id
);
--Permite o melhor direcionamento de estratégias para resolver esse gargalo.

-- 3. Vendedores que venderam produtos de mais de 5 categorias diferentes.
SELECT vendedor_id, total_categorias
FROM (
    SELECT 
        i.seller_id AS vendedor_id,
        COUNT(DISTINCT p.product_category_name) AS total_categorias
    FROM public.olist_order_items_dataset i
    INNER JOIN public.olist_products_dataset p 
        ON i.product_id = p.product_id
    GROUP BY i.seller_id
) categorias_por_vendedor
WHERE total_categorias > 5
ORDER BY total_categorias DESC;
--Permite um mapeamento de vendedores com a maior variedade de produtos o que enriquece o relacionamento B2B.

-- 4. Pedidos cujo valor de frete (freight_value) é maior que o valor total dos itens do próprio pedido (subquery correlacionada comparando as duas somas).
SELECT 
    i.order_id,
    SUM(i.freight_value) AS frete_total,
    SUM(i.price) AS produto_total
FROM public.olist_order_items_dataset i
GROUP BY i.order_id
HAVING SUM(i.freight_value) > SUM(i.price)
ORDER BY frete_total DESC;
--Permite identificar padrões desse gargalo e redirecionar para soluções inteligentes de logística.



