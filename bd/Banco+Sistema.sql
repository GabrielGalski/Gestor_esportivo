DROP DATABASE IF EXISTS gestao_clube;
CREATE DATABASE gestao_clube;
USE gestao_clube;

-- ============================================
-- TABELAS PRINCIPAIS
-- ============================================

CREATE TABLE IF NOT EXISTS clube (
    id_clube INT PRIMARY KEY,
    nome_clube VARCHAR(100) NOT NULL,
    data_de_fundacao DATE NOT NULL,
    presidente_atual VARCHAR(100) NOT NULL,
    chapa INT NOT NULL
);

CREATE TABLE IF NOT EXISTS direcao (
    id_direcao INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_clube INT NOT NULL,
    FOREIGN KEY (id_clube) REFERENCES clube(id_clube)
);

CREATE TABLE IF NOT EXISTS corpo_diretivo (
    id_direcao INT PRIMARY KEY,
    assinatura VARCHAR(255),
    data_homologacao DATE NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
);

CREATE TABLE IF NOT EXISTS corpo_esportivo (
    id_direcao INT PRIMARY KEY,
    temporada VARCHAR(9) NOT NULL,
    orcamento DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
);

CREATE TABLE IF NOT EXISTS corpo_financeiro (
    id_direcao INT PRIMARY KEY,
    orcamento DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
);

-- ============================================
-- TABELAS DE PLANO DE CONTAS
-- ============================================

CREATE TABLE IF NOT EXISTS plano_de_contas (
    id_conta INT PRIMARY KEY AUTO_INCREMENT,
    codigo_conta VARCHAR(20) UNIQUE NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    tipo_conta ENUM('ativo', 'passivo', 'receita', 'despesa', 'patrimonio_liquido') NOT NULL
);

CREATE TABLE IF NOT EXISTS lancamento (
    id_lancamento INT PRIMARY KEY AUTO_INCREMENT,
    data_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor DECIMAL(15,2) NOT NULL,
    tipo_de_movimentacao ENUM('entrada', 'saida') NOT NULL,
    status_aprovacao ENUM('pendente', 'aprovado', 'rejeitado') DEFAULT 'pendente',
    id_aprovador INT,
    data_aprovacao DATETIME,
    id_direcao INT NOT NULL,
    id_conta INT NOT NULL,
    descricao TEXT,
    origem ENUM('folha_elenco', 'folha_funcionarios', 'bem', 'manual') NOT NULL,
    id_origem INT,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao),
    FOREIGN KEY (id_aprovador) REFERENCES direcao(id_direcao),
    FOREIGN KEY (id_conta) REFERENCES plano_de_contas(id_conta)
);

-- ============================================
-- TABELAS DE FUNCIONÁRIOS
-- ============================================

CREATE TABLE IF NOT EXISTS funcionarios (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    id_contrato VARCHAR(50) UNIQUE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    setor VARCHAR(100) NOT NULL,
    tipo_funcionario ENUM('contratado', 'terceirizado') NOT NULL,
    id_direcao INT NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao)
);

CREATE TABLE IF NOT EXISTS contratado (
    id_funcionario INT PRIMARY KEY,
    data_admissao DATE NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

CREATE TABLE IF NOT EXISTS terceirizado (
    id_funcionario INT PRIMARY KEY,
    empresa_contratante VARCHAR(150) NOT NULL,
    prazo_contrato INT NOT NULL,
    valor_contrato_total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

CREATE TABLE IF NOT EXISTS folha_funcionarios (
    id_folha_funcionarios INT PRIMARY KEY AUTO_INCREMENT,
    data_pagamento DATE NOT NULL,
    status ENUM('pendente', 'aprovado', 'pago', 'rejeitado') DEFAULT 'pendente',
    data_competencia DATE NOT NULL,
    id_direcao INT NOT NULL,
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
);

CREATE TABLE IF NOT EXISTS item_folha_f (
    id_item_folha INT PRIMARY KEY AUTO_INCREMENT,
    salario_base DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    descontos DECIMAL(10,2) DEFAULT 0.00,
    adicionais DECIMAL(10,2) DEFAULT 0.00,
    id_folha_funcionarios INT NOT NULL,
    id_funcionario INT NOT NULL,
    FOREIGN KEY (id_folha_funcionarios) REFERENCES folha_funcionarios(id_folha_funcionarios),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- ============================================
-- TABELAS DE BENS
-- ============================================

CREATE TABLE IF NOT EXISTS bens (
    id_bem INT PRIMARY KEY AUTO_INCREMENT,
    data_aquisicao DATE NOT NULL,
    nome_item VARCHAR(200) NOT NULL,
    valor_aquisicao DECIMAL(15,2) NOT NULL,
    localizacao VARCHAR(200),
    id_direcao INT NOT NULL,
    status_aprovacao ENUM('pendente', 'aprovado', 'rejeitado', 'baixado') DEFAULT 'pendente',
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
);

CREATE TABLE IF NOT EXISTS imoveis (
    id_bem INT PRIMARY KEY,
    endereco VARCHAR(255) NOT NULL,
    area DECIMAL(10,2) NOT NULL,
    tipo_propriedade VARCHAR(100) NOT NULL,
    depreciacao_ano DECIMAL(5,2) DEFAULT 2.00,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
);

CREATE TABLE IF NOT EXISTS moveis (
    id_bem INT PRIMARY KEY,
    depreciacao_ano DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
);

CREATE TABLE IF NOT EXISTS automoveis (
    id_bem INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    ano INT NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    depreciacao_ano DECIMAL(5,2) DEFAULT 10.00,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
);

CREATE TABLE IF NOT EXISTS ativo_imobilizado (
    id_relatorio_bens INT PRIMARY KEY AUTO_INCREMENT,
    data_competencia DATE NOT NULL,
    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo VARCHAR(100),
    valor_total DECIMAL(15,2) NOT NULL,
    valor_total_contabil DECIMAL(15,2) NOT NULL,
    responsavel VARCHAR(150) NOT NULL,
    status ENUM('em_elaboracao', 'concluido', 'auditado') DEFAULT 'em_elaboracao',
    id_direcao INT NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao)
);

CREATE TABLE IF NOT EXISTS relatorio_bens (
    id_relatorio_item INT PRIMARY KEY AUTO_INCREMENT,
    valor_contabil DECIMAL(15,2) NOT NULL,
    estado_conservacao VARCHAR(100),
    localizacao_registro VARCHAR(200),
    descricao TEXT,
    id_relatorio_bens INT NOT NULL,
    id_bem INT NOT NULL,
    FOREIGN KEY (id_relatorio_bens) REFERENCES ativo_imobilizado(id_relatorio_bens),
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
);

-- ============================================
-- TABELAS DE ELENCO
-- ============================================

CREATE TABLE IF NOT EXISTS elenco (
    id_elenco INT PRIMARY KEY AUTO_INCREMENT,
    nome_jogador VARCHAR(150) NOT NULL,
    multa DECIMAL(15,2),
    funcao VARCHAR(100) NOT NULL,
    inicio_contrato DATE NOT NULL,
    fim_contrato DATE NOT NULL,
    luvas DECIMAL(15,2) DEFAULT 0.00,
    passe_data_contrato DATE,
    id_direcao INT NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES corpo_esportivo(id_direcao)
);

CREATE TABLE IF NOT EXISTS folha_elenco (
    id_folha_elenco INT PRIMARY KEY AUTO_INCREMENT,
    data_competencia DATE NOT NULL,
    data_pagamento DATE NOT NULL,
    valor_direitos_imagem DECIMAL(15,2) DEFAULT 0.00,
    status ENUM('pendente', 'aprovado', 'pago', 'rejeitado') DEFAULT 'pendente',
    id_direcao INT NOT NULL,
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_esportivo(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
);

CREATE TABLE IF NOT EXISTS item_folha_e (
    id_item_folha_e INT PRIMARY KEY AUTO_INCREMENT,
    salario_base DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    direito_imagem DECIMAL(10,2) DEFAULT 0.00,
    parcela_luvas DECIMAL(10,2) DEFAULT 0.00,
    descontos DECIMAL(10,2) DEFAULT 0.00,
    id_folha_elenco INT NOT NULL,
    id_elenco INT NOT NULL,
    FOREIGN KEY (id_folha_elenco) REFERENCES folha_elenco(id_folha_elenco),
    FOREIGN KEY (id_elenco) REFERENCES elenco(id_elenco)
);

-- ============================================
-- TABELA DE ALERTAS DE ORÇAMENTO
-- ============================================

CREATE TABLE IF NOT EXISTS alertas_orcamento (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_direcao INT NOT NULL,
    percentual_usado DECIMAL(5,2) NOT NULL,
    valor_disponivel DECIMAL(15,2) NOT NULL,
    data_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    mensagem TEXT NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
);

-- ============================================
-- VIEWS PARA CÁLCULO EM TEMPO REAL
-- ============================================

-- View para Itens da Folha de Elenco (Calcula valor_liquido)
CREATE OR REPLACE VIEW vw_item_folha_e_calculado AS
SELECT 
    id_item_folha_e,
    id_folha_elenco,
    id_elenco,
    salario_base,
    bonus,
    direito_imagem,
    parcela_luvas,
    descontos,
    (salario_base + bonus + direito_imagem + parcela_luvas - descontos) AS valor_liquido
FROM item_folha_e;

-- View para Itens da Folha de Funcionários (Calcula valor_liquido)
CREATE OR REPLACE VIEW vw_item_folha_f_calculado AS
SELECT 
    id_item_folha,
    id_folha_funcionarios,
    id_funcionario,
    salario_base,
    bonus,
    adicionais,
    descontos,
    (salario_base + bonus + adicionais - descontos) AS valor_liquido
FROM item_folha_f;

-- View para Totalização da Folha de Elenco (Calcula valor_bruto)
CREATE OR REPLACE VIEW vw_folha_elenco_total AS
SELECT 
    fe.id_folha_elenco,
    fe.data_competencia,
    fe.data_pagamento,
    fe.valor_direitos_imagem,
    fe.status,
    fe.id_direcao,
    fe.id_lancamento,
    COALESCE(SUM(ife.salario_base + ife.bonus + ife.direito_imagem + ife.parcela_luvas), 0) AS valor_bruto,
    COALESCE(SUM(ife.salario_base + ife.bonus + ife.direito_imagem + ife.parcela_luvas - ife.descontos), 0) AS valor_liquido_total
FROM folha_elenco fe
LEFT JOIN item_folha_e ife ON fe.id_folha_elenco = ife.id_folha_elenco
GROUP BY fe.id_folha_elenco, fe.data_competencia, fe.data_pagamento, fe.valor_direitos_imagem, fe.status, fe.id_direcao, fe.id_lancamento;

-- View para Totalização da Folha de Funcionários (Calcula valor_bruto)
CREATE OR REPLACE VIEW vw_folha_funcionarios_total AS
SELECT 
    ff.id_folha_funcionarios,
    ff.data_competencia,
    ff.data_pagamento,
    ff.status,
    ff.id_direcao,
    ff.id_lancamento,
    COALESCE(SUM(iff.salario_base + iff.bonus + iff.adicionais), 0) AS valor_bruto,
    COALESCE(SUM(iff.salario_base + iff.bonus + iff.adicionais - iff.descontos), 0) AS valor_liquido_total
FROM folha_funcionarios ff
LEFT JOIN item_folha_f iff ON ff.id_folha_funcionarios = iff.id_folha_funcionarios
GROUP BY ff.id_folha_funcionarios, ff.data_competencia, ff.data_pagamento, ff.status, ff.id_direcao, ff.id_lancamento;

-- ============================================
-- FUNÇÃO AUXILIAR PARA CÁLCULO DE SALDO
-- ============================================

DELIMITER //

CREATE FUNCTION fn_calcular_saldo_atual()
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_saldo DECIMAL(15,2);
    
    SELECT COALESCE(SUM(
        CASE 
            WHEN tipo_de_movimentacao = 'entrada' THEN valor
            WHEN tipo_de_movimentacao = 'saida' THEN -valor
            ELSE 0
        END
    ), 0) INTO v_saldo
    FROM lancamento
    WHERE status_aprovacao = 'aprovado';
    
    RETURN v_saldo;
END//

DELIMITER ;

-- ============================================
-- TRIGGERS DE VALIDAÇÃO E ALERTAS
-- ============================================

DELIMITER //

-- ============================================
-- TRIGGER 1: Validação de Saldo para Lançamentos Manuais
-- ============================================
CREATE TRIGGER tr_validar_saldo_lancamento
BEFORE INSERT ON lancamento
FOR EACH ROW
BEGIN
    DECLARE v_saldo_atual DECIMAL(15,2);
    
    -- Só valida se for saída com aprovação automática
    IF NEW.tipo_de_movimentacao = 'saida' AND NEW.status_aprovacao = 'aprovado' THEN
        -- Calcula saldo atual
        SET v_saldo_atual = fn_calcular_saldo_atual();
        
        -- Valida se há saldo suficiente
        IF v_saldo_atual < NEW.valor THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Saldo insuficiente! Operação não permitida.';
        END IF;
    END IF;
END//

-- ============================================
-- TRIGGER 2: Validação de Orçamento ao Aprovar Folha de Elenco
-- ============================================
CREATE TRIGGER tr_validar_orcamento_elenco
BEFORE UPDATE ON folha_elenco
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_total_mes DECIMAL(15,2);
    DECLARE v_valor_bruto DECIMAL(15,2);
    DECLARE v_saldo_atual DECIMAL(15,2);
    
    -- Só valida quando status muda de 'pendente' para 'aprovado' ou 'pago'
    IF NEW.status IN ('aprovado', 'pago') AND OLD.status = 'pendente' THEN
        -- Busca orçamento do corpo esportivo
        SELECT orcamento INTO v_orcamento
        FROM corpo_esportivo
        WHERE id_direcao = NEW.id_direcao;
        
        -- Calcula valor bruto desta folha
        SELECT COALESCE(SUM(salario_base + bonus + direito_imagem + parcela_luvas), 0)
        INTO v_valor_bruto
        FROM item_folha_e
        WHERE id_folha_elenco = NEW.id_folha_elenco;
        
        -- Calcula total já gasto no mês (excluindo a folha atual)
        SELECT COALESCE(SUM(vfe.valor_bruto), 0) INTO v_total_mes
        FROM vw_folha_elenco_total vfe
        INNER JOIN folha_elenco fe ON vfe.id_folha_elenco = fe.id_folha_elenco
        WHERE fe.id_direcao = NEW.id_direcao
          AND fe.status IN ('aprovado', 'pago')
          AND MONTH(fe.data_competencia) = MONTH(NEW.data_competencia)
          AND YEAR(fe.data_competencia) = YEAR(NEW.data_competencia)
          AND fe.id_folha_elenco != NEW.id_folha_elenco;
        
        -- VALIDAÇÃO 1: Verifica se excede orçamento mensal
        IF (v_total_mes + v_valor_bruto) > v_orcamento THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Orçamento mensal do Corpo Esportivo excedido!';
        END IF;
        
        -- VALIDAÇÃO 2: Verifica se há saldo em caixa
        SET v_saldo_atual = fn_calcular_saldo_atual();
        IF v_saldo_atual < v_valor_bruto THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Saldo insuficiente para aprovar esta folha de elenco!';
        END IF;
    END IF;
END//

-- ============================================
-- TRIGGER 3: Validação de Orçamento ao Aprovar Folha de Funcionários
-- ============================================
CREATE TRIGGER tr_validar_orcamento_funcionarios
BEFORE UPDATE ON folha_funcionarios
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_total_mes DECIMAL(15,2);
    DECLARE v_valor_bruto DECIMAL(15,2);
    DECLARE v_saldo_atual DECIMAL(15,2);
    
    -- Só valida quando status muda de 'pendente' para 'aprovado' ou 'pago'
    IF NEW.status IN ('aprovado', 'pago') AND OLD.status = 'pendente' THEN
        -- Busca orçamento do corpo financeiro
        SELECT orcamento INTO v_orcamento
        FROM corpo_financeiro
        WHERE id_direcao = NEW.id_direcao;
        
        -- Calcula valor bruto desta folha
        SELECT COALESCE(SUM(salario_base + bonus + adicionais), 0)
        INTO v_valor_bruto
        FROM item_folha_f
        WHERE id_folha_funcionarios = NEW.id_folha_funcionarios;
        
        -- Calcula total já gasto no mês (excluindo a folha atual)
        SELECT COALESCE(SUM(vff.valor_bruto), 0) INTO v_total_mes
        FROM vw_folha_funcionarios_total vff
        INNER JOIN folha_funcionarios ff ON vff.id_folha_funcionarios = ff.id_folha_funcionarios
        WHERE ff.id_direcao = NEW.id_direcao
          AND ff.status IN ('aprovado', 'pago')
          AND MONTH(ff.data_competencia) = MONTH(NEW.data_competencia)
          AND YEAR(ff.data_competencia) = YEAR(NEW.data_competencia)
          AND ff.id_folha_funcionarios != NEW.id_folha_funcionarios;
        
        -- VALIDAÇÃO 1: Verifica se excede orçamento mensal
        IF (v_total_mes + v_valor_bruto) > v_orcamento THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Orçamento mensal do Corpo Financeiro excedido!';
        END IF;
        
        -- VALIDAÇÃO 2: Verifica se há saldo em caixa
        SET v_saldo_atual = fn_calcular_saldo_atual();
        IF v_saldo_atual < v_valor_bruto THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Saldo insuficiente para aprovar esta folha de funcionários!';
        END IF;
    END IF;
END//

-- ============================================
-- TRIGGER 4: Alerta de Orçamento Crítico - Elenco (80%)
-- ============================================
CREATE TRIGGER tr_alerta_orcamento_critico_elenco
AFTER UPDATE ON folha_elenco
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_total_mes DECIMAL(15,2);
    DECLARE v_percentual DECIMAL(5,2);
    DECLARE v_disponivel DECIMAL(15,2);
    
    -- Só executa quando folha é aprovada ou paga
    IF NEW.status IN ('aprovado', 'pago') AND OLD.status = 'pendente' THEN
        -- Busca orçamento
        SELECT orcamento INTO v_orcamento
        FROM corpo_esportivo
        WHERE id_direcao = NEW.id_direcao;
        
        -- Calcula total do mês (incluindo a folha recém-aprovada)
        SELECT COALESCE(SUM(vfe.valor_bruto), 0) INTO v_total_mes
        FROM vw_folha_elenco_total vfe
        INNER JOIN folha_elenco fe ON vfe.id_folha_elenco = fe.id_folha_elenco
        WHERE fe.id_direcao = NEW.id_direcao
          AND fe.status IN ('aprovado', 'pago')
          AND MONTH(fe.data_competencia) = MONTH(NEW.data_competencia)
          AND YEAR(fe.data_competencia) = YEAR(NEW.data_competencia);
        
        -- Calcula percentual
        SET v_percentual = (v_total_mes / v_orcamento) * 100;
        SET v_disponivel = v_orcamento - v_total_mes;
        
        -- Gera alerta se >= 80%
        IF v_percentual >= 80.00 THEN
            INSERT INTO alertas_orcamento (
                id_direcao,
                percentual_usado,
                valor_disponivel,
                mensagem
            ) VALUES (
                NEW.id_direcao,
                v_percentual,
                v_disponivel,
                CONCAT('ALERTA CRÍTICO: Orçamento do elenco em ', ROUND(v_percentual, 2), 
                       '% de utilização no mês ', DATE_FORMAT(NEW.data_competencia, '%m/%Y'),
                       '. Disponível: R$ ', FORMAT(v_disponivel, 2, 'pt_BR'))
            );
        END IF;
    END IF;
END//

-- ============================================
-- TRIGGER 5: Alerta de Orçamento Crítico - Funcionários (80%)
-- ============================================
CREATE TRIGGER tr_alerta_orcamento_critico_funcionarios
AFTER UPDATE ON folha_funcionarios
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_total_mes DECIMAL(15,2);
    DECLARE v_percentual DECIMAL(5,2);
    DECLARE v_disponivel DECIMAL(15,2);
    
    -- Só executa quando folha é aprovada ou paga
    IF NEW.status IN ('aprovado', 'pago') AND OLD.status = 'pendente' THEN
        -- Busca orçamento
        SELECT orcamento INTO v_orcamento
        FROM corpo_financeiro
        WHERE id_direcao = NEW.id_direcao;
        
        -- Calcula total do mês (incluindo a folha recém-aprovada)
        SELECT COALESCE(SUM(vff.valor_bruto), 0) INTO v_total_mes
        FROM vw_folha_funcionarios_total vff
        INNER JOIN folha_funcionarios ff ON vff.id_folha_funcionarios = ff.id_folha_funcionarios
        WHERE ff.id_direcao = NEW.id_direcao
          AND ff.status IN ('aprovado', 'pago')
          AND MONTH(ff.data_competencia) = MONTH(NEW.data_competencia)
          AND YEAR(ff.data_competencia) = YEAR(NEW.data_competencia);
        
        -- Calcula percentual
        SET v_percentual = (v_total_mes / v_orcamento) * 100;
        SET v_disponivel = v_orcamento - v_total_mes;
        
        -- Gera alerta se >= 80%
        IF v_percentual >= 80.00 THEN
            INSERT INTO alertas_orcamento (
                id_direcao,
                percentual_usado,
                valor_disponivel,
                mensagem
            ) VALUES (
                NEW.id_direcao,
                v_percentual,
                v_disponivel,
                CONCAT('ALERTA CRÍTICO: Orçamento administrativo em ', ROUND(v_percentual, 2), 
                       '% de utilização no mês ', DATE_FORMAT(NEW.data_competencia, '%m/%Y'),
                       '. Disponível: R$ ', FORMAT(v_disponivel, 2, 'pt_BR'))
            );
        END IF;
    END IF;
END//

DELIMITER ;

-- ============================================
-- STORED PROCEDURES
-- ============================================

DELIMITER //

-- ============================================
-- Procedure para aprovar bem
-- ============================================
CREATE PROCEDURE sp_aprovar_bem(
    IN p_id_bem INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_nome VARCHAR(200);
    DECLARE v_data_aquisicao DATE;
    DECLARE v_id_lancamento INT;
    DECLARE v_saldo_atual DECIMAL(15,2);
    
    -- Busca dados do bem
    SELECT valor_aquisicao, nome_item, data_aquisicao
    INTO v_valor, v_nome, v_data_aquisicao
    FROM bens
    WHERE id_bem = p_id_bem;
    
    -- Valida saldo antes de aprovar
    SET v_saldo_atual = fn_calcular_saldo_atual();
    IF v_saldo_atual < v_valor THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Saldo insuficiente para aprovar este bem!';
    END IF;
    
    -- Cria lançamento
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
        v_data_aquisicao,
        v_valor,
        'saida',
        'aprovado',
        p_id_aprovador,
        NOW(),
        p_id_aprovador,
        p_id_conta,
        CONCAT('Aquisição de Bem: ', v_nome),
        'bem',
        p_id_bem
    );
    
    SET v_id_lancamento = LAST_INSERT_ID();
    
    -- Atualiza bem
    UPDATE bens
    SET status_aprovacao = 'aprovado', id_lancamento = v_id_lancamento
    WHERE id_bem = p_id_bem;
END//

-- ============================================
-- Procedure para aprovar folha de funcionários
-- ============================================
CREATE PROCEDURE sp_aprovar_folha_funcionarios(
    IN p_id_folha INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_data_competencia DATE;
    DECLARE v_id_lancamento INT;
    
    -- Busca o valor bruto calculado da view
    SELECT valor_bruto, data_competencia 
    INTO v_valor, v_data_competencia
    FROM vw_folha_funcionarios_total
    WHERE id_folha_funcionarios = p_id_folha;
    
    -- IMPORTANTE: Atualiza a folha para 'aprovado' ANTES de criar o lançamento
    -- Isso garante que o trigger BEFORE UPDATE seja disparado com as validações
    UPDATE folha_funcionarios
    SET status = 'aprovado'
    WHERE id_folha_funcionarios = p_id_folha;
    
    -- Cria o lançamento após aprovação bem-sucedida
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
        v_data_competencia,
        v_valor,
        'saida',
        'aprovado',
        p_id_aprovador,
        NOW(),
        p_id_aprovador,
        p_id_conta,
        CONCAT('Folha de Funcionários - ', DATE_FORMAT(v_data_competencia, '%m/%Y')),
        'folha_funcionarios',
        p_id_folha
    );
    
    SET v_id_lancamento = LAST_INSERT_ID();
    
    -- Atualiza o id_lancamento na folha
    UPDATE folha_funcionarios
    SET id_lancamento = v_id_lancamento
    WHERE id_folha_funcionarios = p_id_folha;
END//

-- ============================================
-- Procedure para aprovar folha de elenco
-- ============================================
CREATE PROCEDURE sp_aprovar_folha_elenco(
    IN p_id_folha INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_data_competencia DATE;
    DECLARE v_id_lancamento INT;
    
    -- Busca o valor bruto calculado da view
    SELECT valor_bruto, data_competencia 
    INTO v_valor, v_data_competencia
    FROM vw_folha_elenco_total
    WHERE id_folha_elenco = p_id_folha;
    
    -- IMPORTANTE: Atualiza a folha para 'aprovado' ANTES de criar o lançamento
    -- Isso garante que o trigger BEFORE UPDATE seja disparado com as validações
    UPDATE folha_elenco
    SET status = 'aprovado'
    WHERE id_folha_elenco = p_id_folha;
    
    -- Cria o lançamento após aprovação bem-sucedida
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
        v_data_competencia,
        v_valor,
        'saida',
        'aprovado',
        p_id_aprovador,
        NOW(),
        p_id_aprovador,
        p_id_conta,
        CONCAT('Folha de Elenco - ', DATE_FORMAT(v_data_competencia, '%m/%Y')),
        'folha_elenco',
        p_id_folha
    );
    
    SET v_id_lancamento = LAST_INSERT_ID();
    
    -- Atualiza o id_lancamento na folha
    UPDATE folha_elenco
    SET id_lancamento = v_id_lancamento
    WHERE id_folha_elenco = p_id_folha;
END//

-- ============================================
-- Procedure para aprovar lançamento manual
-- ============================================
CREATE PROCEDURE sp_aprovar_lancamento_manual(
    IN p_id_lancamento INT,
    IN p_id_aprovador INT
)
BEGIN
    DECLARE v_tipo VARCHAR(10);
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_saldo_atual DECIMAL(15,2);
    
    -- Busca dados do lançamento
    SELECT tipo_de_movimentacao, valor
    INTO v_tipo, v_valor
    FROM lancamento
    WHERE id_lancamento = p_id_lancamento;
    
    -- Se for saída, valida saldo
    IF v_tipo = 'saida' THEN
        SET v_saldo_atual = fn_calcular_saldo_atual();
        IF v_saldo_atual < v_valor THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Saldo insuficiente para aprovar este lançamento!';
        END IF;
    END IF;
    
    -- Aprova o lançamento
    UPDATE lancamento
    SET status_aprovacao = 'aprovado',
        id_aprovador = p_id_aprovador,
        data_aprovacao = NOW()
    WHERE id_lancamento = p_id_lancamento;
END//

-- ============================================
-- Procedures automáticas (para uso no sistema)
-- ============================================
CREATE PROCEDURE sp_aprovar_folha_elenco_automatica(
    IN p_data_competencia DATE,
    IN p_data_pagamento DATE,
    IN p_valor_bruto DECIMAL(15,2),
    IN p_valor_direitos DECIMAL(15,2),
    IN p_id_direcao INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_id_folha INT;
    
    -- Inserir folha como PENDENTE primeiro
    INSERT INTO folha_elenco (
        data_competencia,
        data_pagamento,
        valor_direitos_imagem,
        status,
        id_direcao
    ) VALUES (
        p_data_competencia,
        p_data_pagamento,
        p_valor_direitos,
        'pendente',
        p_id_direcao
    );
    
    SET v_id_folha = LAST_INSERT_ID();
    
    -- Aprovar usando a procedure (que dispara os triggers)
    CALL sp_aprovar_folha_elenco(v_id_folha, 1, p_id_conta);
END//

CREATE PROCEDURE sp_aprovar_folha_funcionarios_automatica(
    IN p_data_competencia DATE,
    IN p_data_pagamento DATE,
    IN p_valor_bruto DECIMAL(15,2),
    IN p_id_direcao INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_id_folha INT;
    
    -- Inserir folha como PENDENTE primeiro
    INSERT INTO folha_funcionarios (
        data_competencia,
        data_pagamento,
        status,
        id_direcao
    ) VALUES (
        p_data_competencia,
        p_data_pagamento,
        'pendente',
        p_id_direcao
    );
    
    SET v_id_folha = LAST_INSERT_ID();
    
    -- Aprovar usando a procedure (que dispara os triggers)
    CALL sp_aprovar_folha_funcionarios(v_id_folha, 1, p_id_conta);
END//

DELIMITER ;

-- ============================================
-- VIEWS PARA CONSULTAS (Compatibilidade)
-- ============================================

-- View dados públicos consolidados
CREATE OR REPLACE VIEW dados_publicos AS
SELECT 
    pc.codigo_conta,
    pc.descricao,
    pc.tipo_conta,
    DATE_FORMAT(l.data_registro, '%Y-%m') AS mes_ano,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END) AS total_saidas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE -l.valor END) AS saldo_liquido
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
WHERE l.status_aprovacao = 'aprovado'
GROUP BY pc.id_conta, pc.codigo_conta, pc.descricao, pc.tipo_conta, DATE_FORMAT(l.data_registro, '%Y-%m')
ORDER BY mes_ano DESC, pc.codigo_conta;

-- View dados privados detalhados
CREATE OR REPLACE VIEW dados_privados AS
SELECT 
    l.id_lancamento,
    l.data_registro,
    l.valor,
    l.tipo_de_movimentacao,
    l.descricao,
    l.origem,
    l.id_origem,
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
WHERE l.status_aprovacao = 'aprovado'
ORDER BY l.data_registro DESC;

-- View resumo do elenco
CREATE OR REPLACE VIEW resumo_elenco AS
SELECT 
    e.id_elenco,
    e.nome_jogador,
    e.funcao,
    e.inicio_contrato,
    e.fim_contrato,
    DATEDIFF(e.fim_contrato, CURDATE()) AS dias_restantes_contrato,
    e.multa,
    e.luvas,
    e.passe_data_contrato,
    COALESCE(SUM(vie.valor_liquido), 0) AS total_pago
FROM elenco e
LEFT JOIN item_folha_e ife ON e.id_elenco = ife.id_elenco
LEFT JOIN folha_elenco fe ON ife.id_folha_elenco = fe.id_folha_elenco AND fe.status IN ('aprovado', 'pago')
LEFT JOIN vw_item_folha_e_calculado vie ON vie.id_item_folha_e = ife.id_item_folha_e
GROUP BY e.id_elenco, e.nome_jogador, e.funcao, e.inicio_contrato, e.fim_contrato, 
         e.multa, e.luvas, e.passe_data_contrato;

-- View resumo dos funcionários
CREATE OR REPLACE VIEW resumo_funcionarios AS
SELECT 
    f.id_funcionario,
    f.id_contrato,
    f.cargo,
    f.setor,
    f.salario,
    f.tipo_funcionario,
    c.data_admissao,
    t.empresa_contratante,
    t.prazo_contrato,
    t.valor_contrato_total,
    COALESCE(SUM(vif.valor_liquido), 0) AS total_pago
FROM funcionarios f
LEFT JOIN contratado c ON f.id_funcionario = c.id_funcionario
LEFT JOIN terceirizado t ON f.id_funcionario = t.id_funcionario
LEFT JOIN item_folha_f iff ON f.id_funcionario = iff.id_funcionario
LEFT JOIN folha_funcionarios ff ON iff.id_folha_funcionarios = ff.id_folha_funcionarios AND ff.status IN ('aprovado', 'pago')
LEFT JOIN vw_item_folha_f_calculado vif ON vif.id_item_folha = iff.id_item_folha
GROUP BY f.id_funcionario, f.id_contrato, f.cargo, f.setor, f.salario, f.tipo_funcionario,
         c.data_admissao, t.empresa_contratante, t.prazo_contrato, t.valor_contrato_total;

-- View ativo imobilizado mensal
CREATE OR REPLACE VIEW ativo_imobilizado_mensal AS
SELECT 
    DATE_FORMAT(data_competencia, '%Y-%m') AS mes_ano,
    tipo,
    SUM(valor_total) AS valor_total_periodo,
    SUM(valor_total_contabil) AS valor_contabil_periodo
FROM ativo_imobilizado
WHERE status IN ('concluido', 'auditado')
GROUP BY DATE_FORMAT(data_competencia, '%Y-%m'), tipo
ORDER BY mes_ano DESC, tipo;

-- View detalhamento de bens
CREATE OR REPLACE VIEW detalhamento_bens AS
SELECT 
    b.id_bem,
    b.nome_item,
    b.valor_aquisicao,
    b.data_aquisicao,
    b.localizacao,
    b.status_aprovacao,
    CASE 
        WHEN i.id_bem IS NOT NULL THEN 'Imóvel'
        WHEN m.id_bem IS NOT NULL THEN 'Móvel'
        WHEN a.id_bem IS NOT NULL THEN 'Automóvel'
        ELSE 'Outro'
    END AS tipo_bem,
    COALESCE(i.depreciacao_ano, m.depreciacao_ano, a.depreciacao_ano, 0) AS depreciacao_anual,
    ROUND(b.valor_aquisicao - (b.valor_aquisicao * COALESCE(i.depreciacao_ano, m.depreciacao_ano, a.depreciacao_ano, 0) / 100 * 
          TIMESTAMPDIFF(YEAR, b.data_aquisicao, CURDATE())), 2) AS valor_contabil_atual,
    i.endereco AS imovel_endereco,
    i.area AS imovel_area,
    a.placa AS automovel_placa,
    a.modelo AS automovel_modelo
FROM bens b
LEFT JOIN imoveis i ON b.id_bem = i.id_bem
LEFT JOIN moveis m ON b.id_bem = m.id_bem
LEFT JOIN automoveis a ON b.id_bem = a.id_bem
WHERE b.status_aprovacao = 'aprovado';

-- View análise de orçamento mensal
CREATE OR REPLACE VIEW analise_orcamento_mensal AS
SELECT 
    DATE_FORMAT(fe.data_competencia, '%Y-%m') AS mes_ano,
    ce.orcamento,
    SUM(vfe.valor_bruto) AS gasto_periodo,
    ce.orcamento - SUM(vfe.valor_bruto) AS saldo_orcamento,
    ROUND((SUM(vfe.valor_bruto) / ce.orcamento) * 100, 2) AS percentual_utilizado
FROM vw_folha_elenco_total vfe
INNER JOIN folha_elenco fe ON vfe.id_folha_elenco = fe.id_folha_elenco
INNER JOIN corpo_esportivo ce ON fe.id_direcao = ce.id_direcao
WHERE vfe.status IN ('aprovado', 'pago')
GROUP BY DATE_FORMAT(fe.data_competencia, '%Y-%m'), ce.orcamento
ORDER BY mes_ano DESC;

-- View média de folha anual
CREATE OR REPLACE VIEW media_folha_anual AS
SELECT 
    YEAR(data_competencia) AS ano,
    'Elenco' AS tipo_folha,
    COUNT(*) AS quantidade_folhas,
    ROUND(AVG(valor_bruto), 2) AS valor_medio,
    SUM(valor_bruto) AS valor_total
FROM vw_folha_elenco_total
WHERE status IN ('aprovado', 'pago')
GROUP BY YEAR(data_competencia)
UNION ALL
SELECT 
    YEAR(data_competencia) AS ano,
    'Funcionários' AS tipo_folha,
    COUNT(*) AS quantidade_folhas,
    ROUND(AVG(valor_bruto), 2) AS valor_medio,
    SUM(valor_bruto) AS valor_total
FROM vw_folha_funcionarios_total
WHERE status IN ('aprovado', 'pago')
GROUP BY YEAR(data_competencia)
ORDER BY ano DESC, tipo_folha;

-- ============================================
-- FIM DO SCRIPT
-- ============================================

-- Tabela para armazenar as queries do sistema
CREATE TABLE IF NOT EXISTS queries_sistema (
    id_query INT PRIMARY KEY AUTO_INCREMENT,
    nome_query VARCHAR(200) NOT NULL,
    descricao TEXT,
    sql_query TEXT NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP
) ;

-- Tabela para armazenar as views do sistema
CREATE TABLE IF NOT EXISTS views_sistema (
    id_view INT PRIMARY KEY AUTO_INCREMENT,
    nome_view VARCHAR(200) NOT NULL,
    descricao TEXT,
    sql_view TEXT NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP
) ;

-- ============================================
-- INSERÇÃO DAS QUERIES
-- ============================================

INSERT INTO queries_sistema (nome_query, descricao, sql_query) VALUES
('1. Lançamentos', 'Lista todos os lançamentos financeiros com detalhes completos', 
'SELECT 
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
ORDER BY l.data_registro DESC;'),

('2. Movimentação por Conta e Período', 'Resumo de movimentações agrupadas por conta e período', 
'SELECT 
    pc.codigo_conta,
    pc.descricao,
    pc.tipo_conta,
    DATE_FORMAT(l.data_registro, \'%Y-%m\') AS mes_ano,
    COUNT(l.id_lancamento) AS total_lancamentos,
    SUM(CASE WHEN l.tipo_de_movimentacao = \'entrada\' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = \'saida\' THEN l.valor ELSE 0 END) AS total_saidas,
    SUM(CASE WHEN l.tipo_de_movimentacao = \'entrada\' THEN l.valor ELSE -l.valor END) AS saldo_periodo
FROM plano_de_contas pc
LEFT JOIN lancamento l ON pc.id_conta = l.id_conta AND l.status_aprovacao = \'aprovado\'
GROUP BY pc.id_conta, pc.codigo_conta, pc.descricao, pc.tipo_conta, DATE_FORMAT(l.data_registro, \'%Y-%m\')
ORDER BY mes_ano DESC, pc.codigo_conta;'),

('3. Total de Patrimônio Imobilizado', 'Resumo do patrimônio por tipo de bem', 
'SELECT 
    tipo_bem,
    COUNT(*) AS quantidade_bens,
    SUM(valor_aquisicao) AS valor_total_aquisicao,
    SUM(valor_contabil_atual) AS valor_total_contabil_atual,
    SUM(valor_aquisicao - valor_contabil_atual) AS depreciacao_acumulada
FROM detalhamento_bens
GROUP BY tipo_bem
ORDER BY valor_total_contabil_atual DESC;'),

('4. Balanço Mensal', 'Balanço financeiro mensal com receitas, despesas e resultado', 
'SELECT 
    DATE_FORMAT(data_registro, \'%Y-%m\') AS mes_ano,
    YEAR(data_registro) AS ano,
    MONTH(data_registro) AS mes,
    SUM(CASE WHEN tipo_de_movimentacao = \'entrada\' THEN valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN tipo_de_movimentacao = \'saida\' THEN valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN tipo_de_movimentacao = \'entrada\' THEN valor ELSE -valor END) AS resultado_periodo
FROM lancamento
WHERE status_aprovacao = \'aprovado\'
GROUP BY YEAR(data_registro), MONTH(data_registro), DATE_FORMAT(data_registro, \'%Y-%m\')
ORDER BY ano DESC, mes DESC;'),

('5. Resumo Financeiro Trimestral', 'Análise financeira detalhada dos últimos 3 meses', 
'SELECT 
    pc.tipo_conta,
    pc.codigo_conta,
    pc.descricao AS conta,
    COUNT(l.id_lancamento) AS qtd_lancamentos,
    SUM(CASE WHEN l.tipo_de_movimentacao = \'entrada\' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = \'saida\' THEN l.valor ELSE 0 END) AS total_saidas,
    (SUM(CASE WHEN l.tipo_de_movimentacao = \'entrada\' THEN l.valor ELSE 0 END) -
     SUM(CASE WHEN l.tipo_de_movimentacao = \'saida\' THEN l.valor ELSE 0 END)) AS saldo_liquido,
    DATE_FORMAT(MIN(l.data_registro), \'%d/%m/%Y\') AS primeira_movimentacao,
    DATE_FORMAT(MAX(l.data_registro), \'%d/%m/%Y\') AS ultima_movimentacao
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
WHERE l.status_aprovacao = \'aprovado\'
    AND l.data_registro >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY pc.tipo_conta, pc.codigo_conta, pc.descricao
ORDER BY pc.tipo_conta, saldo_liquido DESC;'),

('6. Orçamento Crítico', 'Alertas de orçamento em situação crítica', 
'SELECT 
    a.id_alerta,
    d.nome AS responsavel_departamento,
    CASE WHEN ce.id_direcao IS NOT NULL THEN \'Esportivo\' WHEN cf.id_direcao IS NOT NULL THEN \'Financeiro\' WHEN cd.id_direcao IS NOT NULL THEN \'Diretivo\' ELSE \'Outro\' END AS tipo_corpo,
    a.percentual_usado,
    CONCAT(\'R$ \', FORMAT(a.valor_disponivel, 2, \'pt_BR\')) AS valor_disponivel,
    DATE_FORMAT(a.data_alerta, \'%d/%m/%Y %H:%i:%s\') AS data_hora_alerta,
    a.mensagem
FROM alertas_orcamento a
INNER JOIN direcao d ON a.id_direcao = d.id_direcao
LEFT JOIN corpo_esportivo ce ON a.id_direcao = ce.id_direcao
LEFT JOIN corpo_financeiro cf ON a.id_direcao = cf.id_direcao
LEFT JOIN corpo_diretivo cd ON a.id_direcao = cd.id_direcao
ORDER BY a.data_alerta DESC;');

-- ============================================
-- INSERÇÃO DAS VIEWS
-- ============================================

INSERT INTO views_sistema (nome_view, descricao, sql_view) VALUES
('1. Resumo do Elenco', 'Informações completas do elenco com histórico financeiro', 
'SELECT * FROM resumo_elenco;'),

('2. Resumo dos Funcionários', 'Informações completas dos funcionários com histórico financeiro', 
'SELECT * FROM resumo_funcionarios;'),

('3. Ativo Imobilizado Mensal', 'Evolução mensal do patrimônio imobilizado', 
'SELECT * FROM ativo_imobilizado_mensal;'),

('4. Detalhamento de Bens', 'Lista detalhada de todos os bens com depreciação', 
'SELECT * FROM detalhamento_bens;'),

('5. Análise de Orçamento Mensal', 'Análise mensal da execução orçamentária', 
'SELECT * FROM analise_orcamento_mensal;'),

('6. Média de Folha Anual', 'Média anual das folhas de pagamento (elenco e funcionários)', 
'SELECT * FROM media_folha_anual;');
