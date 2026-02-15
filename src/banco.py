"""
Conexão com o banco de dados - pool de conexões e execução de queries.
"""
import mysql.connector
from mysql.connector import Error
from contextlib import contextmanager
from tkinter import messagebox

# ==================== CONFIGURAÇÃO DO BANCO ====================
DB_CONFIG = {
    'host': 'localhost',
    'database': 'gestao_clube',
    'user': 'root',
    'password': '2003',
    'pool_size': 3,
    'pool_reset_session': True
}


class DatabaseManager:
    """Gerenciador otimizado com pool de conexões"""

    def __init__(self, config):
        self.config = config
        self._pool = None
        self._init_pool()

    def _init_pool(self):
        try:
            self._pool = mysql.connector.pooling.MySQLConnectionPool(
                pool_name="club_pool", **self.config
            )
        except Error as e:
            messagebox.showerror("Erro Crítico", f"Falha ao conectar ao banco:\n{e}")
            raise

    @contextmanager
    def get_connection(self):
        conn = self._pool.get_connection()
        try:
            yield conn
        finally:
            conn.close()

    def execute_query(self, query, params=None):
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params) if params else cursor.execute(query)

                if cursor.description:
                    columns = [desc[0] for desc in cursor.description]
                    data = cursor.fetchall()
                    cursor.close()
                    return columns, data

                conn.commit()
                cursor.close()
                return None, None
        except Error as e:
            messagebox.showerror("Erro", f"Erro na consulta:\n{str(e)[:200]}")
            return None, None

    def get_items(self, table):
        if table == "queries_sistema":
            return self.execute_query("SELECT id_query, nome_query FROM queries_sistema ORDER BY id_query")
        if table == "views_sistema":
            return self.execute_query("SELECT id_view, nome_view FROM views_sistema ORDER BY id_view")
        raise ValueError(f"Tabela não suportada: {table}")

    def get_item_sql(self, table, item_id):
        if table == "queries_sistema":
            cols, data = self.execute_query("SELECT sql_query FROM queries_sistema WHERE id_query = %s", (item_id,))
            return data[0][0] if data else None
        if table == "views_sistema":
            cols, data = self.execute_query("SELECT sql_view FROM views_sistema WHERE id_view = %s", (item_id,))
            return data[0][0] if data else None
        raise ValueError(f"Tabela não suportada: {table}")
