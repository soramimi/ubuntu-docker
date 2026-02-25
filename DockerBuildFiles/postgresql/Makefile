PG_POSTGRES_PASS=qwerty123
PG_USER_NAME=user
PG_USER_PASS=pass

main: 
	
init: stop dropcluster createcluster start alterrole createuser createdb

stop:
	-service postgresql stop

dropcluster:
	/usr/bin/pg_dropcluster 16 main

createcluster:
	/usr/bin/pg_createcluster 16 main

start:
	cp postgresql.conf /etc/postgresql/16/main/
	cp pg_hba.conf /etc/postgresql/16/main/
	chown postgres:postgres /etc/postgresql/16/main/*
	service postgresql start

alterrole:
	sudo -u postgres psql -c "ALTER ROLE postgres WITH password '${PG_POSTGRES_PASS}';"

createuser:
	sudo -u postgres createuser -d -r -s ${PG_USER_NAME} && sudo -u postgres psql -c "ALTER USER \"${PG_USER_NAME}\" with encrypted password '${PG_USER_PASS}';"

createdb:
	sudo -u postgres psql -c "create database \"user\" owner \"user\";"


