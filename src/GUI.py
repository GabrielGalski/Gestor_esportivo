"""
Parte visual do sistema: tema, botões, formulários, telas e diálogos.
"""
import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime, date
from mysql.connector import Error

# ==================== CONFIGURAÇÕES (perfil/corpos/tema) ====================
PERFIS = {
    'administracao': {'senha': '1', 'tipo': 'direcao', 'view': None},
    'adm': {'senha': '1', 'tipo': 'direcao', 'view': None},
    'conselheiro': {'senha': '2', 'tipo': 'conselheiro', 'view': 'dados_privados'},
    'socio': {'senha': '3', 'tipo': 'socio', 'view': 'dados_publicos'}
}

# CORREÇÃO 1: Dicionário CORPOS completo com todos os corpos
CORPOS = {
    'diretivo': {'senha': '1', 'id_direcao': 1, 'nome': 'Corpo Diretivo'},
    'financeiro': {'senha': '2', 'id_direcao': 3, 'nome': 'Corpo Financeiro'},
    'esportivo': {'senha': '3', 'id_direcao': 2, 'nome': 'Corpo Esportivo'}
}

# CORREÇÃO 2: Mapeamento direto senha -> corpo
SENHA_PARA_CORPO = {
    '1': 'diretivo',
    '2': 'financeiro',
    '3': 'esportivo'
}

# Design System - Tema Profissional
THEME = {
    'bg_primary': '#0A0E27',
    'bg_secondary': '#1A1F3A',
    'bg_card': '#252B48',
    'accent': '#4F6CFF',
    'accent_hover': '#3B52E5',
    'success': '#00D9A3',
    'danger': '#FF5370',
    'warning': '#FFA726',
    'text': '#E8EAF6',
    'text_secondary': '#9BA3C7',
    'border': '#2E3553'
}

# ==================== UI COMPONENTS ====================
class ModernButton(tk.Button):
    """Botão com estilo profissional e efeitos hover"""

    def __init__(self, parent, text, command, style='accent', **kwargs):
        colors = {
            'accent': (THEME['accent'], THEME['accent_hover']),
            'success': (THEME['success'], '#00C092'),
            'danger': (THEME['danger'], '#E53D5D'),
            'warning': (THEME['warning'], '#FF9800')
        }

        bg, hover = colors.get(style, colors['accent'])
        super().__init__(
            parent, text=text, command=command,
            font=('Segoe UI', 11, 'bold'),
            bg=bg, fg='white',
            activebackground=hover, activeforeground='white',
            relief='flat', bd=0,
            padx=25, pady=12,
            cursor='hand2',
            **kwargs
        )

        self.default_bg = bg
        self.hover_bg = hover
        self.bind('<Enter>', lambda e: self.config(bg=self.hover_bg))
        self.bind('<Leave>', lambda e: self.config(bg=self.default_bg))

class ModernEntry(tk.Entry):
    """Campo de entrada com estilo moderno"""

    def __init__(self, parent, placeholder='', **kwargs):
        super().__init__(
            parent,
            font=('Segoe UI', 11),
            bg=THEME['bg_card'],
            fg=THEME['text'],
            insertbackground=THEME['text'],
            relief='flat',
            bd=0,
            **kwargs
        )
        self.placeholder = placeholder
        self.default_fg = THEME['text']

# ==================== APLICAÇÃO PRINCIPAL ====================
class ClubManagementApp:
    """Sistema de Gestão - Interface Profissional (recebe conexão com banco)."""

    def __init__(self, root, db):
        self.root = root
        self.db = db
        self.root.title("Sistema de Gestão de Clube Esportivo")
        self.root.state('zoomed')
        self.root.configure(bg=THEME['bg_primary'])

        self.perfil_atual = None
        self.corpo_atual = None
        self.id_direcao_atual = None
        self.origem_consulta = None

        self.container = tk.Frame(self.root, bg=THEME['bg_primary'])
        self.container.pack(fill='both', expand=True)

        self._configure_styles()
        self.show_login()

    def _configure_styles(self):
        """Configura estilos do ttk Treeview"""
        style = ttk.Style()
        style.theme_use('clam')

        style.configure('Modern.Treeview',
                       background=THEME['bg_secondary'],
                       foreground=THEME['text'],
                       fieldbackground=THEME['bg_secondary'],
                       borderwidth=0,
                       font=('Segoe UI', 10))

        style.configure('Modern.Treeview.Heading',
                       background=THEME['bg_card'],
                       foreground=THEME['text'],
                       borderwidth=0,
                       font=('Segoe UI', 10, 'bold'))

        style.map('Modern.Treeview',
                 background=[('selected', THEME['accent'])],
                 foreground=[('selected', 'white')])

    def _clear_container(self):
        for widget in self.container.winfo_children():
            widget.destroy()

    @staticmethod
    def _parse_date_br(s):
        """Converte DD/MM/AAAA para string YYYY-MM-DD. Retorna None se inválido."""
        try:
            parts = s.strip().split('/')
            if len(parts) != 3:
                return None
            dia, mes, ano = int(parts[0]), int(parts[1]), int(parts[2])
            if 1 <= mes <= 12 and 1 <= dia <= 31 and ano > 0:
                return f"{ano}-{mes:02d}-{dia:02d}"
        except (ValueError, IndexError):
            pass
        return None

    def _tree_selection_dialog(self, title, columns, data, action_text, on_confirm, geometry='900x600'):
        """Dialog com Treeview e botão de ação. on_confirm(selected_id, dialog) é chamado ao confirmar."""
        dialog = tk.Toplevel(self.root)
        dialog.title(title)
        dialog.configure(bg=THEME['bg_primary'])
        dialog.geometry(geometry)
        dialog.transient(self.root)
        tk.Label(dialog, text=title, font=('Segoe UI', 18, 'bold'),
                 bg=THEME['bg_primary'], fg=THEME['text']).pack(pady=20)
        tree_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        tree_frame.pack(fill='both', expand=True, padx=20, pady=(0, 20))
        scroll_y = ttk.Scrollbar(tree_frame, orient='vertical')
        scroll_x = ttk.Scrollbar(tree_frame, orient='horizontal')
        tree = ttk.Treeview(tree_frame, columns=columns, show='headings',
                            yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set, style='Modern.Treeview')
        scroll_y.config(command=tree.yview)
        scroll_x.config(command=tree.xview)
        scroll_y.pack(side='right', fill='y')
        scroll_x.pack(side='bottom', fill='x')
        tree.pack(fill='both', expand=True)
        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=120, anchor='center')
        for row in data:
            tree.insert('', 'end', values=row)

        def do_action():
            sel = tree.selection()
            if not sel:
                messagebox.showwarning("Aviso", "Selecione um item!")
                return
            item_id = tree.item(sel[0])['values'][0]
            on_confirm(item_id, dialog)

        btn_frame = tk.Frame(dialog, bg=THEME['bg_primary'])
        btn_frame.pack(pady=20)
        ModernButton(btn_frame, text=action_text, command=do_action, style='danger').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='accent').pack(side='left', padx=5)
        return dialog

    def _visualizar(self, query, title, empty_msg):
        """Define origem_consulta, executa query e mostra resultados ou mensagem vazia."""
        self.origem_consulta = 'corpo_dashboard'
        columns, data = self.db.execute_query(query)
        if columns and data:
            self.show_results(columns, data, title)
        else:
            messagebox.showinfo("Info", empty_msg)

    # Menu do dashboard por corpo: (texto_botao, comando, estilo, ícone opcional)
    _MENU_CORPO = {
        'diretivo': [
            ('📊 ANÁLISE DE DADOS', lambda s: s.show_dashboard(), 'accent'),
            ('💰 GERAR LANÇAMENTO', lambda s: s.gerar_lancamento_manual(), 'accent'),
        ],
        'esportivo': [
            ('👥 VISUALIZAR ELENCO', lambda s: s.visualizar_elenco(), 'accent'),
            ('📋 GERAR FOLHA DE ELENCO', lambda s: s.gerar_folha_elenco(), 'accent'),
            ('⚽ ADICIONAR ATLETA', lambda s: s.adicionar_jogador(), 'success'),
            ('❌ ENCERRAR CONTRATO', lambda s: s.encerrar_contrato_jogador(), 'danger'),
        ],
        'financeiro': [
            ('🏛️ VISUALIZAR BENS', lambda s: s.visualizar_bens(), 'accent'),
            ('👥 VISUALIZAR FUNCIONÁRIOS', lambda s: s.visualizar_funcionarios(), 'accent'),
            ('📋 GERAR FOLHA DE FUNCIONÁRIOS', lambda s: s.gerar_folha_funcionarios(), 'accent'),
            ('👤 CONTRATAR FUNCIONÁRIO', lambda s: s.contratar_funcionario(), 'success'),
            ('❌ DEMITIR FUNCIONÁRIO', lambda s: s.demitir_funcionario(), 'danger'),
            ('🏢 ADICIONAR BEM', lambda s: s.adicionar_bem(), 'success'),
            ('🗑️ DAR BAIXA EM BEM', lambda s: s.dar_baixa_bem(), 'danger'),
        ],
    }

    # ==================== TELAS DE LOGIN ====================

    def show_login(self):
        """Tela de login moderna"""
        self._clear_container()

        # Resetar variáveis ao fazer logout
        self.corpo_atual = None
        self.id_direcao_atual = None
        self.origem_consulta = None

        frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        frame.place(relx=0.5, rely=0.5, anchor='center')

        # Logo/Título
        tk.Label(
            frame,
            text="🏆",
            font=('Segoe UI', 60),
            bg=THEME['bg_primary'],
            fg=THEME['accent']
        ).pack(pady=(0, 10))

        tk.Label(
            frame,
            text="Sistema de Gestão\nClube Esportivo",
            font=('Segoe UI', 26, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text'],
            justify='center'
        ).pack(pady=(0, 40))

        # Card de Login
        login_card = tk.Frame(frame, bg=THEME['bg_secondary'], padx=50, pady=40)
        login_card.pack()

        tk.Label(
            login_card,
            text="Usuário",
            font=('Segoe UI', 10),
            bg=THEME['bg_secondary'],
            fg=THEME['text_secondary'],
            anchor='w'
        ).pack(fill='x', pady=(0, 5))

        self.entry_user = ModernEntry(login_card, width=30)
        self.entry_user.pack(ipady=10, pady=(0, 20))

        tk.Label(
            login_card,
            text="Senha",
            font=('Segoe UI', 10),
            bg=THEME['bg_secondary'],
            fg=THEME['text_secondary'],
            anchor='w'
        ).pack(fill='x', pady=(0, 5))

        self.entry_pass = ModernEntry(login_card, show='●', width=30)
        self.entry_pass.pack(ipady=10, pady=(0, 30))

        ModernButton(
            login_card,
            text="ENTRAR",
            command=self._validate_login,
            style='accent'
        ).pack(fill='x', ipady=5)

        self.entry_user.focus()
        self.entry_user.bind('<Return>', lambda e: self.entry_pass.focus())
        self.entry_pass.bind('<Return>', lambda e: self._validate_login())

    def _validate_login(self):
        """Validação de login"""
        user = self.entry_user.get().strip().lower().replace('ç', 'c').replace('á', 'a').replace('ã', 'a')
        password = self.entry_pass.get().strip()

        perfil = PERFIS.get(user)

        if perfil and perfil['senha'] == password:
            self.perfil_atual = perfil['tipo']

            if perfil['view']:  # Conselheiro ou Sócio
                self._show_profile_data(perfil['view'])
            else:  # Direção - vai para seleção de corpo
                self.show_corpo_selection()
        else:
            messagebox.showerror("Erro", "Credenciais inválidas!")
            self.entry_pass.delete(0, 'end')
            self.entry_user.focus()

    def show_corpo_selection(self):
        """CORREÇÃO 3: Seleção simplificada - APENAS SENHA"""
        self._clear_container()

        frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        frame.place(relx=0.5, rely=0.5, anchor='center')

        tk.Label(
            frame,
            text="Acesse seu perfil",
            font=('Segoe UI', 32, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text']
        ).pack(pady=(0, 30))

        # Card de seleção
        card = tk.Frame(frame, bg=THEME['bg_secondary'], padx=50, pady=40)
        card.pack()

        tk.Label(
            card,
            text="Senha:",
            font=('Segoe UI', 10),
            bg=THEME['bg_secondary'],
            fg=THEME['text_secondary'],
            anchor='w'
        ).pack(fill='x', pady=(0, 5))

        self.entry_corpo_pass = ModernEntry(card, show='●', width=30)
        self.entry_corpo_pass.pack(ipady=10, pady=(0, 30))

        ModernButton(
            card,
            text="ACESSAR",
            command=self._validate_corpo,
            style='accent'
        ).pack(fill='x', ipady=5, pady=(0, 10))

        ModernButton(
            card,
            text="⬅ VOLTAR",
            command=self.show_login,
            style='danger'
        ).pack(fill='x', ipady=5)

        # Legenda com as opções
        tk.Label(
            frame,
            text="1 = Diretivo  •  2 = Financeiro  •  3 = Esportivo",
            font=('Segoe UI', 11),
            bg=THEME['bg_primary'],
            fg=THEME['text_secondary']
        ).pack(pady=(20, 0))

        self.entry_corpo_pass.focus()
        self.entry_corpo_pass.bind('<Return>', lambda e: self._validate_corpo())

    def _validate_corpo(self):
        """CORREÇÃO 4: Valida corpo usando apenas senha"""
        senha = self.entry_corpo_pass.get().strip()

        # Mapear senha diretamente para corpo
        corpo_nome = SENHA_PARA_CORPO.get(senha)

        if corpo_nome:
            corpo_info = CORPOS[corpo_nome]
            self.corpo_atual = corpo_nome
            self.id_direcao_atual = corpo_info['id_direcao']
            self.show_corpo_dashboard()
        else:
            messagebox.showerror(
                "Erro", 
                "Senha incorreta!\n\n" +
                "Senhas válidas:\n" +
                "• 1 = Corpo Diretivo\n" +
                "• 2 = Corpo Financeiro\n" +
                "• 3 = Corpo Esportivo"
            )
            self.entry_corpo_pass.delete(0, 'end')
            self.entry_corpo_pass.focus()

    # ==================== DASHBOARDS ====================

    def show_corpo_dashboard(self):
        """Dashboard específico de cada corpo"""
        self._clear_container()

        frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        frame.place(relx=0.5, rely=0.5, anchor='center')

        corpo_nome = CORPOS[self.corpo_atual]['nome']

        tk.Label(
            frame,
            text=f"{corpo_nome}",
            font=('Segoe UI', 32, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text']
        ).pack(pady=(0, 50))

        options_frame = tk.Frame(frame, bg=THEME['bg_primary'])
        options_frame.pack()

        for text, cmd, style in self._MENU_CORPO.get(self.corpo_atual, []):
            ModernButton(options_frame, text=text, command=lambda c=cmd: c(self), style=style, width=35).pack(pady=12)
        ModernButton(options_frame, text="🚪 SAIR", command=self.show_corpo_selection, style='danger', width=35).pack(pady=(30, 0))

    def show_dashboard(self):
        """Dashboard de consultas e views"""
        self._clear_container()

        frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        frame.place(relx=0.5, rely=0.5, anchor='center')

        tk.Label(
            frame,
            text="Consultas e Relatórios",
            font=('Segoe UI', 32, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text']
        ).pack(pady=(0, 50))

        options_frame = tk.Frame(frame, bg=THEME['bg_primary'])
        options_frame.pack()

        ModernButton(
            options_frame,
            text="📊 CONSULTAS",
            command=lambda: self.show_items_list('queries_sistema'),
            style='accent',
            width=30
        ).pack(pady=12)

        ModernButton(
            options_frame,
            text="📁 VIEWS",
            command=lambda: self.show_items_list('views_sistema'),
            style='accent',
            width=30
        ).pack(pady=12)

        ModernButton(
            options_frame,
            text="⬅ VOLTAR",
            command=self.show_corpo_dashboard,
            style='danger',
            width=30
        ).pack(pady=(30, 0))

    def _show_profile_data(self, view_name):
        """Exibe dados diretos para perfis não-administrativos"""
        self.origem_consulta = 'profile'
        query = f"SELECT * FROM {view_name};"
        columns, data = self.db.execute_query(query)

        if columns and data:
            title = f"Dados {'Privados' if 'privados' in view_name else 'Públicos'}"
            self.show_results(columns, data, title)
        else:
            messagebox.showwarning("Aviso", "Nenhum dado disponível!")
            self.show_login()

    # ==================== FUNCIONALIDADES CORPO DIRETIVO ====================

    def gerar_lancamento_manual(self):
        """Gera um lançamento manual"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Gerar Lançamento Manual")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("500x600")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(
            dialog,
            text="Novo Lançamento",
            font=('Segoe UI', 18, 'bold'),
            bg=THEME['bg_secondary'],
            fg=THEME['text']
        ).pack(pady=20)

        form_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_frame.pack(padx=30, fill='both', expand=True)

        campos = {}

        # Valor
        tk.Label(form_frame, text="Valor (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['valor'] = ModernEntry(form_frame, width=40)
        campos['valor'].pack(ipady=8, fill='x')

        # Tipo
        tk.Label(form_frame, text="Tipo:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['tipo'] = ttk.Combobox(form_frame, values=['entrada', 'saida'],
                                     state='readonly', font=('Segoe UI', 10))
        campos['tipo'].pack(ipady=8, fill='x')
        campos['tipo'].current(0)

        # Conta
        tk.Label(form_frame, text="ID da Conta:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['conta'] = ModernEntry(form_frame, width=40)
        campos['conta'].pack(ipady=8, fill='x')

        # Descrição
        tk.Label(form_frame, text="Descrição:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['descricao'] = tk.Text(form_frame, height=4, font=('Segoe UI', 10),
                                      bg=THEME['bg_card'], fg=THEME['text'])
        campos['descricao'].pack(fill='x')

        def salvar():
            try:
                valor = float(campos['valor'].get())
                tipo = campos['tipo'].get()
                id_conta = int(campos['conta'].get())
                descricao = campos['descricao'].get('1.0', 'end').strip()

                query = """
                INSERT INTO lancamento (valor, tipo_de_movimentacao, status_aprovacao,
                                      id_direcao, id_conta, descricao, origem, id_aprovador, data_aprovacao)
                VALUES (%s, %s, 'aprovado', %s, %s, %s, 'manual', 1, NOW());
                """

                self.db.execute_query(query, (valor, tipo, self.id_direcao_atual,
                                             id_conta, descricao))

                dialog.destroy()
            except ValueError:
                messagebox.showerror("Erro", "Valores inválidos!")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao criar lançamento: {e}")

        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=20)

        ModernButton(btn_frame, text="SALVAR", command=salvar,
                    style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy,
                    style='danger').pack(side='left', padx=5)

    def aprovar_lancamentos(self):
        """Aprova lançamentos pendentes"""
        query = """
        SELECT l.id_lancamento, l.data_registro, l.valor, l.tipo_de_movimentacao,
               l.descricao, d.nome as responsavel
        FROM lancamento l
        JOIN direcao d ON l.id_direcao = d.id_direcao
        WHERE l.status_aprovacao = 'pendente'
        ORDER BY l.data_registro;
        """

        columns, data = self.db.execute_query(query)

        if not data:
            messagebox.showinfo("Info", "Não há lançamentos pendentes!")
            return

        self._show_approval_dialog("Aprovar Lançamentos", columns, data)

    def _show_approval_dialog(self, title, columns, data):
        """Dialog para aprovação de lançamentos"""
        dialog = tk.Toplevel(self.root)
        dialog.title(title)
        dialog.configure(bg=THEME['bg_primary'])
        dialog.geometry("900x600")
        dialog.transient(self.root)

        tk.Label(
            dialog,
            text=title,
            font=('Segoe UI', 18, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text']
        ).pack(pady=20)

        tree_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        tree_frame.pack(fill='both', expand=True, padx=20, pady=(0, 20))

        scroll_y = ttk.Scrollbar(tree_frame, orient='vertical')
        tree = ttk.Treeview(
            tree_frame,
            columns=columns,
            show='headings',
            yscrollcommand=scroll_y.set,
            style='Modern.Treeview'
        )

        scroll_y.config(command=tree.yview)
        scroll_y.pack(side='right', fill='y')
        tree.pack(fill='both', expand=True)

        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=120, anchor='center')

        for row in data:
            tree.insert('', 'end', values=row)

        def aprovar_selecionado():
            selection = tree.selection()
            if not selection:
                messagebox.showwarning("Aviso", "Selecione um lançamento!")
                return

            item = tree.item(selection[0])
            id_lanc = item['values'][0]

            query = "UPDATE lancamento SET status_aprovacao = 'aprovado', id_aprovador = %s, data_aprovacao = NOW() WHERE id_lancamento = %s"
            self.db.execute_query(query, (self.id_direcao_atual, id_lanc))

            dialog.destroy()

        btn_frame = tk.Frame(dialog, bg=THEME['bg_primary'])
        btn_frame.pack(pady=20)

        ModernButton(btn_frame, text="APROVAR", command=aprovar_selecionado,
                    style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy,
                    style='danger').pack(side='left', padx=5)

    # ==================== FUNCIONALIDADES CORPO ESPORTIVO ====================

    def adicionar_jogador(self):
        """Adiciona um novo jogador ao elenco"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Adicionar Jogador")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("500x750")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(
            dialog,
            text="Novo Jogador",
            font=('Segoe UI', 18, 'bold'),
            bg=THEME['bg_secondary'],
            fg=THEME['text']
        ).pack(pady=20)

        form_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_frame.pack(padx=30, fill='both', expand=True)

        campos = {}

        # Nome
        tk.Label(form_frame, text="Nome Completo:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['nome'] = ModernEntry(form_frame, width=40)
        campos['nome'].pack(ipady=8, fill='x')

        # Função
        tk.Label(form_frame, text="Função/Posição:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['funcao'] = ModernEntry(form_frame, width=40)
        campos['funcao'].pack(ipady=8, fill='x')

        # Salário Base
        tk.Label(form_frame, text="Salário Base (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['salario'] = ModernEntry(form_frame, width=40)
        campos['salario'].pack(ipady=8, fill='x')

        # Multa
        tk.Label(form_frame, text="Multa Rescisória (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['multa'] = ModernEntry(form_frame, width=40)
        campos['multa'].pack(ipady=8, fill='x')

        # Luvas
        tk.Label(form_frame, text="Luvas (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['luvas'] = ModernEntry(form_frame, width=40)
        campos['luvas'].pack(ipady=8, fill='x')

        # Datas
        tk.Label(form_frame, text="Início Contrato (DD/MM/AAAA):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['inicio'] = ModernEntry(form_frame, width=40)
        campos['inicio'].pack(ipady=8, fill='x')
        campos['inicio'].insert(0, date.today().strftime('%d/%m/%Y'))

        tk.Label(form_frame, text="Fim Contrato (DD/MM/AAAA):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['fim'] = ModernEntry(form_frame, width=40)
        campos['fim'].pack(ipady=8, fill='x')

        def salvar():
            try:
                # Converter datas de DD/MM/AAAA para AAAA-MM-DD
                data_inicio_br = campos['inicio'].get()
                data_fim_br = campos['fim'].get()
                
                dia_i, mes_i, ano_i = data_inicio_br.split('/')
                data_inicio = f"{ano_i}-{mes_i}-{dia_i}"
                
                dia_f, mes_f, ano_f = data_fim_br.split('/')
                data_fim = f"{ano_f}-{mes_f}-{dia_f}"
                
                query = """
                INSERT INTO elenco (nome_jogador, funcao, multa, luvas,
                                   inicio_contrato, fim_contrato, passe_data_contrato, id_direcao)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
                """

                valores = (
                    campos['nome'].get(),
                    campos['funcao'].get(),
                    float(campos['multa'].get()),
                    float(campos['luvas'].get()),
                    data_inicio,
                    data_fim,
                    data_inicio,
                    self.id_direcao_atual
                )

                self.db.execute_query(query, valores)
                dialog.destroy()
            except ValueError as ve:
                messagebox.showerror("Erro", "Data inválida! Use o formato DD/MM/AAAA")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao adicionar jogador: {e}")

        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=20)

        ModernButton(btn_frame, text="SALVAR", command=salvar, style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='danger').pack(side='left', padx=5)

    def gerar_folha_elenco(self):
        """Gera folha: lista todos os jogadores; ao clicar pode adicionar bônus, direitos de imagem, parcela das luvas e descontos; gera com salário base + valores informados."""
        cols, rows = self.db.execute_query("""
            SELECT e.id_elenco, e.nome_jogador, e.funcao,
                COALESCE((SELECT ife.salario_base FROM item_folha_e ife WHERE ife.id_elenco = e.id_elenco ORDER BY ife.id_folha_elenco DESC LIMIT 1), 0) AS salario_base
            FROM elenco e
            WHERE e.id_direcao = %s AND e.fim_contrato >= CURDATE()
            ORDER BY e.id_elenco
        """, (self.id_direcao_atual,))
        if not rows:
            messagebox.showinfo("Info", "Não há jogadores com contrato ativo!")
            return
        itens = {r[0]: {'salario_base': float(r[3]), 'bonus': 0.0, 'direito_imagem': 0.0, 'parcela_luvas': 0.0, 'descontos': 0.0} for r in rows}

        dialog = tk.Toplevel(self.root)
        dialog.title("Gerar Folha de Elenco")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("900x550")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(dialog, text="Jogadores — clique em um para definir bônus, direitos de imagem, parcela das luvas e descontos",
                 font=('Segoe UI', 14, 'bold'), bg=THEME['bg_secondary'], fg=THEME['text']).pack(pady=(15, 5))
        tk.Label(dialog, text="Se não definir nada, será usado apenas o salário base.",
                 font=('Segoe UI', 10), bg=THEME['bg_secondary'], fg=THEME['text_secondary']).pack(pady=(0, 10))

        form_row = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_row.pack(fill='x', padx=20)
        tk.Label(form_row, text="Competência (DD/MM/AAAA):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(side='left', padx=(0, 5))
        data_comp = ModernEntry(form_row, width=14)
        data_comp.pack(side='left', ipady=6, padx=(0, 20))
        data_comp.insert(0, f"01/{date.today().strftime('%m/%Y')}")
        tk.Label(form_row, text="Pagamento (DD/MM/AAAA):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(side='left', padx=(0, 5))
        data_pag = ModernEntry(form_row, width=14)
        data_pag.pack(side='left', ipady=6)
        data_pag.insert(0, date.today().strftime('%d/%m/%Y'))

        list_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        list_frame.pack(fill='both', expand=True, padx=20, pady=10)
        scroll_y = ttk.Scrollbar(list_frame, orient='vertical')
        scroll_x = ttk.Scrollbar(list_frame, orient='horizontal')
        col_names = ('id_elenco', 'nome_jogador', 'funcao', 'salario_base', 'bonus', 'direito_imagem', 'parcela_luvas', 'descontos')
        tree = ttk.Treeview(list_frame, columns=col_names, show='headings', height=12,
                            yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set, style='Modern.Treeview')
        scroll_y.config(command=tree.yview)
        scroll_x.config(command=tree.xview)
        scroll_y.pack(side='right', fill='y')
        scroll_x.pack(side='bottom', fill='x')
        tree.pack(fill='both', expand=True)
        for c in col_names:
            tree.heading(c, text=c)
            tree.column(c, width=95, anchor='center')
        tree.column('nome_jogador', width=140)

        def refresh_tree():
            tree.delete(*tree.get_children())
            for r in rows:
                id_e = r[0]
                v = itens[id_e]
                tree.insert('', 'end', values=(
                    id_e, r[1], r[2],
                    f"{v['salario_base']:.2f}", f"{v['bonus']:.2f}", f"{v['direito_imagem']:.2f}",
                    f"{v['parcela_luvas']:.2f}", f"{v['descontos']:.2f}"
                ), iid=str(id_e))

        def editar_item():
            sel = tree.selection()
            if not sel:
                messagebox.showwarning("Aviso", "Selecione um jogador na lista.")
                return
            id_e = int(sel[0])
            v = itens[id_e]
            row_e = next((r for r in rows if r[0] == id_e), None)
            nome_txt = row_e[1] if row_e else ""
            pop = tk.Toplevel(dialog)
            pop.title("Valores da folha")
            pop.configure(bg=THEME['bg_secondary'])
            pop.geometry("600x600")
            pop.transient(dialog)
            pop.grab_set()
            tk.Label(pop, text=f"Jogador: {nome_txt}", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10, 'bold')).pack(pady=(10, 8))
            tk.Label(pop, text="Salário base (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(6, 2))
            e_sal = ModernEntry(pop, width=20)
            e_sal.pack(ipady=6, padx=20, fill='x')
            e_sal.insert(0, str(v['salario_base']))
            tk.Label(pop, text="Bônus (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(6, 2))
            e_bonus = ModernEntry(pop, width=20)
            e_bonus.pack(ipady=6, padx=20, fill='x')
            e_bonus.insert(0, str(v['bonus']))
            tk.Label(pop, text="Direitos de imagem (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(6, 2))
            e_di = ModernEntry(pop, width=20)
            e_di.pack(ipady=6, padx=20, fill='x')
            e_di.insert(0, str(v['direito_imagem']))
            tk.Label(pop, text="Parcela das luvas (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(6, 2))
            e_luvas = ModernEntry(pop, width=20)
            e_luvas.pack(ipady=6, padx=20, fill='x')
            e_luvas.insert(0, str(v['parcela_luvas']))
            tk.Label(pop, text="Descontos (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(6, 2))
            e_descontos = ModernEntry(pop, width=20)
            e_descontos.pack(ipady=6, padx=20, fill='x')
            e_descontos.insert(0, str(v['descontos']))
            def ok():
                try:
                    itens[id_e]['salario_base'] = float(e_sal.get() or 0)
                    itens[id_e]['bonus'] = float(e_bonus.get() or 0)
                    itens[id_e]['direito_imagem'] = float(e_di.get() or 0)
                    itens[id_e]['parcela_luvas'] = float(e_luvas.get() or 0)
                    itens[id_e]['descontos'] = float(e_descontos.get() or 0)
                    refresh_tree()
                    pop.destroy()
                except ValueError:
                    messagebox.showerror("Erro", "Use números válidos.")
            tk.Frame(pop, bg=THEME['bg_secondary']).pack(fill='x', pady=12)
            ModernButton(pop, text="OK", command=ok, style='success').pack(side='left', padx=20)
            ModernButton(pop, text="Cancelar", command=pop.destroy, style='danger').pack(side='left')

        tree.bind('<Double-1>', lambda e: editar_item())

        def gerar():
            data_comp_sql = self._parse_date_br(data_comp.get())
            data_pag_sql = self._parse_date_br(data_pag.get())
            if not data_comp_sql or not data_pag_sql:
                messagebox.showerror("Erro", "Datas inválidas. Use DD/MM/AAAA.")
                return
            valor_direitos_folha = sum(v['direito_imagem'] for v in itens.values())
            try:
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute("""
                            INSERT INTO folha_elenco (data_competencia, data_pagamento, valor_direitos_imagem, status, id_direcao)
                            VALUES (%s, %s, %s, 'pendente', %s)
                        """, (data_comp_sql, data_pag_sql, valor_direitos_folha, self.id_direcao_atual))
                        id_folha = cursor.lastrowid
                        for id_e, v in itens.items():
                            cursor.execute("""
                                INSERT INTO item_folha_e (salario_base, bonus, direito_imagem, parcela_luvas, descontos, id_folha_elenco, id_elenco)
                                VALUES (%s, %s, %s, %s, %s, %s, %s)
                            """, (v['salario_base'], v['bonus'], v['direito_imagem'], v['parcela_luvas'], v['descontos'], id_folha, id_e))
                        cursor.execute("CALL sp_aprovar_folha_elenco(%s, %s, %s)", (id_folha, 1, 8))
                        conn.commit()
                        cursor.close()
                        total = sum(v['salario_base'] + v['bonus'] + v['direito_imagem'] + v['parcela_luvas'] - v['descontos'] for v in itens.values())
                        messagebox.showinfo("Sucesso", f"Folha de elenco gerada e aprovada.\n{len(itens)} jogadores. Total líquido estimado: R$ {total:,.2f}")
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cursor.close()
                        messagebox.showerror("Erro", str(e))
            except Exception as e:
                messagebox.showerror("Erro", str(e))

        refresh_tree()
        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=15)
        ModernButton(btn_frame, text="EDITAR ITEM (duplo clique)", command=editar_item, style='accent').pack(side='left', padx=5)
        ModernButton(btn_frame, text="GERAR FOLHA", command=gerar, style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='danger').pack(side='left', padx=5)

    def encerrar_contrato_jogador(self):
        """Encerra contrato: remove atleta e seus dados do banco (item_folha_e, elenco)."""
        columns, data = self.db.execute_query("""
            SELECT id_elenco, nome_jogador, funcao,
                   DATE_FORMAT(fim_contrato, '%d/%m/%Y') as fim_contrato
            FROM elenco WHERE fim_contrato >= CURDATE() ORDER BY nome_jogador
        """)
        if not data:
            messagebox.showinfo("Info", "Não há jogadores com contratos ativos!")
            return

        def on_confirm(item_id, dialog):
            if not messagebox.askyesno("Confirmação", "Remover este atleta e seus dados do banco?"):
                return
            try:
                with self.db.get_connection() as conn:
                    cur = conn.cursor()
                    try:
                        cur.execute("DELETE FROM item_folha_e WHERE id_elenco = %s", (item_id,))
                        cur.execute("DELETE FROM elenco WHERE id_elenco = %s", (item_id,))
                        conn.commit()
                        cur.close()
                        messagebox.showinfo("Sucesso", "Contrato encerrado e dados do atleta removidos.")
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cur.close()
                        messagebox.showerror("Erro", str(e))
            except Exception as e:
                messagebox.showerror("Erro", str(e))

        self._tree_selection_dialog(
            "Encerrar Contrato (atleta e dados serão removidos do banco)",
            columns, data, "ENCERRAR CONTRATO", on_confirm
        )

    def visualizar_elenco(self):
        """Visualiza elenco completo"""
        self._visualizar("SELECT * FROM resumo_elenco;", "Elenco Completo", "Nenhum jogador cadastrado!")

    # ==================== FUNCIONALIDADES CORPO FINANCEIRO ====================

    def contratar_funcionario(self):
        """Contrata um novo funcionário"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Contratar Funcionário")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("500x650")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(
            dialog,
            text="Novo Funcionário",
            font=('Segoe UI', 18, 'bold'),
            bg=THEME['bg_secondary'],
            fg=THEME['text']
        ).pack(pady=20)

        form_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_frame.pack(padx=30, fill='both', expand=True)

        campos = {}

        # ID Contrato
        tk.Label(form_frame, text="ID Contrato:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['id_contrato'] = ModernEntry(form_frame, width=40)
        campos['id_contrato'].pack(ipady=8, fill='x')

        # Salário
        tk.Label(form_frame, text="Salário (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['salario'] = ModernEntry(form_frame, width=40)
        campos['salario'].pack(ipady=8, fill='x')

        # Cargo
        tk.Label(form_frame, text="Cargo:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['cargo'] = ModernEntry(form_frame, width=40)
        campos['cargo'].pack(ipady=8, fill='x')

        # Setor
        tk.Label(form_frame, text="Setor:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['setor'] = ModernEntry(form_frame, width=40)
        campos['setor'].pack(ipady=8, fill='x')

        # Tipo
        tk.Label(form_frame, text="Tipo:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['tipo'] = ttk.Combobox(form_frame, values=['contratado', 'terceirizado'],
                                     state='readonly', font=('Segoe UI', 10))
        campos['tipo'].pack(ipady=8, fill='x')
        campos['tipo'].current(0)

        def salvar():
            try:
                # Usar uma única conexão para INSERT em funcionarios e contratado (evita FK: LAST_INSERT_ID em outra conexão seria 0)
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute("""
                            INSERT INTO funcionarios (id_contrato, salario, cargo, setor, tipo_funcionario, id_direcao)
                            VALUES (%s, %s, %s, %s, %s, %s)
                        """, (
                            campos['id_contrato'].get(),
                            float(campos['salario'].get()),
                            campos['cargo'].get(),
                            campos['setor'].get(),
                            campos['tipo'].get(),
                            self.id_direcao_atual
                        ))
                        id_func = cursor.lastrowid
                        if campos['tipo'].get() == 'contratado':
                            data_adm = datetime.now().strftime('%Y-%m-%d')
                            cursor.execute(
                                "INSERT INTO contratado (id_funcionario, data_admissao) VALUES (%s, %s)",
                                (id_func, data_adm)
                            )
                        conn.commit()
                        cursor.close()
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cursor.close()
                        messagebox.showerror("Erro", f"Erro ao contratar funcionário:\n{str(e)}")
                        return
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao contratar funcionário: {e}")

        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=20)

        ModernButton(btn_frame, text="SALVAR", command=salvar, style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='danger').pack(side='left', padx=5)

    def gerar_folha_funcionarios(self):
        """Gera folha: lista todos os funcionários; ao clicar pode adicionar bônus, descontos e adicionais; gera com salário base + valores informados."""
        cols, rows = self.db.execute_query("""
            SELECT id_funcionario, id_contrato, cargo, setor, salario
            FROM funcionarios WHERE id_direcao = %s ORDER BY id_funcionario
        """, (self.id_direcao_atual,))
        if not rows:
            messagebox.showinfo("Info", "Não há funcionários cadastrados!")
            return
        # itens[id_func] = {salario_base, bonus, descontos, adicionais}
        itens = {r[0]: {'salario_base': float(r[4]), 'bonus': 0.0, 'descontos': 0.0, 'adicionais': 0.0} for r in rows}

        dialog = tk.Toplevel(self.root)
        dialog.title("Gerar Folha de Funcionários")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("800x550")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(dialog, text="Funcionários — clique em um para definir bônus, descontos e adicionais",
                 font=('Segoe UI', 14, 'bold'), bg=THEME['bg_secondary'], fg=THEME['text']).pack(pady=(15, 5))
        tk.Label(dialog, text="Se não definir nada, será usado apenas o salário base.",
                 font=('Segoe UI', 10), bg=THEME['bg_secondary'], fg=THEME['text_secondary']).pack(pady=(0, 10))

        form_row = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_row.pack(fill='x', padx=20)
        tk.Label(form_row, text="Competência (DD/MM/AAAA):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(side='left', padx=(0, 5))
        data_comp = ModernEntry(form_row, width=14)
        data_comp.pack(side='left', ipady=6, padx=(0, 20))
        data_comp.insert(0, f"01/{date.today().strftime('%m/%Y')}")
        tk.Label(form_row, text="Pagamento (DD/MM/AAAA):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(side='left', padx=(0, 5))
        data_pag = ModernEntry(form_row, width=14)
        data_pag.pack(side='left', ipady=6)
        data_pag.insert(0, date.today().strftime('%d/%m/%Y'))

        list_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        list_frame.pack(fill='both', expand=True, padx=20, pady=10)
        scroll_y = ttk.Scrollbar(list_frame, orient='vertical')
        scroll_x = ttk.Scrollbar(list_frame, orient='horizontal')
        col_names = ('id_funcionario', 'id_contrato', 'cargo', 'setor', 'salario_base', 'bonus', 'descontos', 'adicionais')
        tree = ttk.Treeview(list_frame, columns=col_names, show='headings', height=12,
                            yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set, style='Modern.Treeview')
        scroll_y.config(command=tree.yview)
        scroll_x.config(command=tree.xview)
        scroll_y.pack(side='right', fill='y')
        scroll_x.pack(side='bottom', fill='x')
        tree.pack(fill='both', expand=True)
        for c in col_names:
            tree.heading(c, text=c)
            tree.column(c, width=90, anchor='center')
        tree.column('cargo', width=120)
        tree.column('setor', width=100)

        def refresh_tree():
            tree.delete(*tree.get_children())
            for r in rows:
                id_f = r[0]
                v = itens[id_f]
                tree.insert('', 'end', values=(
                    id_f, r[1], r[2], r[3],
                    f"{v['salario_base']:.2f}", f"{v['bonus']:.2f}", f"{v['descontos']:.2f}", f"{v['adicionais']:.2f}"
                ), iid=str(id_f))

        def editar_item():
            sel = tree.selection()
            if not sel:
                messagebox.showwarning("Aviso", "Selecione um funcionário na lista.")
                return
            id_f = int(sel[0])
            v = itens[id_f]
            row_f = next((r for r in rows if r[0] == id_f), None)
            cargo_txt = row_f[2] if row_f else ""
            pop = tk.Toplevel(dialog)
            pop.title("Bônus, descontos e adicionais")
            pop.configure(bg=THEME['bg_secondary'])
            pop.geometry("600x600")
            pop.transient(dialog)
            pop.grab_set()
            tk.Label(pop, text=f"Funcionário ID {id_f} — Cargo: {cargo_txt}", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(pady=(10, 5))
            tk.Label(pop, text="Bônus (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(8, 2))
            e_bonus = ModernEntry(pop, width=20)
            e_bonus.pack(ipady=6, padx=20, fill='x')
            e_bonus.insert(0, str(v['bonus']))
            tk.Label(pop, text="Descontos (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(8, 2))
            e_descontos = ModernEntry(pop, width=20)
            e_descontos.pack(ipady=6, padx=20, fill='x')
            e_descontos.insert(0, str(v['descontos']))
            tk.Label(pop, text="Adicionais (R$):", bg=THEME['bg_secondary'], fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', padx=20, pady=(8, 2))
            e_adicionais = ModernEntry(pop, width=20)
            e_adicionais.pack(ipady=6, padx=20, fill='x')
            e_adicionais.insert(0, str(v['adicionais']))
            def ok():
                try:
                    itens[id_f]['bonus'] = float(e_bonus.get() or 0)
                    itens[id_f]['descontos'] = float(e_descontos.get() or 0)
                    itens[id_f]['adicionais'] = float(e_adicionais.get() or 0)
                    refresh_tree()
                    pop.destroy()
                except ValueError:
                    messagebox.showerror("Erro", "Use números válidos.")
            tk.Frame(pop, bg=THEME['bg_secondary']).pack(fill='x', pady=15)
            ModernButton(pop, text="OK", command=ok, style='success').pack(side='left', padx=20)
            ModernButton(pop, text="Cancelar", command=pop.destroy, style='danger').pack(side='left')

        tree.bind('<Double-1>', lambda e: editar_item())

        def gerar():
            data_comp_sql = self._parse_date_br(data_comp.get())
            data_pag_sql = self._parse_date_br(data_pag.get())
            if not data_comp_sql or not data_pag_sql:
                messagebox.showerror("Erro", "Datas inválidas. Use DD/MM/AAAA.")
                return
            try:
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute("""
                            INSERT INTO folha_funcionarios (data_competencia, data_pagamento, status, id_direcao)
                            VALUES (%s, %s, 'pendente', %s)
                        """, (data_comp_sql, data_pag_sql, self.id_direcao_atual))
                        id_folha = cursor.lastrowid
                        for id_f, v in itens.items():
                            cursor.execute("""
                                INSERT INTO item_folha_f (salario_base, bonus, descontos, adicionais, id_folha_funcionarios, id_funcionario)
                                VALUES (%s, %s, %s, %s, %s, %s)
                            """, (v['salario_base'], v['bonus'], v['descontos'], v['adicionais'], id_folha, id_f))
                        cursor.execute("CALL sp_aprovar_folha_funcionarios(%s, %s, %s)", (id_folha, 1, 9))
                        conn.commit()
                        cursor.close()
                        total = sum(v['salario_base'] + v['bonus'] + v['adicionais'] - v['descontos'] for v in itens.values())
                        messagebox.showinfo("Sucesso", f"Folha de funcionários gerada e aprovada.\n{len(itens)} funcionários. Total líquido estimado: R$ {total:,.2f}")
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cursor.close()
                        messagebox.showerror("Erro", str(e))
            except Exception as e:
                messagebox.showerror("Erro", str(e))

        refresh_tree()
        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=15)
        ModernButton(btn_frame, text="EDITAR ITEM (duplo clique)", command=editar_item, style='accent').pack(side='left', padx=5)
        ModernButton(btn_frame, text="GERAR FOLHA", command=gerar, style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='danger').pack(side='left', padx=5)

    def adicionar_bem(self):
        """Adiciona um novo bem patrimonial com aprovação automática"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Adicionar Bem Patrimonial")
        dialog.configure(bg=THEME['bg_secondary'])
        dialog.geometry("700x850")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(
            dialog,
            text="Novo Bem Patrimonial",
            font=('Segoe UI', 18, 'bold'),
            bg=THEME['bg_secondary'],
            fg=THEME['text']
        ).pack(pady=20)

        form_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        form_frame.pack(padx=30, fill='both', expand=True)

        campos = {}

        # Tipo de Bem
        tk.Label(form_frame, text="Tipo de Bem:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['tipo'] = ttk.Combobox(form_frame, values=['imovel', 'automovel', 'movel'],
                                     state='readonly', font=('Segoe UI', 10))
        campos['tipo'].pack(ipady=8, fill='x')
        campos['tipo'].current(0)

        # Nome do Item
        tk.Label(form_frame, text="Nome do Item:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['nome'] = ModernEntry(form_frame, width=40)
        campos['nome'].pack(ipady=8, fill='x')

        # Valor de Aquisição
        tk.Label(form_frame, text="Valor de Aquisição (R$):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['valor'] = ModernEntry(form_frame, width=40)
        campos['valor'].pack(ipady=8, fill='x')

        # Localização
        tk.Label(form_frame, text="Localização:", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['local'] = ModernEntry(form_frame, width=40)
        campos['local'].pack(ipady=8, fill='x')

        # Data de Aquisição
        tk.Label(form_frame, text="Data Aquisição (DD/MM/AAAA):", bg=THEME['bg_secondary'],
                fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
        campos['data'] = ModernEntry(form_frame, width=40)
        campos['data'].pack(ipady=8, fill='x')
        campos['data'].insert(0, date.today().strftime('%d/%m/%Y'))

        # Frame para campos específicos
        especifico_frame = tk.Frame(form_frame, bg=THEME['bg_secondary'])
        especifico_frame.pack(fill='x', pady=(20, 0))

        def atualizar_campos_especificos(*args):
            # Limpar frame
            for widget in especifico_frame.winfo_children():
                widget.destroy()
            
            tipo = campos['tipo'].get()
            
            if tipo == 'imovel':
                tk.Label(especifico_frame, text="Endereço Completo:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['endereco'] = ModernEntry(especifico_frame, width=40)
                campos['endereco'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Área (m²):", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['area'] = ModernEntry(especifico_frame, width=40)
                campos['area'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Tipo de Propriedade:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['tipo_prop'] = ModernEntry(especifico_frame, width=40)
                campos['tipo_prop'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Depreciação Anual (%):", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['depreciacao_imovel'] = ModernEntry(especifico_frame, width=40)
                campos['depreciacao_imovel'].pack(ipady=8, fill='x')
                campos['depreciacao_imovel'].insert(0, '2.00')
                
            elif tipo == 'automovel':
                tk.Label(especifico_frame, text="Tipo de Veículo:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['tipo_veiculo'] = ModernEntry(especifico_frame, width=40)
                campos['tipo_veiculo'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Placa:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['placa'] = ModernEntry(especifico_frame, width=40)
                campos['placa'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Ano:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['ano'] = ModernEntry(especifico_frame, width=40)
                campos['ano'].pack(ipady=8, fill='x')
                
                tk.Label(especifico_frame, text="Modelo:", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['modelo'] = ModernEntry(especifico_frame, width=40)
                campos['modelo'].pack(ipady=8, fill='x')
                
            elif tipo == 'movel':
                tk.Label(especifico_frame, text="Depreciação Anual (%):", bg=THEME['bg_secondary'],
                        fg=THEME['text'], font=('Segoe UI', 10)).pack(anchor='w', pady=(10, 5))
                campos['depreciacao'] = ModernEntry(especifico_frame, width=40)
                campos['depreciacao'].pack(ipady=8, fill='x')

        campos['tipo'].bind('<<ComboboxSelected>>', atualizar_campos_especificos)
        atualizar_campos_especificos()

        def salvar():
            try:
                data_br = campos['data'].get()
                dia, mes, ano = data_br.split('/')
                data_sql = f"{ano}-{mes}-{dia}"
                tipo = campos['tipo'].get()
                if tipo == 'imovel':
                    id_conta = 2
                elif tipo == 'automovel':
                    id_conta = 3
                else:
                    id_conta = 4
                # Vice-presidente (id_direcao 1) aprova automaticamente no sistema
                id_aprovador = 1
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute("""
                            INSERT INTO bens (data_aquisicao, nome_item, valor_aquisicao, localizacao, id_direcao, status_aprovacao)
                            VALUES (%s, %s, %s, %s, %s, 'pendente')
                        """, (data_sql, campos['nome'].get(), float(campos['valor'].get()),
                              campos['local'].get(), self.id_direcao_atual))
                        id_bem = cursor.lastrowid
                        if tipo == 'imovel':
                            cursor.execute("""
                                INSERT INTO imoveis (id_bem, endereco, area, tipo_propriedade, depreciacao_ano)
                                VALUES (%s, %s, %s, %s, %s)
                            """, (id_bem, campos['endereco'].get(), float(campos['area'].get()),
                                  campos['tipo_prop'].get(), float(campos['depreciacao_imovel'].get())))
                        elif tipo == 'automovel':
                            cursor.execute("""
                                INSERT INTO automoveis (id_bem, tipo, placa, ano, modelo)
                                VALUES (%s, %s, %s, %s, %s)
                            """, (id_bem, campos['tipo_veiculo'].get(), campos['placa'].get(),
                                  int(campos['ano'].get()), campos['modelo'].get()))
                        elif tipo == 'movel':
                            cursor.execute("INSERT INTO moveis (id_bem, depreciacao_ano) VALUES (%s, %s)",
                                           (id_bem, float(campos['depreciacao'].get())))
                        cursor.execute("CALL sp_aprovar_bem(%s, %s, %s)", (id_bem, id_aprovador, id_conta))
                        conn.commit()
                        cursor.close()
                        messagebox.showinfo("Sucesso", "Bem adicionado e aprovado automaticamente.")
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cursor.close()
                        messagebox.showerror("Erro", f"Erro ao adicionar bem:\n{str(e)}")
            except ValueError:
                messagebox.showerror("Erro", "Dados inválidos! Verifique os valores inseridos.")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao adicionar bem: {e}")

        btn_frame = tk.Frame(dialog, bg=THEME['bg_secondary'])
        btn_frame.pack(pady=20)

        ModernButton(btn_frame, text="SALVAR", command=salvar, style='success').pack(side='left', padx=5)
        ModernButton(btn_frame, text="CANCELAR", command=dialog.destroy, style='danger').pack(side='left', padx=5)

    def demitir_funcionario(self):
        """Demite um funcionário (remove dados do banco)."""
        columns, data = self.db.execute_query("""
            SELECT id_funcionario, id_contrato, cargo, setor, salario
            FROM funcionarios WHERE id_direcao = %s ORDER BY id_contrato
        """, (self.id_direcao_atual,))
        if not data:
            messagebox.showinfo("Info", "Não há funcionários cadastrados!")
            return

        def on_confirm(item_id, dialog):
            if not messagebox.askyesno("Confirmação", "Tem certeza que deseja demitir este funcionário? Os dados do funcionário serão removidos do banco."):
                return
            try:
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute("DELETE FROM item_folha_f WHERE id_funcionario = %s", (item_id,))
                        cursor.execute("DELETE FROM contratado WHERE id_funcionario = %s", (item_id,))
                        cursor.execute("DELETE FROM terceirizado WHERE id_funcionario = %s", (item_id,))
                        cursor.execute("DELETE FROM funcionarios WHERE id_funcionario = %s", (item_id,))
                        conn.commit()
                        cursor.close()
                        messagebox.showinfo("Sucesso", "Funcionário demitido e dados removidos do banco.")
                        dialog.destroy()
                    except Error as e:
                        conn.rollback()
                        cursor.close()
                        messagebox.showerror("Erro", f"Erro ao demitir:\n{str(e)}")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao demitir: {e}")

        self._tree_selection_dialog("Demitir Funcionário", columns, data, "DEMITIR", on_confirm)

    def dar_baixa_bem(self):
        """Dá baixa em um bem"""
        columns, data = self.db.execute_query("""
            SELECT id_bem, nome_item,
                   DATE_FORMAT(data_aquisicao, '%d/%m/%Y') as data_aquisicao,
                   FORMAT(valor_aquisicao, 2, 'pt_BR') as valor,
                   status_aprovacao
            FROM bens
            WHERE id_direcao = %s AND status_aprovacao = 'aprovado'
            ORDER BY nome_item
        """, (self.id_direcao_atual,))
        if not data:
            messagebox.showinfo("Info", "Não há bens aprovados!")
            return

        def on_confirm(item_id, dialog):
            if messagebox.askyesno("Confirmação", "Tem certeza que deseja dar baixa neste bem?"):
                self.db.execute_query("UPDATE bens SET status_aprovacao = 'baixado' WHERE id_bem = %s", (item_id,))
                dialog.destroy()

        self._tree_selection_dialog("Dar Baixa em Bem", columns, data, "DAR BAIXA", on_confirm)

    def visualizar_funcionarios(self):
        """Visualiza todos os funcionários"""
        self._visualizar("SELECT * FROM resumo_funcionarios;", "Funcionários", "Nenhum funcionário cadastrado!")

    def visualizar_bens(self):
        """Visualiza todos os bens"""
        self._visualizar("SELECT * FROM detalhamento_bens;", "Patrimônio", "Nenhum bem cadastrado!")

    # ==================== VIEWS E LISTAGENS ====================

    def show_items_list(self, table):
        """Lista de queries/views"""
        self._clear_container()
        self.origem_consulta = table

        main_frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        main_frame.pack(fill='both', expand=True, padx=30, pady=30)

        header = tk.Frame(main_frame, bg=THEME['bg_primary'])
        header.pack(fill='x', pady=(0, 20))

        title_text = "Consultas" if 'queries' in table else "Views"
        tk.Label(
            header,
            text=title_text,
            font=('Segoe UI', 24, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text']
        ).pack(side='left')

        list_frame = tk.Frame(main_frame, bg=THEME['bg_secondary'])
        list_frame.pack(fill='both', expand=True)

        scrollbar = tk.Scrollbar(list_frame, bg=THEME['bg_card'])
        scrollbar.pack(side='right', fill='y')

        listbox = tk.Listbox(
            list_frame,
            font=('Segoe UI', 12),
            bg=THEME['bg_secondary'],
            fg=THEME['text'],
            selectbackground=THEME['accent'],
            selectforeground='white',
            yscrollcommand=scrollbar.set,
            relief='flat',
            bd=0,
            highlightthickness=0,
            activestyle='none'
        )
        listbox.pack(side='left', fill='both', expand=True, padx=20, pady=20)
        scrollbar.config(command=listbox.yview)

        columns, data = self.db.get_items(table)

        if not data:
            messagebox.showwarning("Aviso", "Nenhum item encontrado!")
            self.show_dashboard()
            return

        items_dict = {row[1]: row[0] for row in data}

        for name in items_dict.keys():
            listbox.insert('end', f"  {name}")

        def execute_item():
            if not listbox.curselection():
                messagebox.showwarning("Aviso", "Selecione um item!")
                return

            name = listbox.get(listbox.curselection()[0]).strip()
            item_id = items_dict[name]
            query_sql = self.db.get_item_sql(table, item_id)

            if not query_sql:
                messagebox.showerror("Erro", "Não foi possível carregar!")
                return

            columns, data = self.db.execute_query(query_sql)

            if columns and data:
                self.show_results(columns, data, name)
            else:
                messagebox.showinfo("Info", "Nenhum resultado encontrado!")

        listbox.bind('<Double-Button-1>', lambda e: execute_item())

        btn_frame = tk.Frame(main_frame, bg=THEME['bg_primary'])
        btn_frame.pack(fill='x', pady=(20, 0))

        ModernButton(
            btn_frame,
            text="🔍 EXECUTAR",
            command=execute_item,
            style='success'
        ).pack(side='left', padx=(0, 10))

        ModernButton(
            btn_frame,
            text="⬅ VOLTAR",
            command=self.show_dashboard,
            style='danger'
        ).pack(side='right')

    def show_results(self, columns, data, title):
        self._clear_container()

        main_frame = tk.Frame(self.container, bg=THEME['bg_primary'])
        main_frame.pack(fill='both', expand=True, padx=20, pady=20)

        header = tk.Frame(main_frame, bg=THEME['accent'], height=80)
        header.pack(fill='x')
        header.pack_propagate(False)

        tk.Label(
            header,
            text=title,
            font=('Segoe UI', 20, 'bold'),
            bg=THEME['accent'],
            fg='white'
        ).pack(expand=True)

        tree_frame = tk.Frame(main_frame, bg=THEME['bg_secondary'])
        tree_frame.pack(fill='both', expand=True, pady=(20, 0))

        scroll_y = ttk.Scrollbar(tree_frame, orient='vertical')
        scroll_x = ttk.Scrollbar(tree_frame, orient='horizontal')

        tree = ttk.Treeview(
            tree_frame,
            columns=columns,
            show='headings',
            yscrollcommand=scroll_y.set,
            xscrollcommand=scroll_x.set,
            style='Modern.Treeview'
        )

        scroll_y.config(command=tree.yview)
        scroll_x.config(command=tree.xview)
        scroll_y.pack(side='right', fill='y')
        scroll_x.pack(side='bottom', fill='x')
        tree.pack(fill='both', expand=True)

        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=150, anchor='center')

        for row in data:
            tree.insert('', 'end', values=row)

        footer = tk.Frame(main_frame, bg=THEME['bg_primary'])
        footer.pack(fill='x', pady=(20, 0))

        tk.Label(
            footer,
            text=f"Total: {len(data)} registro(s)",
            font=('Segoe UI', 11, 'bold'),
            bg=THEME['bg_primary'],
            fg=THEME['text_secondary']
        ).pack(side='left')

        def go_back():
            if self.origem_consulta == 'profile':
                self.show_login()
            elif self.origem_consulta == 'corpo_dashboard':
                self.show_corpo_dashboard()
            elif self.origem_consulta:
                self.show_items_list(self.origem_consulta)
            elif self.corpo_atual:
                self.show_corpo_dashboard()
            else:
                self.show_login()

        ModernButton(
            footer,
            text="⬅ VOLTAR",
            command=go_back,
            style='danger'
        ).pack(side='right')

# Ponto de entrada: sistema.py (main e lógica de inicialização)
