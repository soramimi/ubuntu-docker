use odbc_api::{buffers::TextRowSet, ConnectionOptions, Cursor, Environment};

fn connection_string() -> String {
    let driver = "PostgreSQL Unicode";
    let server = "localhost";
    let database = "user";
    let uid = "user";
    let pwd = "pass";
    format!("DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={uid};PWD={pwd};")
}

fn main() -> Result<(), odbc_api::Error> {
    let env = Environment::new()?;
    let conn = env.connect_with_connection_string(&connection_string(), ConnectionOptions::default())?;

    // create table

    conn.execute(
        "CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)",
        (),
    )?;

    // insert data

    conn.execute(
        "INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')",
        (),
    )?;

    // select data

    if let Some(mut cursor) = conn.execute("SELECT id, name FROM test", ())? {
        let mut buffers = TextRowSet::for_cursor(100, &mut cursor, Some(256))?;
        let mut row_set_cursor = cursor.bind_buffer(&mut buffers)?;
        while let Some(batch) = row_set_cursor.fetch()? {
            for row_index in 0..batch.num_rows() {
                let id = batch.at(0, row_index).unwrap_or(b"");
                let name = batch.at(1, row_index).unwrap_or(b"");
                println!(
                    "{}: {}",
                    std::str::from_utf8(id).unwrap_or(""),
                    std::str::from_utf8(name).unwrap_or("")
                );
            }
        }
    }

    // delete data

    conn.execute("DELETE FROM test", ())?;

    // drop table

    conn.execute("DROP TABLE test", ())?;

    Ok(())
}
