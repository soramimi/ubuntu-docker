import odbc from 'odbc';

function connectionString(): string {
	const driver = 'PostgreSQL Unicode';
	const server = 'localhost';
	const database = 'user';
	const uid = 'user';
	const pwd = 'pass';
	return `DRIVER={${driver}};SERVER=${server};DATABASE=${database};UID=${uid};PWD=${pwd};`;
}

async function main(): Promise<void> {
	const conn = await odbc.connect(connectionString());

	// create table

	await conn.query('CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)');

	// insert data

	await conn.query("INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')");

	// select data

	interface Record {
		id: number;
		name: string;
	}

	const records = await conn.query<Record>('SELECT id, name FROM test');
	for (const row of records) {
		console.log(`${row.id}: ${row.name}`);
	}

	// delete data

	await conn.query('DELETE FROM test');

	// drop table

	await conn.query('DROP TABLE test');

	// close

	await conn.close();
}

main().catch((err) => {
	console.error(err);
	process.exit(1);
});
