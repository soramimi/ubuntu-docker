

#include <sql.h>
#include <sqlext.h>
#include <string>
#include <cassert>
#include <cstdint>
#include <vector>

void show_error(SQLHENV henv, SQLHDBC hdbc, SQLHSTMT hstmt)
{
	SQLCHAR message[1000];
	SQLCHAR sqlstate[SQL_SQLSTATE_SIZE + 1];
	SQLINTEGER sqlcode;
	SQLSMALLINT length;
	SQLError(henv, hdbc, hstmt, sqlstate, &sqlcode, message, sizeof(message), &length);
	fprintf(stderr, "%s %s\n"
			, (char const *)sqlstate
			, (char const *)message);
}

std::string connection_string()
{
	std::string driver = "PostgreSQL Unicode";
	std::string server = "localhost";
	std::string database = "user";
	std::string uid = "user";
	std::string pwd = "pass";
	std::string connstr = "DRIVER={" + driver + "};SERVER=" + server + ";DATABASE=" + database + ";UID=" + uid + ";PWD=" + pwd + ";";
	return connstr;
}


int main()
{
	HENV henv = nullptr;
	HDBC hdbc = nullptr;
	SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
	SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);

	SQLRETURN ret;
	SQLSMALLINT outstrlen;

	ret = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(henv, nullptr, nullptr);
		return 1;
	}
	SQLCHAR outstr[1024];
	std::string connstr = connection_string();
	ret = SQLDriverConnect(hdbc, NULL, (SQLCHAR *)connstr.c_str(), SQL_NTS, outstr, sizeof(outstr), &outstrlen, SQL_DRIVER_COMPLETE);
	if (!SQL_SUCCEEDED(ret) || !hdbc) {
		show_error(nullptr, hdbc, nullptr);
		return 1;
	}

	// create table

	SQLHSTMT hstmt = nullptr;
	ret = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
	if (!SQL_SUCCEEDED(ret) || !hstmt) {
		show_error(nullptr, hdbc, nullptr);
		return 1;
	}
	ret = SQLExecDirect(hstmt, (SQLCHAR *)"CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)", SQL_NTS);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(nullptr, hdbc, hstmt);
		return 1;
	}

	// insert data

	ret = SQLExecDirect(hstmt, (SQLCHAR *)"INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')", SQL_NTS);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(nullptr, hdbc, hstmt);
		return 1;
	}

	// select data

	struct Record {
		uint32_t id;
		std::string name;
	};
	std::vector<Record> records;

	ret = SQLExecDirect(hstmt, (SQLCHAR *)"SELECT id, name FROM test", SQL_NTS);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(nullptr, hdbc, hstmt);
		return 1;
	}
	SQLINTEGER id;
	char name[256];
	SQLLEN id_ind, name_ind;
	SQLBindCol(hstmt, 1, SQL_C_SLONG, &id, sizeof(id), &id_ind);
	SQLBindCol(hstmt, 2, SQL_C_CHAR, name, sizeof(name), &name_ind);
	while (SQLFetch(hstmt) == SQL_SUCCESS) {
		Record rec;
		rec.id = id;
		rec.name = std::string(name, name_ind);
		records.push_back(rec);
	}

	for (Record const &rec : records) {
		printf("%u: %s\n", rec.id, rec.name.c_str());
	}

	// close cursor

	SQLFreeStmt(hstmt, SQL_CLOSE);

	// delete data

	ret = SQLExecDirect(hstmt, (SQLCHAR *)"DELETE FROM test", SQL_NTS);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(nullptr, hdbc, hstmt);
		return 1;
	}

	// drop table

	ret = SQLExecDirect(hstmt, (SQLCHAR *)"DROP TABLE test", SQL_NTS);
	if (!SQL_SUCCEEDED(ret)) {
		show_error(nullptr, hdbc, hstmt);
		return 1;
	}

	// close

	SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
	SQLDisconnect(hdbc);
	SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
	SQLFreeHandle(SQL_HANDLE_ENV, henv);

	return 0;
}
