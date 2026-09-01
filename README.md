###  Desafio SQL - E-Commerce Olist

Resolução dos desafios de banco de dados da GrowMarket utilizando dados reais e anonimizados da plataforma Olist (2016-2018). O objetivo principal do projeto é aplicar o SQL (DQL) na prática para extrair valor e responder a perguntas reais de negócio.

---

###  Desafios Técnicos & Aprendizados Práticos

Durante a resolução do desafio, enfrentei problemas reais de infraestrutura, tipagem e modelagem de dados, desenvolvendo maturidade técnica para solucioná-los:

* **Resolução de Erros de Ingestão em Lote:** No início, erros de formatação nos arquivos de texto (como o de avaliações) travaram a importação e deixaram tabelas vazias. Para resolver, utilizei o comando `TRUNCATE TABLE` para limpar os resíduos e reconfigurei o DBeaver para desabilitar o processamento em lote (`Desabilitar lotes = Sim`), importando o CSV linha por linha com sucesso.
* **Tratamento de Escala Métrica no Banco de Dados:** O desafio pedia para filtrar produtos acima de 10kg, mas o banco armazena o peso em gramas. Realizei a conversão matemática diretamente na regra do filtro (`10kg = 10000g`) dentro da cláusula `WHERE` para garantir a precisão do resultado.
* **Lógica Temporal para Dados Recentes:** Compreendi que, para o banco de dados, datas mais novas/futuras possuem valores logicamente "maiores". Portanto, para rastrear as entregas mais recentes, a ordenação correta exige o uso de `ORDER BY DESC`.
* **Inclusão de Colunas de Contexto vs. Performance:** No relatório de pedidos atrasados, balanceei a performance trazendo dados essenciais de identificação (ID do pedido, do cliente e cidade). Um relatório de atrasos sem contexto é inútil; essas colunas permitem que a equipe operacional saiba exatamente quem cobrar.
* **A Curva de Aprendizado com a Cláusula HAVING:** Na tentativa de filtrar vendedores por nota média, o erro do banco me forçou a estudar a ordem de execução do SQL. Aprendi que filtros em resultados de funções agregadas (`AVG`, `SUM`) só podem ser aplicados após o agrupamento das linhas, exigindo a cláusula `HAVING` em vez do `WHERE`.
* **Aprofundamento em PL/pgSQL (Bloco H):** O Bloco H introduziu conceitos não abordados no curso básico. Precisei estudar do zero a linguagem procedural do PostgreSQL, compreendendo o uso dos delimitadores `$$` (cifrão-cifrão) para isolar o escopo do código e a função `COALESCE` para substituir valores nulos por `0`, impedindo que os relatórios quebrassem na ausência de dados.
* **Ajuste Técnico de Tipagem (Bloco I):** Ao calcular o percentual de participação de receita, o banco gerou o tipo flutuante `DOUBLE PRECISION`, que impedia o funcionamento da função de arredondamento. Contornei o problema de forma simples: multipliquei o valor individual por `100.0` antes da divisão e apliquei a conversão explícita `::NUMERIC`, permitindo que o `ROUND(..., 2)` formatasse as casas decimais perfeitamente.

---

###  Insights de Entrega & Homologação

A partir do desenvolvimento do **Bloco H** (e estendendo para os blocos mais complexos como **Bloco F — CTEs** e **Bloco G — Views**), tive um insight crítico sobre a experiência do usuário que iria avaliar este projeto. 

Percebi que apenas criar as estruturas (`CREATE FUNCTION` ou `CREATE VIEW`) faria com que o banco apenas respondesse "sucesso" ou gerasse telas de estatísticas de execução. Para o avaliador, isso tornaria a validação cansativa, pois ele precisaria construir seus próprios comandos de busca ou adivinhar IDs válidos para ver os códigos em ação.

**O que eu fiz para resolver isso:**
* Voltei nos blocos anteriores (F, G e H) e adicionei comandos `SELECT` de teste comentados e prontos para o uso logo abaixo de cada exercício.
* Garanti que esses comandos utilizassem parâmetros reais encontrados na base (como IDs de vendedores ativos e categorias com dados populados).
* Transformei os scripts em arquivos "prontos para homologação". O avaliador só precisa selecionar a linha do `SELECT` de teste e rodar para ver o resultado consolidado na tela de forma instantânea.

---

###  Insights Reais da Exploração por Bloco

#### Bloco A — SELECT Básico
* **Pedidos Recentes:** Filtrar por status *delivered* e ordenar por data traz as entregas mais frescas para monitorar a eficiência operacional atual da transportadora.
* **Variedade do Site:** Descobrimos mais de 70 categorias diferentes na plataforma, mostrando que o ecossistema Olist é altamente diversificado e não depende de um único nicho.
* **Formas de Pagamento:** Usando o `DISTINCT`, identifiquei 5 tipos de pagamento. A presença do tipo *not_defined* acendeu um alerta para o time de engenharia checar possíveis falhas de integração no fluxo de checkout.
* **Carga Pesada:** Isolar produtos com mais de 10kg ajuda a equipe de logística a negociar fretes e contratos especiais para grandes volumes.

#### Bloco B — JOINs
* **Novos Centros de Distribuição:** Cruzar categorias de produtos vendidos com a localização geográfica do vendedor ajuda a decidir estrategicamente onde abrir novos galpões de estoque (Fulfillment).
* **Rastreando Atrasos:** Comparando a data real com a estimada, localizamos os gargalos logísticos. Isso ajuda o time de Customer Experience a cobrar satisfações e melhorias das transportadoras certas.
* **Fluxo de Caixa:** Analisar o parcelamento de cada pedido permite que o time financeiro faça uma previsão de recebíveis muito mais assertiva para os meses seguintes.
* **Limpeza do Catálogo:** O uso do `LEFT JOIN` com a tabela de tradução revelou produtos com a categoria nula (`NULL`), gerando uma lista imediata para o time de cadastro corrigir as traduções ausentes.
* **Vendas Locais:** Descobrir transações onde cliente e vendedor estão no mesmo estado apoia a criação de campanhas de frete grátis ou entrega no mesmo dia (*same-day delivery*).

#### Bloco C — Funções Agregadas & Agrupamentos
* **Proteção do Valor da Marca:** Mapear vendedores com notas médias crônicas abaixo de 3 gera uma análise de valor intangível. O objetivo não é o lucro imediato, mas sim agir preventivamente para proteger a reputação da marca.
* **Organização em Análises de Crédito:** No relatório de parcelamentos por categoria, ordenar de forma decrescente (`ORDER BY DESC`) destaca no topo os produtos onde os clientes mais dependem de crédito longo, direcionando a estratégia de parcerias financeiras.

#### Bloco D — Subqueries
* **Fidelização de Clientes VIPs:** No Exercício 1, a ordenação decrescente dos gastos totais dos clientes isola instantaneamente as contas de alto valor (*High-Value Customers*), permitindo focar esforços em campanhas de retenção exclusivas.
* **Gamificação contra Produtos Esquecidos:** A identificação de produtos que nunca receberam avaliação (Exercício 2) trouxe um insight prático de marketing: direcionar campanhas com sistemas de cupons ou moedas digitais em troca de feedbacks para resgatar esses produtos do anonimato.

#### Bloco F, G e H — CTEs, Views e Procedures
* **Encapsulamento de Regras de Negócio (Bloco H):** Compreendi o valor real das procedures no dia a dia corporativo. Elas funcionam como "fórmulas inteligentes". Em vez de obrigar o time de vendas ou marketing a escrever queries complexas com múltiplos JOINs toda vez que precisarem de um dado, criamos relatórios parametrizados onde eles passam apenas filtros simples (como um ID e um período de datas).

#### Bloco I — Window Functions
* **Identificação de Monopólios Locais:** O cálculo do percentual de participação de receita cruzando o `SUM() OVER` com partições por estado permitiu ao time de marketing mapear quais vendedores dominam as vendas regionais e onde há espaço para novos parceiros crescerem.
* **Linha do Tempo Comercial:** Com o uso da função analítica `LAG()`, conseguimos colocar o faturamento atual e o faturamento passado de um vendedor lado a lado. Isso criou um monitoramento de performance histórico indispensável para o time comercial identificar quedas bruscas de desempenho de um mês para o outro.
