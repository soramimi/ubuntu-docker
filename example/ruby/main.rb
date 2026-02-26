require 'pg'

conn = PG.connect(
  host:     'localhost',
  port:     5432,
  dbname:   'user',
  user:     'user',
  password: 'pass'
)

# create table

conn.exec('CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)')

# insert data

conn.exec("INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')")

# select data

result = conn.exec('SELECT id, name FROM test')
result.each do |row|
  puts "#{row['id']}: #{row['name']}"
end

# delete data

conn.exec('DELETE FROM test')

# drop table

conn.exec('DROP TABLE test')

# close

conn.close
