import pyodbc

def connection_string():
    driver = "PostgreSQL Unicode"
    server = "localhost"
    database = "user"
    uid = "user"
    pwd = "pass"
    return f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={uid};PWD={pwd};"

def main():
    connstr = connection_string()
    conn = pyodbc.connect(connstr)
    cursor = conn.cursor()

    # create table
    cursor.execute("CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)")
    conn.commit()

    # insert data
    cursor.execute("INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')")
    conn.commit()

    # select data
    cursor.execute("SELECT id, name FROM test")
    records = cursor.fetchall()
    for row in records:
        print(f"{row.id}: {row.name}")

    # delete data
    cursor.execute("DELETE FROM test")
    conn.commit()

    # drop table
    cursor.execute("DROP TABLE test")
    conn.commit()

    # close
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()
