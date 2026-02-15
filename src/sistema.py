"""
Sistema de Gestão de Clube Esportivo - Ponto de entrada.
Main e lógica de inicialização: conecta ao banco e inicia a interface.
"""
import tkinter as tk
from .banco import DB_CONFIG, DatabaseManager
from .GUI import ClubManagementApp


def main():
    root = tk.Tk()

    try:
        db = DatabaseManager(DB_CONFIG)
    except Exception:
        root.destroy()
        return

    app = ClubManagementApp(root, db)
    root.mainloop()


if __name__ == "__main__":
    main()
