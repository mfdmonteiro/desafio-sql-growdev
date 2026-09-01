-- BLOCO F - CTE / TABELA TEMPORÁRIA

-- 1. Construir uma CTE de faturamento mensal por estado e, a partir dela, calcular a variação percentual de um mês para o outro.


WITH faturamento_mensal AS (
    SELECT 
        c.customer_state AS estado,
        LEFT(o.order_purchase_timestamp, 7) AS ano_mes,
        SUM(i.price::numeric) AS faturamento
    FROM public.olist_orders_dataset o
    INNER JOIN public.olist_customers_dataset c ON o.customer_id = c.customer_id
    INNER JOIN public.olist_order_items_dataset i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state, LEFT(o.order_purchase_timestamp, 7)
),
comparativo_mes AS (
    SELECT 
        estado,
        ano_mes,
        faturamento,
        LAG(faturamento) OVER(PARTITION BY estado ORDER BY ano_mes) AS faturamento_anterior
    FROM faturamento_mensal
)
SELECT 
    estado,
    ano_mes,
    faturamento,
    faturamento_anterior,
    ROUND(((faturamento - faturamento_anterior) / faturamento_anterior) * 100, 2) AS variacao_percentual
FROM comparativo_mes
WHERE faturamento_anterior IS NOT NULL AND faturamento_anterior > 0
ORDER BY estado, ano_mes;

--Essa consulta permite que o financeiro tenha previsões mais acertivas sobre o fluxo de caixa.

--2. Construir uma CTE com volume de avaliações e nota média por categoria de
--produto, usada para identificar as categorias com pior reputação (nota média mais
--baixa e volume relevante de avaliações).

WITH reputacao_categoria AS (
    SELECT 
        p.product_category_name AS categoria_produto,
        COUNT(r.review_id) AS volume_avaliacoes,
        AVG(r.review_score::numeric) AS nota_media
    FROM public.olist_order_items_dataset i
    INNER JOIN public.olist_products_dataset p ON i.product_id = p.product_id
    INNER JOIN public.olist_order_reviews_dataset r ON i.order_id = r.order_id
    GROUP BY p.product_category_name
)
SELECT 
    categoria_produto,
    volume_avaliacoes,
    ROUND(nota_media, 2) AS nota_media_arredondada
FROM reputacao_categoria
WHERE volume_avaliacoes > 100 
ORDER BY nota_media_arredondada ASC;

--Permite que a marca trabalhe para melhorar os produtos com menor avaliação
--a fim de proteger seus valores intangíveis.

-- 3. Construir uma CTE de frete médio por estado para comparar com a média geral.

WITH frete_por_estado AS (
    SELECT 
        c.customer_state AS estado,
        AVG(i.freight_value::numeric) AS frete -- Mudamos o apelido para 'frete'
    FROM public.olist_orders_dataset o
    INNER JOIN public.olist_customers_dataset c ON o.customer_id = c.customer_id
    INNER JOIN public.olist_order_items_dataset i ON o.order_id = i.order_id
    GROUP BY c.customer_state
),
frete_geral AS (
    SELECT AVG(i.freight_value::numeric) AS frete_geral_brasil -- Mudamos aqui também
    FROM public.olist_order_items_dataset i
)
SELECT 
    e.estado,
    ROUND(e.frete, 2) AS frete_do_estado, -- Agora chamamos apenas e.frete
    ROUND(g.frete_geral_brasil, 2) AS frete_geral_brasil,
    ROUND(e.frete - g.frete_geral_brasil, 2) AS diferenca_do_frete
FROM frete_por_estado e
CROSS JOIN frete_geral g
ORDER BY diferenca_do_frete DESC;
--Essa tabela permite analisar quais as geolocalizações que apresentam gargalos 
--estruturais de logística.

