package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/alexbrainman/odbc"
)

func connectionString() string {
	driver := "PostgreSQL Unicode"
	server := "localhost"
	database := "user"
	uid := "user"
	pwd := "pass"
	return fmt.Sprintf("DRIVER={%s};SERVER=%s;DATABASE=%s;UID=%s;PWD=%s;", driver, server, database, uid, pwd)
}

func main() {
	db, err := sql.Open("odbc", connectionString())
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// create table
	_, err = db.Exec("CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)")
	if err != nil {
		log.Fatal(err)
	}

	// insert data
	_, err = db.Exec("INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')")
	if err != nil {
		log.Fatal(err)
	}

	// select data
	rows, err := db.Query("SELECT id, name FROM test")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	for rows.Next() {
		var id int
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%d: %s\n", id, name)
	}

	// delete data
	_, err = db.Exec("DELETE FROM test")
	if err != nil {
		log.Fatal(err)
	}

	// drop table
	_, err = db.Exec("DROP TABLE test")
	if err != nil {
		log.Fatal(err)
	}
}
