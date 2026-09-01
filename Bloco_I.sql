--Bloco I — Window functions

-- 1. Ranking de Vendedores por Estado

SELECT 
    s.seller_state AS estado,
    s.seller_id AS id_vendedor,
    SUM(oi.price) AS faturamento_vendedor,
    RANK() OVER (
        PARTITION BY s.seller_state 
        ORDER BY SUM(oi.price) DESC
    ) AS posicao_ranking
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state, s.seller_id
ORDER BY s.seller_state ASC, posicao_ranking ASC;

--Essa consulta permite que o time de vendas crie estratégias de incentivos regionais.

-- 2. Faturamento Mensal Acumulado por Vendedor-- Pergunta de Negócio: Como o faturamento de cada vendedor evoluiu mês a mês ao longo do tempo?

SELECT 
    oi.seller_id AS id_vendedor,
    TO_CHAR(o.order_purchase_timestamp::timestamp, 'YYYY-MM') AS ano_mes,
    SUM(oi.price) AS faturamento_do_mes,
    SUM(SUM(oi.price)) OVER (
        PARTITION BY oi.seller_id 
        ORDER BY TO_CHAR(o.order_purchase_timestamp::timestamp, 'YYYY-MM')
    ) AS faturamento_acumulado
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
GROUP BY oi.seller_id, TO_CHAR(o.order_purchase_timestamp::timestamp, 'YYYY-MM')
ORDER BY oi.seller_id, ano_mes;

-- Essa consulta calcula a receita acumulada passo a passo, permitindo que o financeiro veja o crescimento histórico de cada parceiro.

-- 3. Percentual de Participação do Vendedor no Estado

WITH faturamento_por_vendedor AS (
    SELECT 
        s.seller_state AS estado,
        s.seller_id AS id_vendedor,
        SUM(oi.price) AS faturamento_individual
    FROM olist_order_items_dataset oi
    JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
    GROUP BY s.seller_state, s.seller_id
)
SELECT 
    estado,
    id_vendedor,
    faturamento_individual,
    SUM(faturamento_individual) OVER (PARTITION BY estado) AS faturamento_total_estado,
    ROUND(((faturamento_individual * 100.0) / SUM(faturamento_individual) OVER (PARTITION BY estado))::NUMERIC, 2) AS percentual_participacao
FROM faturamento_por_vendedor
ORDER BY estado ASC, faturamento_individual DESC;

--Essa métrica ajuda o time de marketing e vendas saberem o comportamento do consumidor e quem vende mais em cada região.

-- 4. Variação de Faturamento Mensal por Vendedor

WITH faturamento_mensal AS (
    SELECT 
        oi.seller_id AS id_vendedor,
        TO_CHAR(o.order_purchase_timestamp::timestamp, 'YYYY-MM') AS ano_mes,
        SUM(oi.price) AS faturamento_atual
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id, TO_CHAR(o.order_purchase_timestamp::timestamp, 'YYYY-MM')
),
comparativo_mes_anterior AS (
    SELECT 
        id_vendedor,
        ano_mes,
        faturamento_atual,
        LAG(faturamento_atual) OVER (
            PARTITION BY id_vendedor 
            ORDER BY ano_mes
        ) AS faturamento_mes_anterior
    FROM faturamento_mensal
)
SELECT 
    id_vendedor,
    ano_mes,
    faturamento_atual,
    COALESCE(faturamento_mes_anterior, 0) AS faturamento_mes_anterior,
    (faturamento_atual - COALESCE(faturamento_mes_anterior, 0)) AS variacao_financeira
FROM comparativo_mes_anterior
ORDER BY id_vendedor, ano_mes;

--Essa consulta traz indicador essencial para o comercial monitorar quedas de desempenho.
