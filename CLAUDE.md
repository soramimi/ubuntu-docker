# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides a Docker environment running Ubuntu 24.04 with PostgreSQL 16, plus a collection of sample programs demonstrating PostgreSQL connectivity from multiple languages. All samples perform the same CRUD workflow: create table → insert → select → delete → drop table.

## Docker Environment

### Build and run the container

```bash
make build        # Build the Docker image
make up           # Start the container (runs as sleep infinity)
make down         # Stop and remove the container
make sh           # Open a shell as the host user
make root         # Open a shell as root
```

The container mounts:
- `./srv` → `/srv`
- `./postgresql` → `/var/lib/postgresql` (persistent DB data)
- `./home` → `/home/<username>`

### PostgreSQL credentials

| Item | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `user` |
| User | `user` |
| Password | `pass` |
| Superuser password | `qwerty123` |

`pg_hba.conf` is configured to allow all connections from any address without authentication (`trust`), so no password is required from within the container.

### ODBC configuration

`etc/odbcinst.ini` defines the `PostgreSQL Unicode` driver (`/usr/lib/psqlodbcw.so`). The `etc/` directory contents should be deployed to `/etc/` inside the container for ODBC examples to work.

## Example Programs

Each language lives under `example/<lang>/` with a consistent `Makefile` interface:

| Target | Meaning |
|---|---|
| `make all` | Build (compiled languages) |
| `make run` | Run the example |
| `make clean` | Remove build artifacts |
| `make install` | Install system/language dependencies |

### Language-specific notes

| Language | Connection method | Key dependency |
|---|---|---|
| **C++** | ODBC (`sql.h`/`sqlext.h`) | `-lodbc`; requires `unixodbc-dev` |
| **C#** | ODBC (`System.Data.Odbc`) | `dotnet-sdk-10.0` |
| **Go** | ODBC (`database/sql` + `github.com/alexbrainman/odbc`) | `unixodbc-dev`; run `make deps` after `make install` |
| **Python** | ODBC (`pyodbc`) | `pip3 install pyodbc` |
| **Ruby** | ODBC (`odbc` gem / `ruby-pg`) | `gem install pg` |
| **Rust** | ODBC (`odbc-api` crate v8) | `unixodbc-dev` |
| **TypeScript** | ODBC (`odbc` npm package v2) | `npm install`; builds to `dist/` via `tsc` |
| **Java** | JDBC (`jdbc:postgresql://`) | `default-jdk libpostgresql-jdbc-java`; JDBC jar at `/usr/share/java/postgresql-jdbc/postgresql.jar` |

## Adding a New Language Example

Follow the existing pattern:
1. Create `example/<lang>/` directory
2. Implement the standard CRUD flow: create table `test(id SERIAL PRIMARY KEY, name TEXT)` → insert Alice/Bob/Charlie → select and print → delete → drop
3. Use ODBC with driver name `PostgreSQL Unicode` (except Java which uses JDBC)
4. Provide a `Makefile` with at minimum `run` and `install` targets
5. Add a `.gitignore` for language-specific build artifacts
