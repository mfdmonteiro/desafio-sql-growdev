--Desafio SQL
--Bloco A - Select Básico

--1. Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de
--entrega.
SELECT * 
FROM public.olist_orders_dataset 
WHERE order_status = 'delivered'
ORDER BY order_delivered_customer_date DESC 
LIMIT 20;
--Essa consulta permite o time de logística identificar os deliveries mais recentes, 
--podendo assim monitorar a eficiência destes.

--2. Listar todos os produtos de uma categoria específica (usando a tabela de tradução
--para filtrar pelo nome em português).

SELECT * 
FROM public.olist_products_dataset 
WHERE product_category_name = 'beleza_saude';
--Essa consulta pode auxiliar o time de marketing e vendas 
--no planejamento de campanhas focadas em categorias específicas
--e também o time de logística em casos de armazenagem específicas
--com volumetria crescente.

--3. Listar os métodos de pagamento distintos utilizados na base

SELECT DISTINCT payment_type 
FROM public.olist_order_payments_dataset;
--Com essa base de dados é possível uma negociação eficiente de taxas
--com os intermediadores. 

--4. Listar os produtos com pesonacima de 10kg, ordenados do
--mais pesado para o mais leve.

SELECT * 
FROM public.olist_products_dataset 
WHERE product_weight_g > 10000
ORDER BY product_weight_g DESC;
--Planejamento de logística e cálculo de frete eficientes.


