import sqlite3
import pandas as pd
import sys


def execute_sql_file(sql_file):

    conn = sqlite3.connect("practice.db")

    try:
        with open(sql_file, "r", encoding="utf-8") as file:
            sql_script = file.read()

        # Split SQL file into individual statements
        statements = [
            statement.strip()
            for statement in sql_script.split(";")
            if statement.strip()
        ]

        for number, statement in enumerate(statements, start=1):

            # Ignore comments before checking statement type
            clean_statement = "\n".join(
                line for line in statement.splitlines()
                if not line.strip().startswith("--")
            ).strip()

            if not clean_statement:
                continue

            # SELECT query
            if clean_statement.upper().startswith("SELECT"):

                df = pd.read_sql_query(clean_statement, conn)

                print("\n" + "=" * 60)
                print(f"QUERY {number} RESULT")
                print("=" * 60)
                print(df.to_string(index=False))
                print("=" * 60)

            # Other SQL statements
            else:

                cursor = conn.cursor()
                cursor.execute(clean_statement)
                conn.commit()

                print("\n" + "=" * 60)
                print(f"SQL STATEMENT {number} EXECUTED")
                print("=" * 60)

        print("\nSQL FILE COMPLETED\n")

    except FileNotFoundError:
        print(f"❌ Error: SQL file '{sql_file}' does not exist.")

    except Exception as e:
        print(f"❌ SQL Error: {e}")

    finally:
        conn.close()


if __name__ == "__main__":

    if len(sys.argv) < 2:

        print("❌ Please provide an SQL file.")
        print()
        print("Example:")
        print(
            "python3 run_sql.py "
            "supply-chain-supplier-compliance/sql/04_supplier_performance.sql"
        )

        sys.exit(1)

    sql_file = sys.argv[1]

    execute_sql_file(sql_file)