"""
Sistema de Gestão de Clube Esportivo
Backend em Python com Interface Gráfica
Autor: Gabriel Galski Machado
"""

import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from mysql.connector import Error

DB_CONFIG = {
    'host': 'localhost',
    'database': 'gestao_clube',
    'user': 'root',
    'password': '2003'
}

class DatabaseManager:
    """Gerencia conexões e consultas ao banco de dados"""
    
    def __init__(self, config):
        self.config = config
        self.connection = None
    
    def connect(self):
        """Estabelece conexão com o banco de dados"""
        try:
            self.connection = mysql.connector.connect(**self.config)
            if self.connection.is_connected():
                return True
        except Error as e:
            messagebox.showerror("Erro de Conexão", f"Erro ao conectar ao banco de dados:\n{e}")
            return False
    
    def disconnect(self):
        """Fecha conexão com o banco de dados"""
        if self.connection and self.connection.is_connected():
            self.connection.close()
    
    def execute_query(self, query):
        """Executa uma consulta SQL e retorna os resultados"""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            cursor = self.connection.cursor()
            cursor.execute(query)
            
            columns = [desc[0] for desc in cursor.description]
            
            data = cursor.fetchall()
            
            cursor.close()
            
            return columns, data
        
        except Error as e:
            messagebox.showerror("Erro na Consulta", f"Erro ao executar consulta:\n{e}")
            return None, None

QUERIES = {
    "1. Lançamentos Detalhados com Responsáveis": """
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
    """,
    
    "2. Movimentação Detalhada por Conta e Período": """
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
    """,
    
    "3. Total de Patrimônio Imobilizado Atual": """
        SELECT 
            tipo_bem,
            COUNT(*) AS quantidade_bens,
            SUM(valor_aquisicao) AS valor_total_aquisicao,
            SUM(valor_contabil_atual) AS valor_total_contabil_atual,
            SUM(valor_aquisicao - valor_contabil_atual) AS depreciacao_acumulada
        FROM detalhamento_bens
        GROUP BY tipo_bem
        ORDER BY valor_total_contabil_atual DESC;
    """,
    
    "4. Balanço Mensal Simplificado": """
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
    """,
    
    "5. Resumo Financeiro Trimestral Consolidado": """
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
    """,
    
    "6. Alertas de Orçamento Registrados": """
        SELECT 
            a.id_alerta,
            d.nome AS responsavel_departamento,
            a.tipo_corpo,
            a.percentual_usado,
            CONCAT('R$ ', FORMAT(a.valor_disponivel, 2, 'pt_BR')) AS valor_disponivel,
            DATE_FORMAT(a.data_alerta, '%d/%m/%Y %H:%i:%s') AS data_hora_alerta,
            a.mensagem
        FROM alertas_orcamento a
        INNER JOIN direcao d ON a.id_direcao = d.id_direcao
        ORDER BY a.data_alerta DESC;
    """
}

VIEWS_DIRECAO = {
    "Resumo do Elenco": "SELECT * FROM resumo_elenco;",
    "Resumo dos Funcionários": "SELECT * FROM resumo_funcionarios;",
    "Ativo Imobilizado Mensal": "SELECT * FROM ativo_imobilizado_mensal;",
    "Detalhamento de Bens": "SELECT * FROM detalhamento_bens;",
    "Análise de Orçamento Mensal": "SELECT * FROM analise_orcamento_mensal;",
    "Média de Folha Anual": "SELECT * FROM media_folha_anual;"
}

class AplicacaoPrincipal:
    """Aplicação principal com janela única em tela cheia"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Sistema de Gestão do Clube Esportivo Pelotas")
        
        self.root.state('zoomed')  # Windows
        
        self.root.configure(bg='#1e3a5f')
        
        self.db = DatabaseManager(DB_CONFIG)
        
        self.origem_consulta = None
        
        if not self.db.connect():
            messagebox.showerror("Erro", "Não foi possível conectar ao banco de dados!")
            self.root.destroy()
            return
        
        self.container = tk.Frame(self.root, bg='#1e3a5f')
        self.container.pack(fill='both', expand=True)
        
        self.frames = {}
        
        self.mostrar_tela_inicial()
    
    def limpar_container(self):
        """Remove todos os widgets do container"""
        for widget in self.container.winfo_children():
            widget.destroy()
    
    def mostrar_tela_inicial(self):
        """Mostra a tela inicial com escolha de perfil"""
        self.limpar_container()
        
        main_frame = tk.Frame(self.container, bg='#1e3a5f')
        main_frame.pack(expand=True)
        
        titulo = tk.Label(
            main_frame,
            text="Sistema de Gestão\nClube Esportivo Pelotas",
            font=('Arial', 32, 'bold'),
            bg='#1e3a5f',
            fg='white'
        )
        titulo.pack(pady=(0, 50))
        
        
        subtitulo = tk.Label(
            main_frame,
            text="Selecione seu perfil de acesso:",
            font=('Arial', 18),
            bg='#1e3a5f',
            fg='#cccccc'
        )
        subtitulo.pack(pady=(0, 40))
        
        btn_style = {
            'font': ('Arial', 16, 'bold'),
            'width': 25,
            'height': 2,
            'bg': '#4CAF50',
            'fg': 'white',
            'activebackground': '#45a049',
            'activeforeground': 'white',
            'relief': 'raised',
            'bd': 4,
            'cursor': 'hand2'
        }
        
        btn_direcao = tk.Button(
            main_frame,
            text="1. Direção",
            command=self.mostrar_tela_direcao,
            **btn_style
        )
        btn_direcao.pack(pady=15)
        
        btn_style['bg'] = '#2196F3'
        btn_style['activebackground'] = '#0b7dda'
        btn_conselheiro = tk.Button(
            main_frame,
            text="2. Conselheiro",
            command=self.mostrar_tela_conselheiro,
            **btn_style
        )
        btn_conselheiro.pack(pady=15)
        
        btn_style['bg'] = '#FF9800'
        btn_style['activebackground'] = '#e68900'
        btn_socio = tk.Button(
            main_frame,
            text="3. Sócio",
            command=self.mostrar_tela_socio,
            **btn_style
        )
        btn_socio.pack(pady=15)
    
    def mostrar_tela_direcao(self):
        """Mostra a tela da Direção"""
        self.limpar_container()
        
        main_frame = tk.Frame(self.container, bg='#1e3a5f')
        main_frame.pack(expand=True)
        
        titulo = tk.Label(
            main_frame,
            text="Painel da Direção",
            font=('Arial', 28, 'bold'),
            bg='#1e3a5f',
            fg='white'
        )
        titulo.pack(pady=(0, 40))
        
        subtitulo = tk.Label(
            main_frame,
            text="Escolha uma opção:",
            font=('Arial', 18),
            bg='#1e3a5f',
            fg='#cccccc'
        )
        subtitulo.pack(pady=(0, 35))
        
        btn_style = {
            'font': ('Arial', 15, 'bold'),
            'width': 30,
            'height': 2,
            'bg': '#4CAF50',
            'fg': 'white',
            'activebackground': '#45a049',
            'activeforeground': 'white',
            'relief': 'raised',
            'bd': 4,
            'cursor': 'hand2'
        }
        
        btn_consultas = tk.Button(
            main_frame,
            text="📊 Consultas (Queries)",
            command=lambda: self.mostrar_lista_consultas(QUERIES),
            **btn_style
        )
        btn_consultas.pack(pady=20)
        
        btn_style['bg'] = '#2196F3'
        btn_style['activebackground'] = '#0b7dda'
        btn_dados = tk.Button(
            main_frame,
            text="📁 Dados (Views)",
            command=lambda: self.mostrar_lista_consultas(VIEWS_DIRECAO),
            **btn_style
        )
        btn_dados.pack(pady=20)
        
        btn_style['bg'] = '#f44336'
        btn_style['activebackground'] = '#da190b'
        btn_voltar = tk.Button(
            main_frame,
            text="⬅ Voltar",
            command=self.mostrar_tela_inicial,
            **btn_style
        )
        btn_voltar.pack(pady=20)
    
    def mostrar_tela_conselheiro(self):
        """Mostra a tela do Conselheiro com dados privados"""
        self.origem_consulta = 'perfil'

        query = "SELECT * FROM dados_privados;"
        columns, data = self.db.execute_query(query)

        if columns and data:
            self.mostrar_resultado(columns, data, "Conselheiro - Dados Privados Detalhados")
        else:
            messagebox.showwarning("Aviso", "Nenhum dado encontrado!")
    
    def mostrar_tela_socio(self):
        """Mostra a tela do Sócio com dados públicos"""
        self.origem_consulta = 'perfil'

        query = "SELECT * FROM dados_publicos;"
        columns, data = self.db.execute_query(query)

        if columns and data:
            self.mostrar_resultado(columns, data, "Sócio - Dados Públicos Consolidados")
        else:
            messagebox.showwarning("Aviso", "Nenhum dado encontrado!")
    
    def mostrar_lista_consultas(self, consultas_dict):
        """Mostra lista de consultas disponíveis"""
        self.limpar_container()
        
        if consultas_dict == QUERIES:
            self.origem_consulta = 'queries'
        else:
            self.origem_consulta = 'views'
        
        main_frame = tk.Frame(self.container, bg='#f0f0f0')
        main_frame.pack(fill='both', expand=True, padx=20, pady=20)
        
        titulo = tk.Label(
            main_frame,
            text="Selecione uma Consulta",
            font=('Arial', 24, 'bold'),
            bg='#f0f0f0',
            fg='#333333'
        )
        titulo.pack(pady=(10, 30))
        
        list_frame = tk.Frame(main_frame, bg='white', relief='sunken', bd=2)
        list_frame.pack(fill='both', expand=True, pady=(0, 20))
        
        scrollbar = tk.Scrollbar(list_frame)
        scrollbar.pack(side='right', fill='y')
        
        listbox = tk.Listbox(
            list_frame,
            font=('Arial', 13),
            yscrollcommand=scrollbar.set,
            activestyle='dotbox',
            selectbackground='#4CAF50',
            selectforeground='white',
            height=20
        )
        listbox.pack(side='left', fill='both', expand=True, padx=5, pady=5)
        scrollbar.config(command=listbox.yview)
        
        for consulta in consultas_dict.keys():
            listbox.insert('end', consulta)
        
        def executar():
            selecao = listbox.curselection()
            if not selecao:
                messagebox.showwarning("Aviso", "Selecione uma consulta!")
                return
            
            nome_consulta = listbox.get(selecao[0])
            query = consultas_dict[nome_consulta]
            
            columns, data = self.db.execute_query(query)
            
            if columns and data:
                self.mostrar_resultado(columns, data, nome_consulta)
            else:
                messagebox.showinfo("Informação", "Nenhum dado encontrado para esta consulta!")
        
        listbox.bind('<Double-Button-1>', lambda e: executar())
        
        btn_frame = tk.Frame(main_frame, bg='#f0f0f0')
        btn_frame.pack(fill='x', pady=10)
        
        btn_executar = tk.Button(
            btn_frame,
            text="🔍 Executar Consulta",
            command=executar,
            font=('Arial', 14, 'bold'),
            bg='#4CAF50',
            fg='white',
            width=20,
            height=2,
            cursor='hand2'
        )
        btn_executar.pack(side='left', padx=10)
        
        btn_voltar = tk.Button(
            btn_frame,
            text="⬅ Voltar para Direção",
            command=self.mostrar_tela_direcao,
            font=('Arial', 14, 'bold'),
            bg='#f44336',
            fg='white',
            width=22,
            height=2,
            cursor='hand2'
        )
        btn_voltar.pack(side='right', padx=10)
    
    def mostrar_resultado(self, columns, data, titulo):
        """Mostra o resultado de uma consulta"""
        self.limpar_container()
        
        main_frame = tk.Frame(self.container)
        main_frame.pack(fill='both', expand=True, padx=10, pady=10)
        
        titulo_label = tk.Label(
            main_frame,
            text=titulo,
            font=('Arial', 20, 'bold'),
            bg='#4CAF50',
            fg='white',
            pady=15
        )
        titulo_label.pack(fill='x')
        
        tree_frame = tk.Frame(main_frame)
        tree_frame.pack(fill='both', expand=True, pady=10)
        
        scroll_y = tk.Scrollbar(tree_frame, orient='vertical')
        scroll_x = tk.Scrollbar(tree_frame, orient='horizontal')
        
        tree = ttk.Treeview(
            tree_frame,
            columns=columns,
            show='headings',
            yscrollcommand=scroll_y.set,
            xscrollcommand=scroll_x.set
        )
        
        scroll_y.config(command=tree.yview)
        scroll_x.config(command=tree.xview)
        scroll_y.pack(side='right', fill='y')
        scroll_x.pack(side='bottom', fill='x')
        tree.pack(side='left', fill='both', expand=True)
        
        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=150, anchor='center')
        
        for row in data:
            tree.insert('', 'end', values=row)
        
        tree.tag_configure('oddrow', background='#f9f9f9')
        tree.tag_configure('evenrow', background='#ffffff')
        
        for i, item in enumerate(tree.get_children()):
            if i % 2 == 0:
                tree.item(item, tags=('evenrow',))
            else:
                tree.item(item, tags=('oddrow',))
        
        bottom_frame = tk.Frame(main_frame, bg='#f0f0f0')
        bottom_frame.pack(fill='x', pady=(10, 0))
        
        total_label = tk.Label(
            bottom_frame,
            text=f"Total de registros: {len(data)}",
            font=('Arial', 13, 'bold'),
            bg='#f0f0f0',
            pady=10
        )
        total_label.pack(side='left', padx=20)
        
        def voltar_lista():
            if self.origem_consulta == 'queries':
                self.mostrar_lista_consultas(QUERIES)
            elif self.origem_consulta == 'views':
                self.mostrar_lista_consultas(VIEWS_DIRECAO)
            elif self.origem_consulta == 'perfil':
                self.mostrar_tela_inicial()
            else:
                self.mostrar_tela_inicial()
        
        btn_voltar = tk.Button(
            bottom_frame,
            text="⬅ Voltar para Lista",
            command=voltar_lista,
            font=('Arial', 13, 'bold'),
            bg='#f44336',
            fg='white',
            width=18,
            height=2,
            cursor='hand2'
        )
        btn_voltar.pack(side='right', padx=20)

def main():
    root = tk.Tk()
    app = AplicacaoPrincipal(root)
    root.mainloop()

if __name__ == "__main__":
    main()