PG_POSTGRES_PASS=qwerty123
PG_USER_NAME=user
PG_USER_PASS=pass

main: restart

restart: stop start

stop:
	-service postgresql stop

start:
	cp postgresql.conf /etc/postgresql/16/main/
	cp pg_hba.conf /etc/postgresql/16/main/
	chown postgres:postgres /etc/postgresql/16/main/*
	service postgresql start
	
init: stop dropcluster createcluster start alterrole createuser createdb

dropcluster:
	/usr/bin/pg_dropcluster 16 main

createcluster:
	/usr/bin/pg_createcluster 16 main

alterrole:
	sudo -u postgres psql -c "ALTER ROLE postgres WITH password '${PG_POSTGRES_PASS}';"

createuser:
	sudo -u postgres createuser -d -r -s ${PG_USER_NAME} && sudo -u postgres psql -c "ALTER USER \"${PG_USER_NAME}\" with encrypted password '${PG_USER_PASS}';"

createdb:
	sudo -u postgres psql -c "create database \"user\" owner \"user\";"

backup:
	pg_basebackup -h 127.0.0.1 -p 5432 -U postgres -D /tmp/pgbackup

restore: stop _restore start

_restore:
	-rm -fr /var/lib/postgresql/16/main.old
	-mv /var/lib/postgresql/16/main /var/lib/postgresql/16/main.old
	cp -a /tmp/pgbackup /var/lib/postgresql/16/main
	chown -R postgres. /var/lib/postgresql/16/main

