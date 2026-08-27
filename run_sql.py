import sqlite3
import pandas as pd

def execute_sql_file():
    conn = sqlite3.connect("practice.db")
    try:
        # Prečítame dopyt zo súboru query.sql
        with open("query.sql", "r", encoding="utf-8") as file:
            query = file.read()
        
        # Spustíme dopyt cez Pandas pre krajší výpis
        df = pd.read_sql_query(query, conn)
        print("\n" + "="*50)
        print("                 VÝSLEDOK DOPYTU                 ")
        print("="*50)
        print(df.to_string(index=False))
        print("="*50 + "\n")
    except FileNotFoundError:
        print("❌ Chyba: Súbor 'query.sql' neexistuje. Najprv ho vytvor!")
    except Exception as e:
        print(f"❌ SQL Chyba: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    execute_sql_file()