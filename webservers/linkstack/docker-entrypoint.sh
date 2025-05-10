#!/bin/sh
set -eu

# Default values
SERVER_ADMIN="${SERVER_ADMIN:-you@example.com}"
HTTP_SERVER_NAME="${HTTP_SERVER_NAME:-localhost}"
HTTPS_SERVER_NAME="${HTTPS_SERVER_NAME:-localhost}"
LOG_LEVEL="${LOG_LEVEL:-info}"
TZ="${TZ:-UTC}"
PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-256M}"
UPLOAD_MAX_FILESIZE="${UPLOAD_MAX_FILESIZE:-8M}"
DEBUG="${DEBUG:-TRUE}"

# Config override paths (user-writeable)
CONFIG_DIR="/config"
APACHE_CONF="${CONFIG_DIR}/apache2/httpd.conf"
SSL_CONF="${CONFIG_DIR}/apache2/conf.d/ssl.conf"
PHP_CONF="${CONFIG_DIR}/php82/php.ini"

# Optional debug output
debug_copy() {
  file="$1"
  tag="$2"
  if [ "$DEBUG" = "TRUE" ] && [ -d /debug ]; then
    cp "$file" "/debug/${tag}.BEFORE"
  fi
}

debug_done() {
  file="$1"
  tag="$2"
  if [ "$DEBUG" = "TRUE" ] && [ -d /debug ]; then
    cp "$file" "/debug/${tag}.AFTER"
  fi
}

# Apply changes to Apache config
debug_copy "$APACHE_CONF" "httpd"
sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" "$APACHE_CONF"
sed -i "s/#ServerName\ www.example.com:80/ServerName\ ${HTTP_SERVER_NAME}/" "$APACHE_CONF"
sed -i 's#^DocumentRoot ".*#DocumentRoot "/htdocs"#g' "$APACHE_CONF"
sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/htdocs"#g' "$APACHE_CONF"
sed -i 's#AllowOverride None#AllowOverride All#' "$APACHE_CONF"
sed -i "s#^LogLevel .*#LogLevel ${LOG_LEVEL}#g" "$APACHE_CONF"
debug_done "$APACHE_CONF" "httpd"

# Apply changes to SSL config
debug_copy "$SSL_CONF" "ssl"
sed -i 's#^ErrorLog .*#ErrorLog "logs/ssl-error.log"#g' "$SSL_CONF"
sed -i "s/^TransferLog .*/#TransferLog \"logs\/ssl-transfer.log\"\nLogLevel ${LOG_LEVEL}/g" "$SSL_CONF"
sed -i 's#^DocumentRoot ".*#DocumentRoot "/htdocs"#g' "$SSL_CONF"
sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" "$SSL_CONF"
sed -i "s/ServerName\ www.example.com:443/ServerName\ ${HTTPS_SERVER_NAME}/" "$SSL_CONF"
debug_done "$SSL_CONF" "ssl"

# Apply changes to PHP config
debug_copy "$PHP_CONF" "php"
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" "$PHP_CONF"
sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${UPLOAD_MAX_FILESIZE}/" "$PHP_CONF"
sed -i "s#^;date.timezone =\$#date.timezone = \"${TZ}\"#" "$PHP_CONF"
echo "is_llc_docker = true" >> "$PHP_CONF"
debug_done "$PHP_CONF" "php"

# Start Apache with overridden config
exec httpd -f "$APACHE_CONF" -D FOREGROUND
