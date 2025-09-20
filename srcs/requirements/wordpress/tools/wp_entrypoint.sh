#!/usr/bin/env bash


# Exit immediately on error (-e), unset variable (-u), or pipe failure (-o pipefail).
set -euo pipefail

: "${WORDPRESS_DB_HOST:?}"
: "${WORDPRESS_DB_NAME:?}"
: "${WORDPRESS_DB_USER:?}"
: "${WORDPRESS_DB_PASSWORD:?}"

: "${WP_PATH:?}"
: "${WP_URL:?}"
: "${WP_TITLE:?}"
: "${WP_ADMIN_USER:?}"
: "${WP_ADMIN_PASSWORD:?}"
: "${WP_ADMIN_EMAIL:?}"

: "${WP_EDITOR_USER:?}"
: "${WP_EDITOR_PASSWORD:?}"
: "${WP_EDITOR_EMAIL:?}"



echo "Waiting for MariaDB at ${WORDPRESS_DB_HOST}..."
# extract longest matching pattern(:*) from the end = the hostname 
host="${WORDPRESS_DB_HOST%%:*}"
# extract longest matching pattern(*:) from the start = the port 
port="${WORDPRESS_DB_HOST##*:}"
# if there is not port, asssign default mariadb port
if [ "$host" = "$port" ]; then port=3306; fi

for i in $(seq 1 60); do
    # The mariadb client is a short-lived process.
    # -e"SELECT 1" "$WORDPRESS_DB_NAME": runs a quick SQL query SELECT 1 on the specified database to check if the database server is running and can process requests.
    if mariadb -h"$host" -P"$port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e"SELECT 1" "$WORDPRESS_DB_NAME" > /dev/null 2>&1; then
        echo "Mariadb is ready."
        break
    else
        echo "Attempt $i: MariaDB is not ready yet..."
    fi
    sleep 1
done

# Check if the loop completed without a successful connection
if [ $i -eq 60 ]; then
    echo "Error: Could not connect to MariaDB after 60 seconds."
    exit 1
fi

# wp-config.php is a crucial file in a WordPress installation that contains core configuration settings for the website
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress core..."
    # WP-CLI command downloads the official WordPress core files (PHP, JS, CSS, etc.)
    wp core download --path="$WP_PATH" --allow-root

    # https://i0.wp.com/learn.wordpress.org/files/2020/11/install-step3_v47.png?ssl=1
    echo "Creating wp-config.php..."
    wp config create \
        --path="$WP_PATH" \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root


    echo "Running wp core install..."

    # wp core install configures a downloaded WordPress installation by connecting it to a database and creating the initial site settings and admin user. 
    # https://codex.wordpress.org/images/1/1b/install-step5.png
    #--skip-email: skip sending email notification
    wp core install \
        --path="$WP_PATH" \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root


    # https://wordpress.org/support/files/2019/01/add-user.png
    # wp user create does not have --skip-email (default is off)
    wp user create \
        --path="$WP_PATH" \
        "$WP_EDITOR_USER" "$WP_EDITOR_EMAIL" \
        --role=editor \
        --user_pass="$WP_EDITOR_PASSWORD" \
        --allow-root \


    # nginx and php-fpm use this directory as www-data user
    chown -R www-data:www-data "$WP_PATH"
    echo "WordPress installed."
else
  echo "Existing WordPress detected. Skipping install."
fi
    

# Hand off to the main process (e.g., php-fpm)
exec "$@"