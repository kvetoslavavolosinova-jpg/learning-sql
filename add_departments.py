import sqlite3

def add_departments():
    conn = sqlite3.connect("practice.db")
    cursor = conn.cursor()
    
    # Create the departments table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS departments (
        department_name TEXT PRIMARY KEY,
        manager TEXT NOT NULL,
        office_floor INTEGER NOT NULL
    );
    """)
    
    # Clean and insert department data
    cursor.execute("DELETE FROM departments;")
    
    departments_data = [
        ("Data Analytics", "Sarah Connor", 3),
        ("Sales", "Michael Jordan", 1),
        ("IT Support", "Linus Torvalds", 2),
        ("HR", "Emma Watson", 4)  # HR is empty (no employees yet)
    ]
    
    cursor.executemany("""
        INSERT INTO departments (department_name, manager, office_floor)
        VALUES (?, ?, ?);
    """, departments_data)
    
    conn.commit()
    conn.close()
    print("✔ Table 'departments' successfully added to practice.db!")

if __name__ == "__main__":
    add_departments()