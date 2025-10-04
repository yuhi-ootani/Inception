#!/usr/bin/env bash
# Wherever Bash is in, it sill finds it.

# Exit immediately on error (-e), unset variable (-u), or pipe failure (-o pipefail).
set -euo pipefail


# Required env (from .env)
: "${MARIADB_ROOT_PASSWORD:?}"
: "${MARIADB_DATABASE:?}"
: "${MARIADB_USER:?}"
: "${MARIADB_PASSWORD:?}"


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


if [ ! -f "/tmp/init.sql" ]; then

  cat >/tmp/init.sql << EOF
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

chown mysql:mysql /tmp/init.sql
chmod 600 /tmp/init.sql

# mysqld → starts the MariaDB server and stays in the foreground
# --skip-name-resolve tells MariaDB not to do any DNS lookups for client hostnames.
# --init-file: “On startup, before accepting any client connections, read this file and execute the SQL in it.
exec mysqld --user=mysql --datadir=/var/lib/mysql  --skip-name-resolve --init-file=/tmp/init.sql
  
fi



# replaced by CMD in the dockerfile
exec "$@"