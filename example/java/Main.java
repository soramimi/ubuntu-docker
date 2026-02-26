import java.sql.*;

public class Main {

    static String connectionUrl() {
        String host = "localhost";
        String database = "user";
        String uid = "user";
        String pwd = "pass";
        return "jdbc:postgresql://" + host + "/" + database + "?user=" + uid + "&password=" + pwd;
    }

    public static void main(String[] args) throws Exception {
        try (Connection conn = DriverManager.getConnection(connectionUrl())) {

            // create table

            try (Statement stmt = conn.createStatement()) {
                stmt.execute("CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, name TEXT)");
            }

            // insert data

            try (Statement stmt = conn.createStatement()) {
                stmt.execute("INSERT INTO test (name) VALUES ('Alice'), ('Bob'), ('Charlie')");
            }

            // select data

            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, name FROM test")) {
                while (rs.next()) {
                    System.out.println(rs.getInt("id") + ": " + rs.getString("name"));
                }
            }

            // delete data

            try (Statement stmt = conn.createStatement()) {
                stmt.execute("DELETE FROM test");
            }

            // drop table

            try (Statement stmt = conn.createStatement()) {
                stmt.execute("DROP TABLE test");
            }
        }
    }
}
