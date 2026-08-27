import sqlite3

def init_db():
    conn = sqlite3.connect("practice.db")
    cursor = conn.cursor()
    
    # Vytvorenie tabuľky zamestnancov
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS employees (
        employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        department TEXT NOT NULL,
        salary INTEGER NOT NULL,
        country TEXT NOT NULL
    );
    """)
    
    # Vyčistenie a vloženie testovacích dát
    cursor.execute("DELETE FROM employees;")
    
    employees_data = [
        ("Kvetoslava", "Volosinova", "Data Analytics", 55000, "Spain"),
        ("John", "Doe", "Sales", 45000, "USA"),
        ("Anna", "Schmidt", "Data Analytics", 62000, "Germany"),
        ("Carlos", "Santana", "IT Support", 40000, "Spain"),
        ("Sofia", "Loren", "Sales", 48000, "Italy")
    ]
    
    cursor.executemany("""
        INSERT INTO employees (first_name, last_name, department, salary, country)
        VALUES (?, ?, ?, ?, ?);
    """, employees_data)
    
    conn.commit()
    conn.close()
    print("✔ Practice database 'practice.db' initialized with test data!")

if __name__ == "__main__":
    init_db()