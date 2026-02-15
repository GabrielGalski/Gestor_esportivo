USE gestao_clube;

-- ============================================
-- 1. CONSULTA: Dados Públicos Consolidados
-- ============================================
/*
apresenta um resumo financeiro agregado por conta contábil e mês/ano,
mostrando totais de entradas, saídas e saldo líquido. exibe
apenas dados consolidados sem detalhes sensíveis de lançamentos individuais.

agrupa os lançamentos aprovados por conta e período (mês/ano), somando valores
de entrada e saída separadamente. Calcula o saldo líquido considerando entradas como
positivas e saídas como negativas. Ordena do período mais recente para o mais antigo.
*/
SELECT * FROM dados_publicos;


-- ============================================
-- 2. CONSULTA: Dados Privados Detalhados
-- ============================================
/*
expõe todos os detalhes de cada lançamento aprovado individualmente,
incluindo informações sensíveis como origem do lançamento, aprovador e descrições completas.
Tem perfil privado pois permite rastreabilidade completa das operações financeiras.

faz JOIN entre lancamento, plano_de_contas e direcao para trazer informações completas
de cada lançamento aprovado. Permite auditar quem aprovou, quando e de onde veio cada
movimentação financeira. Ordena do mais recente para o mais antigo.

*/
SELECT * FROM dados_privados;


-- ============================================
-- 3. CONSULTA: Resumo do Elenco
-- ============================================
/*
imprime os dados completos de cada jogador do elenco, incluindo dados
contratuais e histórico financeiro acumulado.

faz LEFT JOIN entre elenco, item_folha_e e folha_elenco para agregar todos os pagamentos
já realizados a cada jogador. Calcula automaticamente quantos dias faltam para o contrato
expirar usando DATEDIFF. Agrupa por jogador somando valores líquidos pagos.

*/
SELECT * FROM resumo_elenco;


-- ============================================
-- 4. CONSULTA: Resumo dos Funcionários
-- ============================================
/*
resume informações de todos os funcionários administrativos do clube,
diferenciando entre contratados CLT e terceirizados, com histórico de pagamentos.

junta dados das tabelas funcionarios, contratado e terceirizado através de LEFT JOINs
para capturar tanto CLT quanto terceirizados. Agrega valores da folha de pagamento
somando todos os valores líquidos pagos a cada funcionário. Agrupa por funcionário.

*/
SELECT * FROM resumo_funcionarios;


-- ============================================
-- 5. CONSULTA: Ativo Imobilizado Mensal
-- ============================================
/*
evolução mensal do patrimônio imobilizado do clube, mostrando
tanto o valor de aquisição quanto o valor contábil após depreciação dos bens.

Agrega dados da tabela ativo_imobilizado por mês,ano e tipo, somando valores totais
e contábeis. Considera apenas relatórios com status concluido ou auditado, garantindo
que apenas informações validadas sejam exibidas. 

*/
SELECT * FROM ativo_imobilizado_mensal;


-- ============================================
-- 6. CONSULTA: Detalhamento de Bens
-- ============================================
/*
lista de todos os bens patrimoniais aprovados do clube e calculo da depreciação acumulada.

LEFT JOINs com as tabelas imoveis, moveis e automoveis para classificar cada bem.
Calcula automaticamente o valor contábil atual aplicando a taxa de depreciação anual
multiplicada pelos anos decorridos desde a aquisição. Usa CASE para determinar o tipo.
Filtra apenas bens com status 'aprovado'.

*/
SELECT * FROM detalhamento_bens;


-- ============================================
-- 7. CONSULTA: Análise de Orçamento Mensal 
-- ============================================
/*
monitor mensal da execução orçamentária do departamento esportivo,
comparando o orçamento previsto com os gastos reais da folha de elenco e calculando
o percentual de utilização.

junta dados de folha_elenco com corpo_esportivo para comparar gastos reais vs orçamento.
Considera apenas folhas com status aprovado ou pago. Agrupa por período e calcula
automaticamente o saldo (orçamento - gasto) e o percentual (gasto/orçamento * 100).

*/
SELECT * FROM analise_orcamento_mensal;


-- ============================================
-- 8. CONSULTA: Lançamentos Detalhados com Responsáveis
-- ============================================
/*
todos os lançamentos do sistema com informações completas sobre
quem registrou, quem aprovou e em qual conta contábil foi classificado, permitindo
organização das operações financeiras.

múltiplos JOINs entre lancamento, plano_de_contas e direcao (duas vezes: uma para
responsável, outra para aprovador). Traz informações completas de cada transação,
permitindo auditar toda a cadeia de responsabilidade. Ordena da transação mais recente
para a mais antiga.
*/
SELECT 
    l.id_lancamento,
    l.data_registro,
    l.valor,
    l.tipo_de_movimentacao,
    l.descricao,
    l.origem,
    l.status_aprovacao,
    pc.codigo_conta,
    pc.descricao AS conta_descricao,
    d.nome AS responsavel_lancamento,
    aprovador.nome AS nome_aprovador,
    l.data_aprovacao
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
INNER JOIN direcao d ON l.id_direcao = d.id_direcao
LEFT JOIN direcao aprovador ON l.id_aprovador = aprovador.id_direcao
ORDER BY l.data_registro DESC;


-- ============================================
-- 9. CONSULTA: Média de Folha Anual
-- ============================================
/*
compara anualmente os custos com folha de pagamento do elenco versus
funcionários administrativos, calculando valores médios e totais para análise de
distribuição de custos.

usa UNION ALL para combinar dados de duas fontes (folha_elenco e folha_funcionarios)
em um único resultado. Para cada tipo, agrupa por ano, conta quantas folhas foram pagas,
calcula a média dos valores e soma o total anual. Considera apenas folhas com status
'aprovado' ou 'pago'. Ordena por ano (mais recente primeiro) e tipo.

*/
SELECT * FROM media_folha_anual;


-- ============================================
-- 10. CONSULTA: Movimentação Detalhada por Conta e Período
-- ============================================
/*
extrato completo de cada conta do plano de contas, agrupado
por mês/ano, mostra quantidade de lançamentos, totais de entradas, saídas e saldo
do período. Funciona como um extrato para cada conta contábil.

LEFT JOIN entre plano_de_contas e lancamento para garantir que todas as contas
apareçam. Agrupa por conta e período, contando lançamentos e somando valores separadamente para entradas e saídas. 
Calcula o saldo considerando entradas como positivas e saídas como negativas. Considera apenas lançamentos aprovados.
Ordena por período (mais recente) e código da conta.

*/
SELECT 
    pc.codigo_conta,
    pc.descricao,
    pc.tipo_conta,
    DATE_FORMAT(l.data_registro, '%Y-%m') AS mes_ano,
    COUNT(l.id_lancamento) AS total_lancamentos,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END) AS total_saidas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE -l.valor END) AS saldo_periodo
FROM plano_de_contas pc
LEFT JOIN lancamento l ON pc.id_conta = l.id_conta AND l.status_aprovacao = 'aprovado'
GROUP BY pc.id_conta, pc.codigo_conta, pc.descricao, pc.tipo_conta, DATE_FORMAT(l.data_registro, '%Y-%m')
ORDER BY mes_ano DESC, pc.codigo_conta;


-- ============================================
-- 11. CONSULTA: Total de Patrimônio Imobilizado Atual
-- ============================================
/*
calcula o valor total do patrimônio do clube separado por tipo de bem,
considerando a depreciação acumulada para apresentar o valor atual.
*/

SELECT 
    tipo_bem,
    COUNT(*) AS quantidade_bens,
    SUM(valor_aquisicao) AS valor_total_aquisicao,
    SUM(valor_contabil_atual) AS valor_total_contabil_atual,
    SUM(valor_aquisicao - valor_contabil_atual) AS depreciacao_acumulada
FROM detalhamento_bens
GROUP BY tipo_bem
ORDER BY valor_total_contabil_atual DESC;


-- ============================================
-- 12. CONSULTA: Balanço Mensal Simplificado
-- ============================================
/*
balanço simplificado mensal mostrando total de receitas, despesas e resultado de cada mês, agrupando lançamentos aprovados por mês, 
separa e soma receitas e despesas, calcula o resultado do periodo.
*/

SELECT 
    DATE_FORMAT(data_registro, '%Y-%m') AS mes_ano,
    YEAR(data_registro) AS ano,
    MONTH(data_registro) AS mes,
    SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN tipo_de_movimentacao = 'saida' THEN valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE -valor END) AS resultado_periodo
FROM lancamento
WHERE status_aprovacao = 'aprovado'
GROUP BY YEAR(data_registro), MONTH(data_registro), DATE_FORMAT(data_registro, '%Y-%m')
ORDER BY ano DESC, mes DESC;

-- ============================================
-- 13. CONSULTA: Resumo Financeiro Trimestral Consolidado
-- ============================================
/*
mostra todas as movimentações financeiras dos últimos 3 meses, 
separando por tipo de conta e calculando saldos.

Agrupa lançamentos aprovados por tipo de conta, somando entradas e saídas
separadamente. Calcula margem líquida e percentual de cada categoria sobre
o total.
*/
SELECT 
    pc.tipo_conta,
    pc.codigo_conta,
    pc.descricao AS conta,
    COUNT(l.id_lancamento) AS qtd_lancamentos,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END) AS total_saidas,
    (SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) -
     SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END)) AS saldo_liquido,
    ROUND(
        (SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) /
         NULLIF((SELECT SUM(valor) FROM lancamento WHERE tipo_de_movimentacao = 'entrada' 
                 AND status_aprovacao = 'aprovado' 
                 AND data_registro >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)), 0)) * 100,
        2
    ) AS percentual_receitas,
    ROUND(
        (SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END) /
         NULLIF((SELECT SUM(valor) FROM lancamento WHERE tipo_de_movimentacao = 'saida' 
                 AND status_aprovacao = 'aprovado' 
                 AND data_registro >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)), 0)) * 100,
        2
    ) AS percentual_despesas,
    DATE_FORMAT(MIN(l.data_registro), '%d/%m/%Y') AS primeira_movimentacao,
    DATE_FORMAT(MAX(l.data_registro), '%d/%m/%Y') AS ultima_movimentacao
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
WHERE l.status_aprovacao = 'aprovado'
    AND l.data_registro >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY 
    pc.tipo_conta,
    pc.codigo_conta,
    pc.descricao
ORDER BY 
    pc.tipo_conta,
    saldo_liquido DESC;

-- ============================================
-- 14. CONSULTA: Alerta de Orçamento Crítico
-- ============================================
/*
Orçamento Crítico: Dispara quando o orçamento do elenco
em algum mes atinge 80% do orçamento disponivel.
*/

SELECT 
    DATE_FORMAT(data_registro, '%Y-%m') AS mes_ano,
    YEAR(data_registro) AS ano,
    MONTH(data_registro) AS mes,
    SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN tipo_de_movimentacao = 'saida' THEN valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE -valor END) AS resultado_periodo,
    ABS(SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE -valor END)) AS deficit,
    CONCAT('R$ ', FORMAT(ABS(SUM(CASE WHEN tipo_de_movimentacao = 'entrada' THEN valor ELSE -valor END)), 2, 'pt_BR')) AS deficit_formatado
FROM lancamento
WHERE status_aprovacao = 'aprovado'
GROUP BY YEAR(data_registro), MONTH(data_registro), DATE_FORMAT(data_registro, '%Y-%m')
HAVING resultado_periodo < 0
ORDER BY ano DESC, mes DESC;


