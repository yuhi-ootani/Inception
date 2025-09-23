#!/usr/bin/env bash
# Wherever Bash is in, it sill finds it.

# Exit immediately on error (-e), unset variable (-u), or pipe failure (-o pipefail).
set -euo pipefail


# Required env (from .env)
: "${MARIADB_ROOT_PASSWORD:?}"
: "${MARIADB_DATABASE:?}"
: "${MARIADB_USER:?}"
: "${MARIADB_PASSWORD:?}"

SOCK=/run/mysqld/mysqld.sock

# this directory on a Linux system where the MySQL server creates its socket file
mkdir -p /run/mysqld

# make mysql own the directory to create file freely.
# You will login as mysql user (minimum privilege)
chown -R mysql:mysql /run/mysqld
# /var/lib/mysql

# if there is not the wordpress database, initilize the mariadb
# the host volume is empty at the begginng
if [ ! -d "/var/lib/mysql/mysql" ]; then

# mariadb-install-db → initializes the MariaDB data directory by creating the system tables.
# --user=mysql → ensure all files are owned by the mysql user so the server can access them.
# --datadir=/var/lib/mysql → specify where to create the system tables (the MariaDB data directory).
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql 

fi


if [ ! -f "/run/init.sql" ]; then

  cat >/run/init.sql << EOF
-- set the root password using a value from an environment variable.
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';

-- This creates the database if missing; utf8mb4 handles emojis/multi-language.
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- create the user used by WordPress to modify the WordPress database
-- Use backticks (\`) for identifiers (db/table names) and single quotes (') for string values like passwords.
-- The wildcard host '%' allows your WordPress container to connect from any IP address.
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';

-- Give the user all privileges on \`${MARIADB_DATABASE}\`.
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

chmod 777 /run/init.sql
  
fi

# mysqld → starts the MariaDB server and stays in the foreground
# --skip-name-resolve tells MariaDB not to do any DNS lookups for client hostnames.
# --init-file: “On startup, before accepting any client connections, read this file and execute the SQL in it.
exec mysqld --user=mysql --datadir=/var/lib/mysql  --skip-name-resolve --init-file=/run/init.sql

# mysqld : execute mariadb server
# --user=mysql: login as mysql user
# --skip-networking: allow only a socket connect
# &: run in backround
# mysqld --user=mysql --skip-networking --socket="$SOCK" &

# Wait up to 60 seconds for the database server to be ready.
# for i in $(seq 1 60); do
#   # mariadb: This is the MariaDB client program.
#   # --protocol=SOCKET:  It forces it to use a local socket file (--socket=/run/mysqld/mysqld.sock) 
#   # -e 'SELECT 1;': execute universal query used to confirm a live and responsive database connection 
#   # >/dev/null 2>&1;: his silences all output by redirecting both standard output (stdout) and standard error (stderr) to /dev/null.
#   if mariadb --protocol=SOCKET --socket="$SOCK" -uroot -e 'SELECT 1' >/dev/null 2>&1 || \
#      mariadb --protocol=SOCKET --socket="$SOCK" -uroot -p"$MARIADB_ROOT_PASSWORD" -e 'SELECT 1' >/dev/null 2>&1; then
#     echo "Database is ready."
#     break 
#   else
#     echo "Attempt $i: MariaDB is not ready yet..."
#   fi
#   sleep 1
# done

# # Check if the loop completed without a successful  (-eq == equal)
# if [ $i -eq 60 ]; then
#     echo "Error: Could not start MariaDB after 60 seconds."
#     exit 1
# fi





# Try socket without password first; if root already has a password, fall back.
# mariadb --protocol=SOCKET --socket="$SOCK" -uroot -e "$SQL" 2>/dev/null || \
# mariadb --protocol=SOCKET --socket="$SOCK" -uroot -p"$MARIADB_ROOT_PASSWORD" -e "$SQL"

# 4) Stop the temp server
# mysqladmin --protocol=SOCKET --socket="$SOCK" -uroot shutdown >/dev/null 2>&1 || \
# mysqladmin --protocol=SOCKET --socket="$SOCK" -uroot -p"$MARIADB_ROOT_PASSWORD" shutdown


# mysqladmin → the administrative client. after finishing initialization shutdown the mariadb
# mysqladmin --protocol=SOCKET --socket="$SOCK" -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown


# replaced by CMD in the dockerfile
exec "$@"