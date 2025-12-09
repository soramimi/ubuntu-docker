#!/bin/bash
service postgresql start
sudo -u postgres psql -c "ALTER ROLE postgres WITH password '${PG_POSTGRES_PASS}';"
sudo -u postgres createuser -d -r -s ${PG_USER_NAME} && sudo -u postgres psql -c "ALTER USER \"${PG_USER_NAME}\" with encrypted password '${PG_USER_PASS}';"
