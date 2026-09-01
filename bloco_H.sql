-- Bloco H — Procedure de leitura 

--1. Criar a procedure/function sp_relatorio_vendedor(id_vendedor,
--data_inicio, data_fim), que retorna faturamento, ticket médio e nota média
--de avaliação do vendedor no período informado — sem alterar nenhum dado.

CREATE OR REPLACE FUNCTION sp_relatorio_vendedor(
    p_id_vendedor VARCHAR,
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP
)
RETURNS TABLE (
    faturamento NUMERIC,
    ticket_medio NUMERIC,
    nota_media NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(oi.price), 0)::NUMERIC AS faturamento,
        COALESCE(AVG(oi.price), 0)::NUMERIC AS ticket_medio,
        COALESCE(AVG(r.review_score), 0)::NUMERIC AS nota_media
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
    WHERE oi.seller_id = p_id_vendedor
      AND o.order_purchase_timestamp::timestamp BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- COMANDO PARA TESTAR A FUNÇÃO 1:
SELECT * FROM sp_relatorio_vendedor('cc419e0650a3c5ba77189a1882b7556a', '2016-01-01', '2019-12-31');

--Esta consulta nos permite ver o faturamento e a nota do vendedor, ajudando o time de vendas a avaliar o desempenho.]

--2. Criar a procedure/function sp_relatorio_categoria(categoria,
--data_inicio, data_fim), que retorna faturamento total e ticket médio da
--categoria de produto no período informado.

CREATE OR REPLACE FUNCTION sp_relatorio_categoria(
    p_categoria VARCHAR,
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP
)
RETURNS TABLE (
    faturamento_total NUMERIC,
    ticket_medio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(oi.price), 0)::NUMERIC AS faturamento_total,
        COALESCE(AVG(oi.price), 0)::NUMERIC AS ticket_medio
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
    WHERE (p.product_category_name = p_categoria OR t.product_category_name_english = p_categoria)
      AND o.order_purchase_timestamp::timestamp BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- COMANDO PARA TESTAR A FUNÇÃO 2:
SELECT * FROM sp_relatorio_categoria('beleza_saude', '2017-01-01', '2017-12-31');

--Essa consulta permite que o time de vendas tenha um parâmetro se o ticket médio está alinhado ao faturamento.
