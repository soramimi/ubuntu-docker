
#JDBC_JAR := /usr/share/java/postgresql.jar
JDBC_JAR := /usr/share/java/postgresql-jdbc/postgresql.jar

.PHONY: all run clean install

all:
	javac -cp $(JDBC_JAR) Main.java

run: all
	java -cp .:$(JDBC_JAR) Main

clean:
	-rm -f *.class

install:
	sudo apt install -y default-jdk libpostgresql-jdbc-java

findjdbc:
	find /usr -name postgresql.jar
