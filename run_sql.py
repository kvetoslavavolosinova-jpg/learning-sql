import sqlite3
import pandas as pd
import sys


def execute_sql_file(sql_file):
    conn = sqlite3.connect("practice.db")

    try:
        with open(sql_file, "r", encoding="utf-8") as file:
            query = file.read()

        # Execute SQL statements that do not return data
        cursor = conn.cursor()
        cursor.executescript(query)
        conn.commit()

        print("\n" + "=" * 50)
        print("              SQL FILE EXECUTED")
        print("=" * 50)
        print(f"File: {sql_file}")
        print("=" * 50 + "\n")

    except FileNotFoundError:
        print(f"❌ Error: SQL file '{sql_file}' does not exist.")

    except Exception as e:
        print(f"❌ SQL Error: {e}")

    finally:
        conn.close()


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("❌ Please provide an SQL file.")
        print("Example: python3 run_sql.py lesson_15_supply_chain_case_study.sql")
        sys.exit(1)

    sql_file = sys.argv[1]

    execute_sql_file(sql_file)