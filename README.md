# Gestor-Esportivo
Sistema gerenciador de contas que simula movimentações de um clube esportivo.

<div align="center">
  <img src="https://i.imgur.com/qohE3Y3.png" width="45%" alt="Banner 1" />
  &nbsp;&nbsp;
  <img src="https://i.imgur.com/7Fk8xmI.png" width="45%" alt="Banner 2" />
</div>

---

# Sistema de Gestão Financeira — Clube Esportivo

Sistema de banco de dados relacional desenvolvido para centralizar e controlar as operações financeiras e administrativas de um clube esportivo, abrangendo elenco, funcionários e patrimônio.

---

- Desenvolvido para a cadeira de projeto de bancos de Dados (UFPEL)

## Descrição

O sistema organiza as responsabilidades entre três corpos diretivos:

**Corpo Diretivo** - Aprovação de movimentações financeiras; 
**Corpo Esportivo** - Gestão de atletas e equipe técnica;
**Corpo Financeiro** - Gestão de funcionários e patrimônio.

Cada setor possui orçamento próprio e autonomia operacional, porém **todas as movimentações dependem de aprovação do Corpo Diretivo e de saldo disponível em caixa**.

**Fluxo administrativo:**
- Folhas de pagamento e bens são registrados com `status = pendente`
- O Corpo Diretivo invoca as *procedures* de aprovação
- As procedures validam orçamento, verificam saldo e criam lançamentos contábeis automaticamente
- Entradas manuais (bilheteria, patrocínio) são inseridas diretamente com `status = aprovado`

---

## Tabelas

O banco é organizado em grupos funcionais:

### Institucional
- **`clube`** — dados institucionais básicos
- **`direcao`** — todos os membros da direção, com autenticação e dados pessoais
  - Especializações: `corpo_diretivo`, `corpo_esportivo`, `corpo_financeiro`

### Plano de Contas
- **`plano_de_contas`** — estrutura contábil por tipo de conta
- **`lancamento`** — registra todas as movimentações financeiras, conectando-se a folhas, bens e lançamentos manuais com rastreabilidade completa

### Recursos Humanos
- **`funcionarios`** → especializações `contratado` (CLT) e `terceirizado`
- **`folha_funcionarios`** + **`item_folha_f`** — folhas de pagamento com salários, bônus, adicionais e descontos

### Elenco Esportivo
- **`elenco`** → **`folha_elenco`** + **`item_folha_e`** — contratos com direitos de imagem, luvas e multas rescisórias

### Patrimônio
- **`bens`** → especializações `imoveis`, `moveis`, `automoveis` (com depreciação, área, placa etc.)
- **`ativo_imobilizado`** + **`relatorio_bens`** — relatórios e auditorias patrimoniais

### Monitoramento
- **`alertas_orcamento`** — notificações automáticas ao atingir limiares críticos de consumo orçamentário

---

## Triggers

| Trigger | Momento | Função |
|---|---|---|
| `tr_validar_saldo_lancamento` | BEFORE INSERT em `lancamento` | Bloqueia saídas aprovadas sem saldo suficiente |
| `tr_validar_orcamento_elenco` | BEFORE UPDATE em `folha_elenco` | Valida orçamento mensal e saldo antes de aprovar folha |
| `tr_validar_orcamento_funcionarios` | BEFORE UPDATE em `folha_funcionarios` | Idem para funcionários administrativos |
| `tr_alerta_orcamento_critico_elenco` | AFTER UPDATE em `folha_elenco` | Insere alerta em `alertas_orcamento` se utilização ≥ 80% |
| `tr_alerta_orcamento_critico_funcionarios` | AFTER UPDATE em `folha_funcionarios` | Idem para funcionários |

---

## Procedures

### `sp_aprovar_folha_funcionarios` / `sp_aprovar_folha_elenco`
Aprovação atômica de folhas de pagamento. Busca o valor bruto via view de totalização, atualiza o status para `aprovado` (disparando triggers de validação), cria o lançamento contábil de saída e vincula ao registro da folha.

### `sp_aprovar_bem`
Aprovação de aquisições patrimoniais. Verifica saldo via função de cálculo, cria o lançamento de saída com a data original de aquisição e atualiza o status do bem para `aprovado`.

### `sp_aprovar_lancamento_manual`
Aprovação de lançamentos manuais com status `pendente`. Para saídas, consulta o saldo atual antes de atualizar status, aprovador e data de aprovação — bloqueando operações que estourem o caixa.

---

## Views

### Auxiliares (usadas internamente)
- **`vw_item_folha_e_calculado`** / **`vw_item_folha_f_calculado`** — valor líquido por item de folha
- **`vw_folha_elenco_total`** / **`vw_folha_funcionarios_total`** — totalização por folha (bruto + líquido), consumidas por triggers e procedures

### Análise Financeira
- **Dados Públicos** — resumo por conta contábil e período mensal, sem expor detalhes individuais sensíveis
- **Dados Privados** — detalhamento completo de cada lançamento aprovado com aprovador, origem e timestamps (auditoria)
- **Balancete / Orçamento Mensal** — execução orçamentária do departamento esportivo comparando previsto vs. realizado

### Recursos Humanos
- **Resumo do Elenco** — informações contratuais de atletas com dias restantes de contrato (`DATEDIFF`) e histórico financeiro acumulado
- **Resumo de Funcionários** — diferencia contratados CLT e terceirizados via `LEFT JOIN` entre `contratado` e `terceirizado`

### Patrimônio
- **Ativo Imobilizado Mensal** — evolução mensal por tipo de bem (apenas relatórios `concluido` ou `auditado`)
- **Detalhamento de Bens** — lista bens aprovados com valor contábil atual calculado pela depreciação anual × anos decorridos

---

## Consultas Principais

- **Lançamentos completos** — todos os lançamentos com responsável e aprovador via duplo JOIN em `direcao`
- **Extrato por conta** — movimentações do plano de contas agrupadas por mês/ano, incluindo contas sem movimentação (`LEFT JOIN`)
- **Total de Patrimônio** — valor de aquisição, valor contábil e depreciação acumulada agrupados por tipo de bem
- **Balancete Mensal** — receitas, despesas e resultado do período
- **Resumo Financeiro Trimestral** — movimentações dos últimos 90 dias por tipo de conta com saldo líquido
- **Orçamento Crítico** — histórico de alertas ≥ 80% de utilização, com identificação do responsável e departamento

---
