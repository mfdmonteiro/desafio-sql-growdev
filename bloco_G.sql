--Bloco G — View

--1. Criar a view vw_pedidos_completos, consolidando pedido, cliente, itens,
--pagamento e vendedor, para servir de base a consultas analíticas futuras.

CREATE OR REPLACE VIEW vw_pedidos_completos AS 
SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.customer_id,
    i.product_id,
    i.price,
    i.freight_value,
    p.payment_type,
    p.payment_value,
    i.seller_id
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset i ON o.order_id = i.order_id
LEFT JOIN olist_order_payments_dataset p ON o.order_id = p.order_id;

-- Comando para testar e visualizar a View em ação:
SELECT * FROM vw_pedidos_completos LIMIT 20;

--Esta view consolida as principais métricas de vendas e pagamentos de um pedido em um único lugar.
-- Ela simplifica análises futuras de faturamento, ticket médio e performance de produtos e vendedores.

--2. Criar a view vw_avaliacoes_categoria, consolidando nota média e volume de
--avaliações por categoria de produto.

CREATE OR REPLACE VIEW vw_avaliacoes_categoria AS
SELECT 
    p.product_category_name AS categoria_produto,
    COUNT(r.review_id) AS volume_avaliacoes,
    ROUND(AVG(r.review_score::numeric), 2) AS nota_media
FROM public.olist_order_items_dataset i
INNER JOIN public.olist_products_dataset p ON i.product_id = p.product_id
INNER JOIN public.olist_order_reviews_dataset r ON i.order_id = r.order_id
GROUP BY p.product_category_name;

-- Comando para testar e visualizar a View em ação:
SELECT * FROM vw_pedidos_completos LIMIT 20;


-- Essa consulta permite a análise de quais categorias precisam de aprimoramento.
