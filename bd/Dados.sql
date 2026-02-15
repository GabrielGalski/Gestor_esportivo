USE gestao_clube;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE alertas_orcamento;
TRUNCATE TABLE lancamento;
TRUNCATE TABLE relatorio_bens;
TRUNCATE TABLE ativo_imobilizado;
TRUNCATE TABLE item_folha_e;
TRUNCATE TABLE folha_elenco;
TRUNCATE TABLE item_folha_f;
TRUNCATE TABLE folha_funcionarios;
TRUNCATE TABLE elenco;
TRUNCATE TABLE moveis;
TRUNCATE TABLE automoveis;
TRUNCATE TABLE imoveis;
TRUNCATE TABLE bens;
TRUNCATE TABLE terceirizado;
TRUNCATE TABLE contratado;
TRUNCATE TABLE funcionarios;
TRUNCATE TABLE corpo_financeiro;
TRUNCATE TABLE corpo_esportivo;
TRUNCATE TABLE corpo_diretivo;
TRUNCATE TABLE direcao;
TRUNCATE TABLE plano_de_contas;
TRUNCATE TABLE clube;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- INSERÇÃO DE DADOS
-- ============================================

-- Clube
INSERT INTO clube (id_clube, nome_clube, data_de_fundacao, presidente_atual, chapa)
VALUES (1, 'Pelotas', '1908-10-11', 'Gabriel', 2);

-- Direção
INSERT INTO direcao (id_direcao, nome, email, senha, cpf, data_nascimento, data_cadastro, id_clube)
VALUES
(1, 'Vice Presidente', 'diretor.diretivo@pelotas.com.br', 'hash123', '12345678901', '1980-05-15', '2025-01-01 08:00:00', 1),
(2, 'Diretor Esportivo', 'diretor.esportivo@pelotas.com.br', 'hash456', '23456789012', '1985-08-22', '2025-01-01 08:00:00', 1),
(3, 'Diretor Financeiro', 'diretor.financeiro@pelotas.com.br', 'hash789', '34567890123', '1982-11-30', '2025-01-01 08:00:00', 1);

-- administração 
INSERT INTO corpo_diretivo (id_direcao, assinatura, data_homologacao)
VALUES (1, 'Gabriel Galski Machado - Diretor Presidente', '2025-01-01');

INSERT INTO corpo_esportivo (id_direcao, temporada, orcamento)
VALUES (2, '2025/2026', 500000.00);

INSERT INTO corpo_financeiro (id_direcao, orcamento)
VALUES (3, 200000.00);

-- contas do banco
INSERT INTO plano_de_contas (id_conta, codigo_conta, descricao, tipo_conta) VALUES
(1, '1.1.01', 'Caixa e Equivalentes', 'ativo'),
(2, '1.2.01', 'Imóveis', 'ativo'),
(3, '1.2.02', 'Veículos', 'ativo'),
(4, '1.2.03', 'Equipamentos', 'ativo'),
(6, '3.1.01', 'Receitas de Bilheteria', 'receita'),
(7, '3.1.02', 'Receitas de Patrocínio', 'receita'),
(8, '4.1.01', 'Despesas com Elenco', 'despesa'),
(9, '4.1.02', 'Despesas Administrativas', 'despesa');


-- inserção inicial para as operações

INSERT INTO lancamento (
    data_registro,
    valor,
    tipo_de_movimentacao,
    status_aprovacao,
    id_aprovador,
    data_aprovacao,
    id_direcao,
    id_conta,
    descricao,
    origem,
    id_origem
) VALUES (
    '2026-01-02 09:00:00',
    25000000.00,
    'entrada',
    'aprovado',
    1,
    '2026-01-02 09:00:00',
    1,
    1,
    'Aporte inicial no Caixa',
    'manual',
    NULL
);

-- Elenco
INSERT INTO elenco (nome_jogador, multa, funcao, inicio_contrato, fim_contrato, luvas, passe_data_contrato, id_direcao) VALUES
('Goleiro', 500000.00, 'Goleiro', '2024-01-10', '2027-12-31', 20000.00, '2024-01-10', 2),
('Zagueiro', 800000.00, 'Zagueiro', '2023-06-15', '2026-12-31', 35000.00, '2023-06-15', 2),
('Meia', 1200000.00, 'Meio-Campo', '2024-02-01', '2028-06-30', 50000.00, '2024-02-01', 2),
('Atacante', 1500000.00, 'Atacante', '2024-03-20', '2027-12-31', 60000.00, '2024-03-20', 2),
('Lateral', 900000.00, 'Lateral Direito', '2023-08-10', '2026-12-31', 30000.00, '2023-08-10', 2);

-- Funcionários
INSERT INTO funcionarios (id_contrato, salario, cargo, setor, tipo_funcionario, id_direcao) VALUES
('FUNC1', 12000.00, 'Gerente Administrativo', 'Administrativo', 'contratado', 3),
('FUNC2', 8000.00, 'Programador', 'TI', 'contratado', 3),
('FUNC3', 6000.00, 'Analista de Marketing', 'Marketing', 'contratado', 3),
('TERC1', 4500.00, 'Segurança', 'Infraestrutura', 'terceirizado', 3),
('TERC2', 5000.00, 'Serviços de Limpeza', 'Infraestrutura', 'terceirizado', 3);

-- Funcionários Contratados
INSERT INTO contratado (id_funcionario, data_admissao) VALUES
(1, '2020-03-15'),
(2, '2021-07-01'),
(3, '2022-09-10');

-- Funcionários Terceirizados
INSERT INTO terceirizado (id_funcionario, empresa_contratante, prazo_contrato, valor_contrato_total) VALUES
(4, 'Terceirizada1', 24, 108000.00),
(5, 'Terceirizada2', 12, 60000.00);

-- Bens Patrimoniais
INSERT INTO bens (data_aquisicao, nome_item, valor_aquisicao, localizacao, id_direcao, status_aprovacao) VALUES
('2015-05-10', 'Estádio', 15000000.00, 'Rua 1, 211 - Pelotas/RS', 3, 'aprovado'),
('2018-08-20', 'Centro de Treinamento', 3500000.00, 'Avenida 1, 1500 - Pelotas/RS', 3, 'aprovado'),
('2020-11-15', 'Ônibus da Delegação', 450000.00, 'Garagem CT', 3, 'aprovado'),
('2022-06-01', 'Van de Apoio', 180000.00, 'Garagem CT', 3, 'aprovado'),
('2023-01-20', 'Refletores', 85000.00, 'Estádio', 3, 'aprovado'),
('2023-07-10', 'Sistema de Som do Estádio', 120000.00, 'Estádio', 3, 'aprovado'),
('2024-03-15', 'Equipamentos de Musculação', 95000.00, 'Centro de Treinamento', 3, 'aprovado');

-- Imóveis
INSERT INTO imoveis (id_bem, endereco, area, tipo_propriedade, depreciacao_ano) VALUES
(1, 'Rua 1, 211 - Pelotas/RS', 45000.00, 'Estádio de Futebol', 2.00),
(2, 'Avenida 1, 1500 - Pelotas/RS', 25000.00, 'Centro de Treinamento', 2.00);

-- Automóveis
INSERT INTO automoveis (id_bem, tipo, placa, ano, modelo, depreciacao_ano) VALUES
(3, 'Ônibus', 'IQF-1234', 2020, 'Mercedes', 10.00),
(4, 'Van', 'IQG-5678', 2022, 'Renault', 15.00);

-- Móveis
INSERT INTO moveis (id_bem, depreciacao_ano) VALUES
(5, 10.00),
(6, 15.00),
(7, 20.00);

-- Folhas de Pagamento do Elenco (SEM valor_bruto - calculado via view)
INSERT INTO folha_elenco (data_competencia, data_pagamento, valor_direitos_imagem, status, id_direcao) VALUES
('2026-01-01', '2026-01-05', 12000.00, 'pendente', 2),
('2026-02-01', '2026-02-05', 12500.00, 'pendente', 2),
('2026-03-01', '2026-03-05', 12200.00, 'pendente', 2);

-- Itens da Folha de Elenco (SEM valor_liquido - calculado via view)
INSERT INTO item_folha_e (salario_base, bonus, direito_imagem, parcela_luvas, descontos, id_folha_elenco, id_elenco) VALUES
-- Folha 1 (Janeiro)
(12000.00, 1000.00, 2000.00, 500.00, 1700.00, 1, 1),
(18000.00, 1500.00, 2500.00, 800.00, 2400.00, 1, 2),
(25000.00, 3000.00, 3500.00, 1200.00, 3900.00, 1, 3),
(28000.00, 4000.00, 4000.00, 1500.00, 4300.00, 1, 4),
(20000.00, 2000.00, 2500.00, 1000.00, 2750.00, 1, 5),
-- Folha 2 (Fevereiro)
(12500.00, 1200.00, 2100.00, 500.00, 1900.00, 2, 1),
(18500.00, 1600.00, 2600.00, 800.00, 2500.00, 2, 2),
(26000.00, 3200.00, 3600.00, 1200.00, 4200.00, 2, 3),
(29000.00, 4200.00, 4100.00, 1500.00, 4500.00, 2, 4),
(20500.00, 2100.00, 2600.00, 1000.00, 2800.00, 2, 5),
-- Folha 3 (Março)
(12200.00, 1100.00, 2050.00, 500.00, 1750.00, 3, 1),
(18200.00, 1550.00, 2550.00, 800.00, 2450.00, 3, 2),
(25500.00, 3100.00, 3550.00, 1200.00, 4050.00, 3, 3),
(28500.00, 4100.00, 4050.00, 1500.00, 4500.00, 3, 4),
(20200.00, 2050.00, 2550.00, 1000.00, 2750.00, 3, 5);

-- Folhas de Pagamento de Funcionários (SEM valor_bruto - calculado via view)
INSERT INTO folha_funcionarios (data_pagamento, status, data_competencia, id_direcao) VALUES
('2026-01-05', 'pendente', '2026-01-01', 3),
('2026-02-05', 'pendente', '2026-02-01', 3),
('2026-03-05', 'pendente', '2026-03-01', 3);

-- Itens da Folha de Funcionários (SEM valor_liquido - calculado via view)
INSERT INTO item_folha_f (salario_base, bonus, descontos, adicionais, id_folha_funcionarios, id_funcionario) VALUES
-- Folha 1 (Janeiro)
(12000.00, 500.00, 1700.00, 0.00, 1, 1),
(8000.00, 300.00, 1100.00, 0.00, 1, 2),
(6000.00, 200.00, 800.00, 0.00, 1, 3),
(4500.00, 0.00, 450.00, 0.00, 1, 4),
(5000.00, 0.00, 500.00, 0.00, 1, 5),
-- Folha 2 (Fevereiro)
(12000.00, 800.00, 1800.00, 0.00, 2, 1),
(8000.00, 400.00, 1000.00, 0.00, 2, 2),
(6000.00, 250.00, 750.00, 0.00, 2, 3),
(4500.00, 50.00, 450.00, 0.00, 2, 4),
(5000.00, 50.00, 500.00, 0.00, 2, 5),
-- Folha 3 (Março)
(12000.00, 700.00, 1800.00, 0.00, 3, 1),
(8000.00, 350.00, 1050.00, 0.00, 3, 2),
(6000.00, 225.00, 775.00, 0.00, 3, 3),
(4500.00, 25.00, 450.00, 0.00, 3, 4),
(5000.00, 25.00, 500.00, 0.00, 3, 5);


-- ============================================
-- APROVAR FOLHAS E BENS AUTOMATICAMENTE
-- ============================================

-- Aprovar Folhas de Elenco (triggers validarão orçamento)
CALL sp_aprovar_folha_elenco(1, 1, 8);
CALL sp_aprovar_folha_elenco(2, 1, 8);
CALL sp_aprovar_folha_elenco(3, 1, 8);

-- Aprovar Folhas de Funcionários (triggers validarão orçamento)
CALL sp_aprovar_folha_funcionarios(1, 1, 9);
CALL sp_aprovar_folha_funcionarios(2, 1, 9);
CALL sp_aprovar_folha_funcionarios(3, 1, 9);


-- Aprovar Bens
CALL sp_aprovar_bem(1, 1, 2);
CALL sp_aprovar_bem(2, 1, 2);
CALL sp_aprovar_bem(3, 1, 3);
CALL sp_aprovar_bem(4, 1, 3);
CALL sp_aprovar_bem(5, 1, 4);
CALL sp_aprovar_bem(6, 1, 4);
CALL sp_aprovar_bem(7, 1, 4);

-- ============================================
-- RELATÓRIOS DE ATIVOS IMOBILIZADOS
-- ============================================

INSERT INTO ativo_imobilizado (data_competencia, data_geracao, tipo, valor_total, valor_total_contabil, responsavel, status, id_direcao) VALUES
('2026-01-31', '2026-02-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18850000.00, 'João Oliveira', 'concluido', 3),
('2026-02-28', '2026-03-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18820000.00, 'João Oliveira', 'concluido', 3),
('2026-03-31', '2026-04-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18790000.00, 'João Oliveira', 'concluido', 3);

INSERT INTO relatorio_bens (valor_contabil, estado_conservacao, localizacao_registro, descricao, id_relatorio_bens, id_bem) VALUES
-- Janeiro
(14850000.00, 'Bom', 'Estádio', 'Estádio com capacidade para 28000 pessoas', 1, 1),
(3400000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 1, 2),
(420000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 1, 3),
(172000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 1, 4),
(76500.00, 'Ótimo', 'Estádio', 'Sistema de iluminação', 1, 5),
(102000.00, 'Ótimo', 'Estádio', 'Sistema de som do estadio', 1, 6),
(76000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos modernos de musculação', 1, 7),
-- fevereiro
(14820000.00, 'Bom', 'Estádio', 'Estádio com capacidade para 28000 pessoas', 2, 1),
(3380000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 2, 2),
(415000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 2, 3),
(170000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 2, 4),
(75650.00, 'Ótimo', 'Estádio', 'Sistema de iluminação profissional', 2, 5),
(100500.00, 'Ótimo', 'Estádio', 'Sistema de som de última geração', 2, 6),
(72000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos de musculação', 2, 7),
-- março
(14790000.00, 'Bom', 'Estádio', 'Estádio com capacidade para 28000 pessoas', 3, 1),
(3360000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 3, 2),
(410000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 3, 3),
(168000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 3, 4),
(74800.00, 'Ótimo', 'Estádio', 'Sistema de iluminação profissional', 3, 5),
(99000.00, 'Ótimo', 'Estádio', 'Sistema de som de última geração', 3, 6),
(68000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos modernos de musculação', 3, 7);

-- ============================================
-- CORREÇÃO DE COMPETÊNCIA 
-- ============================================

UPDATE lancamento l
JOIN folha_elenco fe ON fe.id_folha_elenco = l.id_origem
SET l.data_registro = fe.data_competencia
WHERE l.origem = 'folha_elenco'
  AND l.id_lancamento > 0
  AND l.data_registro <> fe.data_competencia;

UPDATE lancamento l
JOIN folha_funcionarios ff ON ff.id_folha_funcionarios = l.id_origem
SET l.data_registro = ff.data_competencia
WHERE l.origem = 'folha_funcionarios'
  AND l.id_lancamento > 0
  AND l.data_registro <> ff.data_competencia;

UPDATE lancamento l
JOIN bens b ON b.id_bem = l.id_origem
SET l.data_registro = b.data_aquisicao
WHERE l.origem = 'bem'
  AND l.id_lancamento > 0
  AND l.data_registro <> b.data_aquisicao;

-- LANÇAMENTOS MANUAIS
INSERT INTO lancamento (data_registro, valor, tipo_de_movimentacao, status_aprovacao, id_aprovador, data_aprovacao, id_direcao, id_conta, descricao, origem, id_origem) VALUES
('2026-01-10 14:30:00', 150000.00, 'entrada', 'aprovado', 1, '2026-01-10 14:30:00', 1, 6, 'Receita de Bilheteria - Jogos Janeiro', 'manual', NULL),
('2026-01-15 10:00:00', 280000.00, 'entrada', 'aprovado', 1, '2026-01-15 10:00:00', 1, 7, 'Patrocínio Master - Janeiro', 'manual', NULL),
('2026-02-12 15:00:00', 165000.00, 'entrada', 'aprovado', 1, '2026-02-12 15:00:00', 1, 6, 'Receita de Bilheteria - Jogos Fevereiro', 'manual', NULL),
('2026-02-20 11:00:00', 280000.00, 'entrada', 'aprovado', 1, '2026-02-20 11:00:00', 1, 7, 'Patrocínio Master - Fevereiro', 'manual', NULL),
('2026-03-08 16:00:00', 172000.00, 'entrada', 'aprovado', 1, '2026-03-08 16:00:00', 1, 6, 'Receita de Bilheteria - Jogos Março', 'manual', NULL),
('2026-03-18 09:30:00', 280000.00, 'entrada', 'aprovado', 1, '2026-03-18 09:30:00', 1, 7, 'Patrocínio Master - Março', 'manual', NULL);


