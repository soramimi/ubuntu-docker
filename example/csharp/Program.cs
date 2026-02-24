using System.Data.Odbc;

static string ConnectionString()
{
    string driver = "PostgreSQL Unicode";
    string server = "localhost";
    string database = "user";
    string uid = "user";
    string pwd = "pass";
    return $"DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={uid};PWD={pwd};";
}

using var conn = new OdbcConnection(ConnectionString());
conn.Open();

using var cmd = conn.CreateCommand();

// create table
cmd.CommandText = "CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)";
cmd.ExecuteNonQuery();

// insert data
cmd.CommandText = "INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')";
cmd.ExecuteNonQuery();

// select data
cmd.CommandText = "SELECT id, name FROM test";
using (var reader = cmd.ExecuteReader())
{
    while (reader.Read())
    {
        Console.WriteLine($"{reader["id"]}: {reader["name"]}");
    }
}

// delete data
cmd.CommandText = "DELETE FROM test";
cmd.ExecuteNonQuery();

// drop table
cmd.CommandText = "DROP TABLE test";
cmd.ExecuteNonQuery();
