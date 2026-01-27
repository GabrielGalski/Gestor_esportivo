-- ============================================
-- SISTEMA DE GERENCIAMENTO DE CONTAS - CLUBE
-- Database: MySQL
-- Clube: Pelotas (ID: 01)
-- ============================================

DROP DATABASE IF EXISTS gestao_clube;
CREATE DATABASE gestao_clube CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestao_clube;

SET NAMES utf8mb4;
SET sql_mode = '';
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- ============================================
-- TABELAS PRINCIPAIS
-- ============================================

CREATE TABLE IF NOT EXISTS clube (
    id_clube INT PRIMARY KEY,
    nome_clube VARCHAR(100) NOT NULL,
    data_de_fundacao DATE NOT NULL,
    presidente_atual VARCHAR(100) NOT NULL,
    chapa INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS corpo_diretivo (
    id_direcao INT PRIMARY KEY,
    assinatura VARCHAR(255),
    data_homologacao DATE NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS corpo_esportivo (
    id_direcao INT PRIMARY KEY,
    temporada VARCHAR(9) NOT NULL,
    despesa_salarial DECIMAL(15,2) DEFAULT 0.00,
    total_elenco INT DEFAULT 0,
    orcamento DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS corpo_financeiro (
    id_direcao INT PRIMARY KEY,
    total_funcionarios INT DEFAULT 0,
    total_bens DECIMAL(15,2) DEFAULT 0.00,
    orcamento DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_direcao) REFERENCES direcao(id_direcao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABELAS DE PLANO DE CONTAS (movida para antes)
-- ============================================

CREATE TABLE IF NOT EXISTS plano_de_contas (
    id_conta INT PRIMARY KEY AUTO_INCREMENT,
    codigo_conta VARCHAR(20) UNIQUE NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    tipo_conta ENUM('ativo', 'passivo', 'receita', 'despesa', 'patrimonio_liquido') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    FOREIGN KEY (id_direcao) REFERENCES corpo_diretivo(id_direcao),
    FOREIGN KEY (id_aprovador) REFERENCES corpo_diretivo(id_direcao),
    FOREIGN KEY (id_conta) REFERENCES plano_de_contas(id_conta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS contratado (
    id_funcionario INT PRIMARY KEY,
    data_admissao DATE NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS terceirizado (
    id_funcionario INT PRIMARY KEY,
    empresa_contratante VARCHAR(150) NOT NULL,
    prazo_contrato INT NOT NULL,
    valor_contrato_total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS folha_funcionarios (
    id_folha_funcionarios INT PRIMARY KEY AUTO_INCREMENT,
    data_pagamento DATE NOT NULL,
    valor_bruto DECIMAL(15,2) NOT NULL,
    status ENUM('pendente', 'aprovado', 'pago', 'rejeitado') DEFAULT 'pendente',
    data_competencia DATE NOT NULL,
    id_direcao INT NOT NULL,
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS item_folha_f (
    id_item_folha INT PRIMARY KEY AUTO_INCREMENT,
    valor_liquido DECIMAL(10,2) NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    descontos DECIMAL(10,2) DEFAULT 0.00,
    adicionais DECIMAL(10,2) DEFAULT 0.00,
    id_folha_funcionarios INT NOT NULL,
    id_funcionario INT NOT NULL,
    FOREIGN KEY (id_folha_funcionarios) REFERENCES folha_funcionarios(id_folha_funcionarios),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    status_aprovacao ENUM('pendente', 'aprovado', 'rejeitado') DEFAULT 'pendente',
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_financeiro(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS imoveis (
    id_bem INT PRIMARY KEY,
    endereco VARCHAR(255) NOT NULL,
    area DECIMAL(10,2) NOT NULL,
    tipo_propriedade VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS moveis (
    id_bem INT PRIMARY KEY,
    depreciacao_ano DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS automoveis (
    id_bem INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    ano INT NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_bem) REFERENCES bens(id_bem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS folha_elenco (
    id_folha_elenco INT PRIMARY KEY AUTO_INCREMENT,
    data_competencia DATE NOT NULL,
    data_pagamento DATE NOT NULL,
    valor_bruto DECIMAL(15,2) NOT NULL,
    valor_direitos_imagem DECIMAL(15,2) DEFAULT 0.00,
    status ENUM('pendente', 'aprovado', 'pago', 'rejeitado') DEFAULT 'pendente',
    id_direcao INT NOT NULL,
    id_lancamento INT,
    FOREIGN KEY (id_direcao) REFERENCES corpo_esportivo(id_direcao),
    FOREIGN KEY (id_lancamento) REFERENCES lancamento(id_lancamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS item_folha_e (
    id_item_folha_e INT PRIMARY KEY AUTO_INCREMENT,
    salario_base DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    direito_imagem DECIMAL(10,2) DEFAULT 0.00,
    parcela_luvas DECIMAL(10,2) DEFAULT 0.00,
    valor_liquido DECIMAL(10,2) NOT NULL,
    descontos DECIMAL(10,2) DEFAULT 0.00,
    id_folha_elenco INT NOT NULL,
    id_elenco INT NOT NULL,
    FOREIGN KEY (id_folha_elenco) REFERENCES folha_elenco(id_folha_elenco),
    FOREIGN KEY (id_elenco) REFERENCES elenco(id_elenco)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TRIGGERS DE VALIDAÇÃO DE ORÇAMENTO
-- ============================================

DELIMITER //

CREATE TRIGGER trg_valida_orcamento_elenco_insert
BEFORE INSERT ON folha_elenco
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_mes_competencia INT;
    DECLARE v_ano_competencia INT;
    DECLARE v_total_mes DECIMAL(15,2);
    
    SELECT orcamento INTO v_orcamento
    FROM corpo_esportivo
    WHERE id_direcao = NEW.id_direcao;
    
    SET v_mes_competencia = MONTH(NEW.data_competencia);
    SET v_ano_competencia = YEAR(NEW.data_competencia);
    
    SELECT COALESCE(SUM(valor_bruto), 0) INTO v_total_mes
    FROM folha_elenco
    WHERE id_direcao = NEW.id_direcao
    AND MONTH(data_competencia) = v_mes_competencia
    AND YEAR(data_competencia) = v_ano_competencia;
    
    IF (v_total_mes + NEW.valor_bruto) > v_orcamento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orçamento do Corpo Esportivo excedido para o mês';
    END IF;
END//

CREATE TRIGGER trg_valida_orcamento_elenco_update
BEFORE UPDATE ON folha_elenco
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_mes_competencia INT;
    DECLARE v_ano_competencia INT;
    DECLARE v_total_mes DECIMAL(15,2);
    
    SELECT orcamento INTO v_orcamento
    FROM corpo_esportivo
    WHERE id_direcao = NEW.id_direcao;
    
    SET v_mes_competencia = MONTH(NEW.data_competencia);
    SET v_ano_competencia = YEAR(NEW.data_competencia);
    
    SELECT COALESCE(SUM(valor_bruto), 0) INTO v_total_mes
    FROM folha_elenco
    WHERE id_direcao = NEW.id_direcao
    AND MONTH(data_competencia) = v_mes_competencia
    AND YEAR(data_competencia) = v_ano_competencia
    AND id_folha_elenco != NEW.id_folha_elenco;
    
    IF (v_total_mes + NEW.valor_bruto) > v_orcamento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orçamento do Corpo Esportivo excedido para o mês';
    END IF;
END//

CREATE TRIGGER trg_valida_orcamento_funcionarios_insert
BEFORE INSERT ON folha_funcionarios
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_mes_competencia INT;
    DECLARE v_ano_competencia INT;
    DECLARE v_total_mes DECIMAL(15,2);
    
    SELECT orcamento INTO v_orcamento
    FROM corpo_financeiro
    WHERE id_direcao = NEW.id_direcao;
    
    SET v_mes_competencia = MONTH(NEW.data_competencia);
    SET v_ano_competencia = YEAR(NEW.data_competencia);
    
    SELECT COALESCE(SUM(valor_bruto), 0) INTO v_total_mes
    FROM folha_funcionarios
    WHERE id_direcao = NEW.id_direcao
    AND MONTH(data_competencia) = v_mes_competencia
    AND YEAR(data_competencia) = v_ano_competencia;
    
    IF (v_total_mes + NEW.valor_bruto) > v_orcamento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orçamento do Corpo Financeiro excedido para o mês';
    END IF;
END//

CREATE TRIGGER trg_valida_orcamento_funcionarios_update
BEFORE UPDATE ON folha_funcionarios
FOR EACH ROW
BEGIN
    DECLARE v_orcamento DECIMAL(15,2);
    DECLARE v_mes_competencia INT;
    DECLARE v_ano_competencia INT;
    DECLARE v_total_mes DECIMAL(15,2);
    
    SELECT orcamento INTO v_orcamento
    FROM corpo_financeiro
    WHERE id_direcao = NEW.id_direcao;
    
    SET v_mes_competencia = MONTH(NEW.data_competencia);
    SET v_ano_competencia = YEAR(NEW.data_competencia);
    
    SELECT COALESCE(SUM(valor_bruto), 0) INTO v_total_mes
    FROM folha_funcionarios
    WHERE id_direcao = NEW.id_direcao
    AND MONTH(data_competencia) = v_mes_competencia
    AND YEAR(data_competencia) = v_ano_competencia
    AND id_folha_funcionarios != NEW.id_folha_funcionarios;
    
    IF (v_total_mes + NEW.valor_bruto) > v_orcamento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orçamento do Corpo Financeiro excedido para o mês';
    END IF;
END//

CREATE TRIGGER trg_atualiza_total_funcionarios_insert
AFTER INSERT ON funcionarios
FOR EACH ROW
BEGIN
    UPDATE corpo_financeiro
    SET total_funcionarios = (
        SELECT COUNT(*)
        FROM funcionarios
        WHERE id_direcao = NEW.id_direcao
    )
    WHERE id_direcao = NEW.id_direcao;
END//

CREATE TRIGGER trg_atualiza_total_funcionarios_delete
AFTER DELETE ON funcionarios
FOR EACH ROW
BEGIN
    UPDATE corpo_financeiro
    SET total_funcionarios = (
        SELECT COUNT(*)
        FROM funcionarios
        WHERE id_direcao = OLD.id_direcao
    )
    WHERE id_direcao = OLD.id_direcao;
END//

CREATE TRIGGER trg_atualiza_total_elenco_insert
AFTER INSERT ON elenco
FOR EACH ROW
BEGIN
    UPDATE corpo_esportivo
    SET total_elenco = (
        SELECT COUNT(*)
        FROM elenco
        WHERE id_direcao = NEW.id_direcao
    )
    WHERE id_direcao = NEW.id_direcao;
END//

CREATE TRIGGER trg_atualiza_total_elenco_delete
AFTER DELETE ON elenco
FOR EACH ROW
BEGIN
    UPDATE corpo_esportivo
    SET total_elenco = (
        SELECT COUNT(*)
        FROM elenco
        WHERE id_direcao = OLD.id_direcao
    )
    WHERE id_direcao = OLD.id_direcao;
END//

CREATE TRIGGER trg_atualiza_total_bens_insert
AFTER INSERT ON bens
FOR EACH ROW
BEGIN
    IF NEW.status_aprovacao = 'aprovado' THEN
        UPDATE corpo_financeiro
        SET total_bens = (
            SELECT COALESCE(SUM(valor_aquisicao), 0)
            FROM bens
            WHERE id_direcao = NEW.id_direcao
            AND status_aprovacao = 'aprovado'
        )
        WHERE id_direcao = NEW.id_direcao;
    END IF;
END//

CREATE TRIGGER trg_atualiza_total_bens_update
AFTER UPDATE ON bens
FOR EACH ROW
BEGIN
    UPDATE corpo_financeiro
    SET total_bens = (
        SELECT COALESCE(SUM(valor_aquisicao), 0)
        FROM bens
        WHERE id_direcao = NEW.id_direcao
        AND status_aprovacao = 'aprovado'
    )
    WHERE id_direcao = NEW.id_direcao;
END//

CREATE TRIGGER trg_atualiza_despesa_elenco
AFTER INSERT ON folha_elenco
FOR EACH ROW
BEGIN
    IF NEW.status = 'aprovado' OR NEW.status = 'pago' THEN
        UPDATE corpo_esportivo
        SET despesa_salarial = despesa_salarial + NEW.valor_bruto
        WHERE id_direcao = NEW.id_direcao;
    END IF;
END//

DELIMITER ;

-- ============================================
-- PROCEDURES DE APROVAÇÃO
-- ============================================

DELIMITER //

CREATE PROCEDURE sp_aprovar_folha_funcionarios(
    IN p_id_folha INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_data_competencia DATE;
    DECLARE v_id_lancamento INT;
    
    SELECT valor_bruto, data_competencia 
    INTO v_valor, v_data_competencia
    FROM folha_funcionarios
    WHERE id_folha_funcionarios = p_id_folha;
    
    INSERT INTO lancamento (
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
    
    UPDATE folha_funcionarios
    SET status = 'aprovado', id_lancamento = v_id_lancamento
    WHERE id_folha_funcionarios = p_id_folha;
END//

CREATE PROCEDURE sp_aprovar_folha_elenco(
    IN p_id_folha INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_data_competencia DATE;
    DECLARE v_id_lancamento INT;
    
    SELECT valor_bruto, data_competencia 
    INTO v_valor, v_data_competencia
    FROM folha_elenco
    WHERE id_folha_elenco = p_id_folha;
    
    INSERT INTO lancamento (
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
    
    UPDATE folha_elenco
    SET status = 'aprovado', id_lancamento = v_id_lancamento
    WHERE id_folha_elenco = p_id_folha;
END//

CREATE PROCEDURE sp_aprovar_bem(
    IN p_id_bem INT,
    IN p_id_aprovador INT,
    IN p_id_conta INT
)
BEGIN
    DECLARE v_valor DECIMAL(15,2);
    DECLARE v_nome VARCHAR(200);
    DECLARE v_id_lancamento INT;
    
    SELECT valor_aquisicao, nome_item 
    INTO v_valor, v_nome
    FROM bens
    WHERE id_bem = p_id_bem;
    
    INSERT INTO lancamento (
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
    
    UPDATE bens
    SET status_aprovacao = 'aprovado', id_lancamento = v_id_lancamento
    WHERE id_bem = p_id_bem;
END//

DELIMITER ;

-- ============================================
-- VIEWS DO SISTEMA
-- ============================================

CREATE OR REPLACE VIEW vw_dados_publicos AS
SELECT 
    pc.codigo_conta,
    pc.descricao AS conta_descricao,
    pc.tipo_conta,
    DATE_FORMAT(l.data_registro, '%Y-%m') AS mes_ano,
    YEAR(l.data_registro) AS ano,
    MONTH(l.data_registro) AS mes,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'saida' THEN l.valor ELSE 0 END) AS total_saidas,
    SUM(CASE WHEN l.tipo_de_movimentacao = 'entrada' THEN l.valor ELSE -l.valor END) AS saldo_liquido
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
WHERE l.status_aprovacao = 'aprovado'
GROUP BY 
    pc.codigo_conta, 
    pc.descricao, 
    pc.tipo_conta, 
    YEAR(l.data_registro), 
    MONTH(l.data_registro),
    DATE_FORMAT(l.data_registro, '%Y-%m')
ORDER BY ano DESC, mes DESC, pc.codigo_conta;

CREATE OR REPLACE VIEW vw_dados_privados AS
SELECT 
    l.id_lancamento,
    pc.codigo_conta,
    pc.descricao AS conta_descricao,
    pc.tipo_conta,
    l.data_registro,
    DATE_FORMAT(l.data_registro, '%Y-%m') AS mes_ano,
    YEAR(l.data_registro) AS ano,
    MONTH(l.data_registro) AS mes,
    l.tipo_de_movimentacao,
    l.valor,
    l.descricao AS lancamento_descricao,
    l.origem,
    l.id_origem,
    l.status_aprovacao,
    d.nome AS aprovador,
    l.data_aprovacao
FROM lancamento l
INNER JOIN plano_de_contas pc ON l.id_conta = pc.id_conta
LEFT JOIN direcao d ON l.id_aprovador = d.id_direcao
WHERE l.status_aprovacao = 'aprovado'
ORDER BY l.data_registro DESC;

CREATE OR REPLACE VIEW vw_resumo_elenco AS
SELECT 
    e.id_elenco,
    e.nome_jogador,
    e.funcao,
    e.inicio_contrato,
    e.fim_contrato,
    e.multa,
    e.luvas,
    DATEDIFF(e.fim_contrato, CURDATE()) AS dias_restantes_contrato,
    COALESCE(SUM(ife.valor_liquido), 0) AS total_recebido,
    COUNT(DISTINCT fe.id_folha_elenco) AS total_pagamentos
FROM elenco e
LEFT JOIN item_folha_e ife ON e.id_elenco = ife.id_elenco
LEFT JOIN folha_elenco fe ON ife.id_folha_elenco = fe.id_folha_elenco
GROUP BY 
    e.id_elenco, 
    e.nome_jogador, 
    e.funcao, 
    e.inicio_contrato, 
    e.fim_contrato, 
    e.multa, 
    e.luvas;

CREATE OR REPLACE VIEW vw_resumo_funcionarios AS
SELECT 
    f.id_funcionario,
    f.id_contrato,
    f.cargo,
    f.setor,
    f.tipo_funcionario,
    f.salario,
    c.data_admissao,
    t.empresa_contratante,
    COALESCE(SUM(iff.valor_liquido), 0) AS total_recebido,
    COUNT(DISTINCT ff.id_folha_funcionarios) AS total_pagamentos
FROM funcionarios f
LEFT JOIN contratado c ON f.id_funcionario = c.id_funcionario
LEFT JOIN terceirizado t ON f.id_funcionario = t.id_funcionario
LEFT JOIN item_folha_f iff ON f.id_funcionario = iff.id_funcionario
LEFT JOIN folha_funcionarios ff ON iff.id_folha_funcionarios = ff.id_folha_funcionarios
GROUP BY 
    f.id_funcionario, 
    f.id_contrato, 
    f.cargo, 
    f.setor, 
    f.tipo_funcionario, 
    f.salario, 
    c.data_admissao, 
    t.empresa_contratante;

CREATE OR REPLACE VIEW vw_ativo_imobilizado_mensal AS
SELECT 
    DATE_FORMAT(ai.data_competencia, '%Y-%m') AS mes_ano,
    YEAR(ai.data_competencia) AS ano,
    MONTH(ai.data_competencia) AS mes,
    ai.tipo,
    SUM(ai.valor_total) AS valor_total_ativo,
    SUM(ai.valor_total_contabil) AS valor_total_contabil,
    COUNT(DISTINCT ai.id_relatorio_bens) AS total_relatorios
FROM ativo_imobilizado ai
WHERE ai.status IN ('concluido', 'auditado')
GROUP BY 
    YEAR(ai.data_competencia), 
    MONTH(ai.data_competencia), 
    DATE_FORMAT(ai.data_competencia, '%Y-%m'),
    ai.tipo
ORDER BY ano DESC, mes DESC;

CREATE OR REPLACE VIEW vw_detalhamento_bens AS
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
    COALESCE(m.depreciacao_ano, 0) AS depreciacao_anual,
    ROUND(b.valor_aquisicao - (b.valor_aquisicao * COALESCE(m.depreciacao_ano, 0) / 100 * 
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

CREATE OR REPLACE VIEW vw_analise_orcamento_mensal AS
SELECT 
    DATE_FORMAT(fe.data_competencia, '%Y-%m') AS mes_ano,
    YEAR(fe.data_competencia) AS ano,
    MONTH(fe.data_competencia) AS mes,
    ce.orcamento AS orcamento_esportivo,
    SUM(fe.valor_bruto) AS gasto_elenco,
    ce.orcamento - SUM(fe.valor_bruto) AS saldo_orcamento,
    ROUND((SUM(fe.valor_bruto) / ce.orcamento) * 100, 2) AS percentual_utilizado
FROM folha_elenco fe
INNER JOIN corpo_esportivo ce ON fe.id_direcao = ce.id_direcao
WHERE fe.status IN ('aprovado', 'pago')
GROUP BY 
    YEAR(fe.data_competencia), 
    MONTH(fe.data_competencia), 
    DATE_FORMAT(fe.data_competencia, '%Y-%m'),
    ce.orcamento
ORDER BY ano DESC, mes DESC;

CREATE OR REPLACE VIEW vw_media_folha_anual AS
SELECT 
    YEAR(fe.data_competencia) AS ano,
    'Elenco' AS tipo_folha,
    COUNT(DISTINCT fe.id_folha_elenco) AS total_folhas,
    AVG(fe.valor_bruto) AS valor_medio_folha,
    SUM(fe.valor_bruto) AS valor_total_ano
FROM folha_elenco fe
WHERE fe.status IN ('aprovado', 'pago')
GROUP BY YEAR(fe.data_competencia)

UNION ALL

SELECT 
    YEAR(ff.data_competencia) AS ano,
    'Funcionários' AS tipo_folha,
    COUNT(DISTINCT ff.id_folha_funcionarios) AS total_folhas,
    AVG(ff.valor_bruto) AS valor_medio_folha,
    SUM(ff.valor_bruto) AS valor_total_ano
FROM folha_funcionarios ff
WHERE ff.status IN ('aprovado', 'pago')
GROUP BY YEAR(ff.data_competencia)
ORDER BY ano DESC, tipo_folha;

-- ============================================
-- INSERÇÃO DE DADOS
-- ============================================

INSERT INTO clube (id_clube, nome_clube, data_de_fundacao, presidente_atual, chapa) 
VALUES (1, 'Pelotas', '1908-10-11', 'Gabriel', 1);

INSERT INTO direcao (id_direcao, nome, email, senha, cpf, data_nascimento, data_cadastro, id_clube) 
VALUES 
(1, 'Gabriel Silva', 'gabriel.diretivo@pelotas.com.br', 'hash123', '12345678901', '1980-05-15', '2025-01-01 08:00:00', 1),
(2, 'Maria Santos', 'maria.esportivo@pelotas.com.br', 'hash456', '23456789012', '1985-08-22', '2025-01-01 08:00:00', 1),
(3, 'João Oliveira', 'joao.financeiro@pelotas.com.br', 'hash789', '34567890123', '1982-11-30', '2025-01-01 08:00:00', 1);

INSERT INTO corpo_diretivo (id_direcao, assinatura, data_homologacao) 
VALUES (1, 'Gabriel Silva - Diretor Presidente', '2025-01-01');

INSERT INTO corpo_esportivo (id_direcao, temporada, despesa_salarial, total_elenco, orcamento) 
VALUES (2, '2025/2026', 0.00, 0, 500000.00);

INSERT INTO corpo_financeiro (id_direcao, total_funcionarios, total_bens, orcamento) 
VALUES (3, 0, 0.00, 200000.00);

INSERT INTO plano_de_contas (codigo_conta, descricao, tipo_conta) VALUES
('1.1.01', 'Caixa e Equivalentes', 'ativo'),
('1.2.01', 'Imóveis', 'ativo'),
('1.2.02', 'Veículos', 'ativo'),
('1.2.03', 'Equipamentos', 'ativo'),
('2.1.01', 'Salários a Pagar', 'passivo'),
('3.1.01', 'Receitas de Bilheteria', 'receita'),
('3.1.02', 'Receitas de Patrocínio', 'receita'),
('4.1.01', 'Despesas com Elenco', 'despesa'),
('4.1.02', 'Despesas Administrativas', 'despesa'),
('4.2.01', 'Aquisição de Bens', 'despesa');

INSERT INTO elenco (nome_jogador, multa, funcao, inicio_contrato, fim_contrato, luvas, passe_data_contrato, id_direcao) VALUES
('Carlos Henrique', 500000.00, 'Goleiro', '2024-01-10', '2027-12-31', 20000.00, '2024-01-10', 2),
('Rafael Souza', 800000.00, 'Zagueiro', '2023-06-15', '2026-12-31', 35000.00, '2023-06-15', 2),
('Lucas Martins', 1200000.00, 'Meio-Campo', '2024-02-01', '2028-06-30', 50000.00, '2024-02-01', 2),
('Pedro Alves', 1500000.00, 'Atacante', '2024-03-20', '2027-12-31', 60000.00, '2024-03-20', 2),
('Diego Santos', 900000.00, 'Lateral Direito', '2023-08-10', '2026-12-31', 30000.00, '2023-08-10', 2);

INSERT INTO funcionarios (id_contrato, salario, cargo, setor, tipo_funcionario, id_direcao) VALUES
('FUNC-001', 12000.00, 'Gerente Administrativo', 'Administrativo', 'contratado', 3),
('FUNC-002', 8000.00, 'Contador', 'Financeiro', 'contratado', 3),
('FUNC-003', 6000.00, 'Analista de Marketing', 'Marketing', 'contratado', 3),
('TERC-001', 4500.00, 'Segurança', 'Infraestrutura', 'terceirizado', 3),
('TERC-002', 5000.00, 'Serviços de Limpeza', 'Infraestrutura', 'terceirizado', 3);

INSERT INTO contratado (id_funcionario, data_admissao) VALUES
(1, '2020-03-15'),
(2, '2021-07-01'),
(3, '2022-09-10');

INSERT INTO terceirizado (id_funcionario, empresa_contratante, prazo_contrato, valor_contrato_total) VALUES
(4, 'SecureMax Segurança Ltda', 24, 108000.00),
(5, 'CleanPro Serviços', 12, 60000.00);

INSERT INTO bens (data_aquisicao, nome_item, valor_aquisicao, localizacao, id_direcao, status_aprovacao) VALUES
('2015-05-10', 'Estádio Boca do Lobo', 15000000.00, 'Rua Alberto Rosa, 211 - Pelotas/RS', 3, 'aprovado'),
('2018-08-20', 'Centro de Treinamento', 3500000.00, 'Avenida dos Esportes, 1500 - Pelotas/RS', 3, 'aprovado'),
('2020-11-15', 'Ônibus da Delegação', 450000.00, 'Garagem CT Pelotas', 3, 'aprovado'),
('2022-06-01', 'Van de Apoio', 180000.00, 'Garagem CT Pelotas', 3, 'aprovado'),
('2023-01-20', 'Refletores de Campo', 85000.00, 'Estádio Boca do Lobo', 3, 'aprovado'),
('2023-07-10', 'Sistema de Som Estádio', 120000.00, 'Estádio Boca do Lobo', 3, 'aprovado'),
('2024-03-15', 'Equipamentos de Musculação', 95000.00, 'Centro de Treinamento', 3, 'aprovado');

INSERT INTO imoveis (id_bem, endereco, area, tipo_propriedade) VALUES
(1, 'Rua Alberto Rosa, 211 - Pelotas/RS', 45000.00, 'Estádio de Futebol'),
(2, 'Avenida dos Esportes, 1500 - Pelotas/RS', 25000.00, 'Centro de Treinamento');

INSERT INTO automoveis (id_bem, tipo, placa, ano, modelo) VALUES
(3, 'Ônibus', 'IQF-1234', 2020, 'Mercedes-Benz O500 RSD'),
(4, 'Van', 'IQG-5678', 2022, 'Renault Master');

INSERT INTO moveis (id_bem, depreciacao_ano) VALUES
(5, 10.00),
(6, 15.00),
(7, 20.00);

INSERT INTO folha_elenco (data_competencia, data_pagamento, valor_bruto, valor_direitos_imagem, status, id_direcao) VALUES
('2026-01-01', '2026-01-05', 95000.00, 12000.00, 'pendente', 2),
('2026-02-01', '2026-02-05', 98000.00, 12500.00, 'pendente', 2),
('2026-03-01', '2026-03-05', 96500.00, 12200.00, 'pendente', 2);

INSERT INTO item_folha_e (salario_base, bonus, direito_imagem, parcela_luvas, valor_liquido, descontos, id_folha_elenco, id_elenco) VALUES
(12000.00, 1000.00, 2000.00, 500.00, 13800.00, 1700.00, 1, 1),
(18000.00, 1500.00, 2500.00, 800.00, 20400.00, 2400.00, 1, 2),
(25000.00, 3000.00, 3500.00, 1200.00, 28800.00, 3900.00, 1, 3),
(28000.00, 4000.00, 4000.00, 1500.00, 33200.00, 4300.00, 1, 4),
(20000.00, 2000.00, 2500.00, 1000.00, 22750.00, 2750.00, 1, 5),
(12500.00, 1200.00, 2100.00, 500.00, 14400.00, 1900.00, 2, 1),
(18500.00, 1600.00, 2600.00, 800.00, 21000.00, 2500.00, 2, 2),
(26000.00, 3200.00, 3600.00, 1200.00, 29800.00, 4200.00, 2, 3),
(29000.00, 4200.00, 4100.00, 1500.00, 34300.00, 4500.00, 2, 4),
(20500.00, 2100.00, 2600.00, 1000.00, 23400.00, 2800.00, 2, 5),
(12200.00, 1100.00, 2050.00, 500.00, 14100.00, 1750.00, 3, 1),
(18200.00, 1550.00, 2550.00, 800.00, 20650.00, 2450.00, 3, 2),
(25500.00, 3100.00, 3550.00, 1200.00, 29300.00, 4050.00, 3, 3),
(28500.00, 4100.00, 4050.00, 1500.00, 33650.00, 4500.00, 3, 4),
(20200.00, 2050.00, 2550.00, 1000.00, 23050.00, 2750.00, 3, 5);

INSERT INTO folha_funcionarios (data_pagamento, valor_bruto, status, data_competencia, id_direcao) VALUES
('2026-01-05', 35500.00, 'pendente', '2026-01-01', 3),
('2026-02-05', 36000.00, 'pendente', '2026-02-01', 3),
('2026-03-05', 35800.00, 'pendente', '2026-03-01', 3);

INSERT INTO item_folha_f (valor_liquido, salario_base, bonus, descontos, adicionais, id_folha_funcionarios, id_funcionario) VALUES
(10800.00, 12000.00, 500.00, 1700.00, 0.00, 1, 1),
(7200.00, 8000.00, 300.00, 1100.00, 0.00, 1, 2),
(5400.00, 6000.00, 200.00, 800.00, 0.00, 1, 3),
(4050.00, 4500.00, 0.00, 450.00, 0.00, 1, 4),
(4500.00, 5000.00, 0.00, 500.00, 0.00, 1, 5),
(11000.00, 12000.00, 800.00, 1800.00, 0.00, 2, 1),
(7400.00, 8000.00, 400.00, 1000.00, 0.00, 2, 2),
(5500.00, 6000.00, 250.00, 750.00, 0.00, 2, 3),
(4100.00, 4500.00, 50.00, 450.00, 0.00, 2, 4),
(4550.00, 5000.00, 50.00, 500.00, 0.00, 2, 5),
(10900.00, 12000.00, 700.00, 1800.00, 0.00, 3, 1),
(7300.00, 8000.00, 350.00, 1050.00, 0.00, 3, 2),
(5450.00, 6000.00, 225.00, 775.00, 0.00, 3, 3),
(4075.00, 4500.00, 25.00, 450.00, 0.00, 3, 4),
(4525.00, 5000.00, 25.00, 500.00, 0.00, 3, 5);

-- Aprovar folhas e bens
CALL sp_aprovar_folha_elenco(1, 1, 8);
CALL sp_aprovar_folha_elenco(2, 1, 8);
CALL sp_aprovar_folha_elenco(3, 1, 8);

CALL sp_aprovar_folha_funcionarios(1, 1, 9);
CALL sp_aprovar_folha_funcionarios(2, 1, 9);
CALL sp_aprovar_folha_funcionarios(3, 1, 9);

CALL sp_aprovar_bem(5, 1, 10);
CALL sp_aprovar_bem(6, 1, 10);
CALL sp_aprovar_bem(7, 1, 10);

INSERT INTO ativo_imobilizado (data_competencia, data_geracao, tipo, valor_total, valor_total_contabil, responsavel, status, id_direcao) VALUES
('2026-01-31', '2026-02-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18850000.00, 'João Oliveira', 'concluido', 3),
('2026-02-28', '2026-03-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18820000.00, 'João Oliveira', 'concluido', 3),
('2026-03-31', '2026-04-01 10:00:00', 'Patrimônio Geral', 19430000.00, 18790000.00, 'João Oliveira', 'concluido', 3);

INSERT INTO relatorio_bens (valor_contabil, estado_conservacao, localizacao_registro, descricao, id_relatorio_bens, id_bem) VALUES
(14850000.00, 'Bom', 'Estádio Principal', 'Estádio com capacidade para 28000 pessoas', 1, 1),
(3400000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 1, 2),
(420000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 1, 3),
(172000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 1, 4),
(76500.00, 'Ótimo', 'Estádio', 'Sistema de iluminação profissional', 1, 5),
(102000.00, 'Ótimo', 'Estádio', 'Sistema de som de última geração', 1, 6),
(76000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos modernos de musculação', 1, 7),
(14820000.00, 'Bom', 'Estádio Principal', 'Estádio com capacidade para 28000 pessoas', 2, 1),
(3380000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 2, 2),
(415000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 2, 3),
(170000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 2, 4),
(75650.00, 'Ótimo', 'Estádio', 'Sistema de iluminação profissional', 2, 5),
(100500.00, 'Ótimo', 'Estádio', 'Sistema de som de última geração', 2, 6),
(72000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos modernos de musculação', 2, 7),
(14790000.00, 'Bom', 'Estádio Principal', 'Estádio com capacidade para 28000 pessoas', 3, 1),
(3360000.00, 'Ótimo', 'CT Principal', 'Centro de treinamento completo', 3, 2),
(410000.00, 'Bom', 'Garagem CT', 'Ônibus para viagens da delegação', 3, 3),
(168000.00, 'Ótimo', 'Garagem CT', 'Van de apoio logístico', 3, 4),
(74800.00, 'Ótimo', 'Estádio', 'Sistema de iluminação profissional', 3, 5),
(99000.00, 'Ótimo', 'Estádio', 'Sistema de som de última geração', 3, 6),
(68000.00, 'Ótimo', 'CT Ginásio', 'Equipamentos modernos de musculação', 3, 7);

INSERT INTO lancamento (data_registro, valor, tipo_de_movimentacao, status_aprovacao, id_aprovador, data_aprovacao, id_direcao, id_conta, descricao, origem, id_origem) VALUES
('2026-01-10 14:30:00', 150000.00, 'entrada', 'aprovado', 1, '2026-01-10 14:30:00', 1, 6, 'Receita de Bilheteria - Jogos Janeiro', 'manual', NULL),
('2026-01-15 10:00:00', 280000.00, 'entrada', 'aprovado', 1, '2026-01-15 10:00:00', 1, 7, 'Patrocínio Master - Janeiro', 'manual', NULL),
('2026-02-12 15:00:00', 165000.00, 'entrada', 'aprovado', 1, '2026-02-12 15:00:00', 1, 6, 'Receita de Bilheteria - Jogos Fevereiro', 'manual', NULL),
('2026-02-20 11:00:00', 280000.00, 'entrada', 'aprovado', 1, '2026-02-20 11:00:00', 1, 7, 'Patrocínio Master - Fevereiro', 'manual', NULL),
('2026-03-08 16:00:00', 172000.00, 'entrada', 'aprovado', 1, '2026-03-08 16:00:00', 1, 6, 'Receita de Bilheteria - Jogos Março', 'manual', NULL),
('2026-03-18 09:30:00', 280000.00, 'entrada', 'aprovado', 1, '2026-03-18 09:30:00', 1, 7, 'Patrocínio Master - Março', 'manual', NULL);

-- ============================================
-- QUERIES
-- ============================================

-- ============================================
-- CONSULTAS (QUERIES) DO SISTEMA
-- Sistema de Gerenciamento de Contas - Clube Pelotas
-- ============================================

-- ============================================
-- 1. CONSULTA: Dados Públicos Consolidados
-- ============================================
/*
OBJETIVO: Esta view apresenta um resumo financeiro agregado por conta contábil e mês/ano,
mostrando totais de entradas, saídas e saldo líquido. É considerada "pública" pois exibe
apenas dados consolidados sem detalhes sensíveis de lançamentos individuais.

O QUE RETORNA:
- Código e descrição da conta contábil
- Tipo da conta (ativo, passivo, receita, despesa, patrimônio líquido)
- Mês/ano da movimentação
- Total de entradas no período
- Total de saídas no período
- Saldo líquido (entradas - saídas)

COMO FUNCIONA:
A view agrupa os lançamentos aprovados por conta e período (mês/ano), somando valores
de entrada e saída separadamente. Calcula o saldo líquido considerando entradas como
positivas e saídas como negativas. Ordena do período mais recente para o mais antigo.

USO TÍPICO: Relatórios gerenciais, dashboards públicos, prestação de contas à diretoria.
*/
SELECT * FROM vw_dados_publicos;


-- ============================================
-- 2. CONSULTA: Dados Privados Detalhados
-- ============================================
/*
OBJETIVO: Esta view expõe todos os detalhes de cada lançamento aprovado individualmente,
incluindo informações sensíveis como origem do lançamento, aprovador e descrições completas.
É considerada "privada" pois permite rastreabilidade completa das operações financeiras.

O QUE RETORNA:
- ID do lançamento
- Código e descrição da conta contábil
- Data de registro completa (não apenas mês/ano)
- Tipo de movimentação (entrada/saída)
- Valor individual do lançamento
- Descrição detalhada
- Origem (folha_elenco, folha_funcionarios, bem, manual)
- ID de origem (referência à tabela de origem)
- Nome do aprovador
- Data de aprovação

COMO FUNCIONA:
Faz JOIN entre lancamento, plano_de_contas e direcao para trazer informações completas
de cada lançamento aprovado. Permite auditar quem aprovou, quando e de onde veio cada
movimentação financeira. Ordena do mais recente para o mais antigo.

USO TÍPICO: Auditorias internas, análises detalhadas de conformidade, rastreamento de
transações específicas, investigações financeiras.
*/
SELECT * FROM vw_dados_privados;


-- ============================================
-- 3. CONSULTA: Resumo do Elenco
-- ============================================
/*
OBJETIVO: Apresenta um panorama completo de cada jogador do elenco, incluindo dados
contratuais e histórico financeiro acumulado. Útil para gestão de contratos e análise
de investimento em atletas.

O QUE RETORNA:
- Dados do jogador (nome, função/posição)
- Informações contratuais (datas de início/fim, multa rescisória, luvas)
- Dias restantes até o fim do contrato
- Total acumulado recebido pelo jogador
- Quantidade total de pagamentos realizados

COMO FUNCIONA:
Faz LEFT JOIN entre elenco, item_folha_e e folha_elenco para agregar todos os pagamentos
já realizados a cada jogador. Calcula automaticamente quantos dias faltam para o contrato
expirar usando DATEDIFF. Agrupa por jogador somando valores líquidos pagos.

USO TÍPICO: Planejamento de renovações contratuais, análise de custos por jogador,
identificação de contratos próximos ao vencimento, cálculo de investimento em atletas.
*/
SELECT * FROM vw_resumo_elenco;


-- ============================================
-- 4. CONSULTA: Resumo dos Funcionários
-- ============================================
/*
OBJETIVO: Consolida informações de todos os funcionários administrativos do clube,
diferenciando entre contratados CLT e terceirizados, com histórico de pagamentos.

O QUE RETORNA:
- Identificação do funcionário (ID, ID do contrato)
- Dados profissionais (cargo, setor, tipo de vínculo)
- Salário base registrado
- Data de admissão (se contratado CLT)
- Empresa contratante (se terceirizado)
- Total acumulado recebido
- Quantidade de pagamentos realizados

COMO FUNCIONA:
Combina dados das tabelas funcionarios, contratado e terceirizado através de LEFT JOINs
para capturar tanto CLT quanto terceirizados. Agrega valores da folha de pagamento
somando todos os valores líquidos pagos a cada funcionário. Agrupa por funcionário.

USO TÍPICO: Gestão de recursos humanos, análise de custos administrativos, relatórios
trabalhistas, comparação entre custos de CLT vs terceirizados.
*/
SELECT * FROM vw_resumo_funcionarios;


-- ============================================
-- 5. CONSULTA: Ativo Imobilizado Mensal
-- ============================================
/*
OBJETIVO: Apresenta a evolução mensal do patrimônio imobilizado do clube, mostrando
tanto o valor de aquisição quanto o valor contábil (após depreciação) dos bens.

O QUE RETORNA:
- Período de competência (mês/ano)
- Tipo de ativo imobilizado
- Valor total de aquisição dos ativos
- Valor total contábil (considerando depreciação)
- Quantidade de relatórios consolidados no período

COMO FUNCIONA:
Agrega dados da tabela ativo_imobilizado por mês/ano e tipo, somando valores totais
e contábeis. Considera apenas relatórios com status 'concluido' ou 'auditado', garantindo
que apenas informações validadas sejam exibidas. Ordena do período mais recente para o antigo.

USO TÍPICO: Balanço patrimonial, análise de depreciação de ativos, relatórios contábeis
mensais, acompanhamento da evolução do patrimônio do clube.
*/
SELECT * FROM vw_ativo_imobilizado_mensal;


-- ============================================
-- 6. CONSULTA: Detalhamento de Bens
-- ============================================
/*
OBJETIVO: Lista detalhada de todos os bens patrimoniais aprovados do clube, classificando-os
por tipo (imóvel, móvel, automóvel) e calculando automaticamente a depreciação acumulada.

O QUE RETORNA:
- Identificação e nome do bem
- Valor de aquisição original
- Data de aquisição e localização
- Tipo de bem (Imóvel, Móvel, Automóvel, Outro)
- Taxa de depreciação anual (se aplicável)
- Valor contábil atual (aquisição - depreciação acumulada)
- Detalhes específicos por tipo (endereço/área para imóveis, placa/modelo para veículos)

COMO FUNCIONA:
Usa LEFT JOINs com as tabelas imoveis, moveis e automoveis para classificar cada bem.
Calcula automaticamente o valor contábil atual aplicando a taxa de depreciação anual
multiplicada pelos anos decorridos desde a aquisição. Usa CASE para determinar o tipo.
Filtra apenas bens com status 'aprovado'.

USO TÍPICO: Inventário patrimonial, cálculo de depreciação para balanço, seguro de bens,
planejamento de substituição de equipamentos, avaliação de patrimônio.
*/
SELECT * FROM vw_detalhamento_bens;


-- ============================================
-- 7. CONSULTA: Análise de Orçamento Mensal (Esportivo)
-- ============================================
/*
OBJETIVO: Monitora mensalmente a execução orçamentária do departamento esportivo,
comparando o orçamento previsto com os gastos reais da folha de elenco e calculando
o percentual de utilização.

O QUE RETORNA:
- Período (mês/ano)
- Orçamento total disponível para o corpo esportivo
- Gasto efetivo com elenco no período
- Saldo restante do orçamento
- Percentual de utilização do orçamento

COMO FUNCIONA:
Cruza dados de folha_elenco com corpo_esportivo para comparar gastos reais vs orçamento.
Considera apenas folhas com status 'aprovado' ou 'pago'. Agrupa por período e calcula
automaticamente o saldo (orçamento - gasto) e o percentual (gasto/orçamento * 100).
Ordena do período mais recente para o antigo.

USO TÍPICO: Controle orçamentário mensal, alertas de estouro de orçamento, planejamento
de contratações, justificativas para solicitação de aumento de orçamento.
*/
SELECT * FROM vw_analise_orcamento_mensal;


-- ============================================
-- 8. CONSULTA: Lançamentos Detalhados com Responsáveis
-- ============================================
/*
OBJETIVO: Apresenta todos os lançamentos do sistema com informações completas sobre
quem registrou, quem aprovou e em qual conta contábil foi classificado, permitindo
rastreabilidade total das operações financeiras.

O QUE RETORNA:
- ID e data do lançamento
- Valor e tipo de movimentação
- Descrição do lançamento
- Origem (de qual módulo veio: folha, bem, manual)
- Status de aprovação
- Código e descrição da conta contábil
- Nome do responsável pelo lançamento
- Nome do aprovador
- Data de aprovação

COMO FUNCIONA:
Faz múltiplos JOINs entre lancamento, plano_de_contas e direcao (duas vezes: uma para
responsável, outra para aprovador). Traz informações completas de cada transação,
permitindo auditar toda a cadeia de responsabilidade. Ordena da transação mais recente
para a mais antiga.

USO TÍPICO: Auditoria completa de transações, rastreamento de responsabilidades,
análise de aprovações, investigação de irregularidades, relatórios de compliance.
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
OBJETIVO: Compara anualmente os custos com folha de pagamento do elenco versus
funcionários administrativos, calculando valores médios e totais para análise de
distribuição de custos.

O QUE RETORNA:
- Ano de competência
- Tipo de folha (Elenco ou Funcionários)
- Quantidade de folhas pagas no ano
- Valor médio de cada folha
- Valor total pago no ano

COMO FUNCIONA:
Usa UNION ALL para combinar dados de duas fontes (folha_elenco e folha_funcionarios)
em um único resultado. Para cada tipo, agrupa por ano, conta quantas folhas foram pagas,
calcula a média dos valores e soma o total anual. Considera apenas folhas com status
'aprovado' ou 'pago'. Ordena por ano (mais recente primeiro) e tipo.

USO TÍPICO: Planejamento orçamentário anual, comparação de custos entre departamentos,
identificação de tendências de crescimento de despesas, análise de sazonalidade nos gastos.
*/
SELECT * FROM vw_media_folha_anual;


-- ============================================
-- 10. CONSULTA: Movimentação Detalhada por Conta e Período
-- ============================================
/*
OBJETIVO: Apresenta o extrato completo de cada conta do plano de contas, agrupado
por mês/ano, mostrando quantidade de lançamentos, totais de entradas/saídas e saldo
do período. Funciona como um "extrato bancário" para cada conta contábil.

O QUE RETORNA:
- Código e descrição da conta contábil
- Tipo da conta
- Período (mês/ano)
- Quantidade de lançamentos no período
- Total de entradas
- Total de saídas
- Saldo do período (entradas - saídas)

COMO FUNCIONA:
Faz LEFT JOIN entre plano_de_contas e lancamento para garantir que todas as contas
apareçam, mesmo sem movimentação. Agrupa por conta e período, contando lançamentos
e somando valores separadamente para entradas e saídas. Calcula o saldo considerando
entradas como positivas e saídas como negativas. Considera apenas lançamentos aprovados.
Ordena por período (mais recente) e código da conta.

USO TÍPICO: Análise detalhada de movimentação por conta, reconciliação contábil,
identificação de contas sem movimentação, extrato para auditoria, balancete de verificação.
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
FROM vw_detalhamento_bens
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
-- RESTAURAR CONFIGURAÇÕES
-- ============================================

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
