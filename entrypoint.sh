#!/usr/bin/env bash
set -e

# Exit if not run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo."
  echo "Usage: sudo $0"
  exit 1
fi

echo "Running with proper privileges..."

# Wait for MariaDB
echo "Waiting for MariaDB at $DB_HOST..."
until nc -z -v -w30 "$DB_HOST" 3306
do
  echo "Waiting for database connection..."
  sleep 5
done
echo "Database is up!"

# Download SuiteCRM if not present
if [ ! -f /var/www/html/composer.json ]; then
  echo "No SuiteCRM found. Downloading..."
  cd /var/www/html
  curl -Ls https://suitecrm.com/download/165/suite88/565090/suitecrm-8-8-0.zip -o suitecrm.zip
  unzip -q suitecrm.zip
  mv suitecrm-8.8.0/* ./
  mv suitecrm-8.8.0/.* ./ 2>/dev/null || true
  rm -rf suitecrm-8.8.0 suitecrm.zip
  
  # Ensure custom Smarty file is preserved after download
  if [ -f /root/suitecrm/smarty/Sugar_Smarty.php ]; then
    echo "Copying custom Smarty file..."
    cp /root/suitecrm/smarty/Sugar_Smarty.php /var/www/html/public/legacy/include/Sugar_Smarty.php
  fi
fi

# Set initial file permissions
echo "Setting initial permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chmod +x /var/www/html/bin/console

# Make sure the Apache config files are correctly in place
echo "Ensuring Apache configuration files are in place..."
if [ -f /root/suitecrm/apache/000-default.conf ]; then
  cp /root/suitecrm/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
  cp /root/suitecrm/apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
fi

# Run CLI install if not installed
if [ ! -f /var/www/html/public/legacy/config.php ]; then
  echo "Running CLI install..."
  cd /var/www/html
  php bin/console suitecrm:app:install \
    -u "${SUITECRM_ADMIN_USER:-admin}" \
    -p "${SUITECRM_ADMIN_PASSWORD:-admin}" \
    -U "$DB_USER" \
    -P "$DB_PASS" \
    -H "$DB_HOST" \
    -N "$DB_NAME" \
    -S "${SUITECRM_SITE_URL:-http://localhost}" \
    -d "no"
fi

# After installation, ensure custom Smarty file is in place
if [ -f /root/suitecrm/smarty/Sugar_Smarty.php ]; then
  echo "Ensuring custom Smarty file is in place after installation..."
  cp /root/suitecrm/smarty/Sugar_Smarty.php /var/www/html/public/legacy/include/Sugar_Smarty.php
fi

# Reset permissions after installation
echo "Setting final permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chmod +x /var/www/html/bin/console

# Generate or verify OAuth2 keys
mkdir -p /var/www/html/public/legacy/Api/V8/OAuth2
cd /var/www/html/public/legacy/Api/V8/OAuth2

if [ ! -f private.key ]; then
  echo "Generating OAuth2 private/public keys..."
  openssl genrsa -out private.key 2048
  openssl rsa -in private.key -pubout -out public.key
fi

# Always set proper permissions for OAuth keys
echo "Setting OAuth key permissions..."
chmod 600 private.key public.key
chown www-data:www-data private.key public.key

# Ensure proper permissions for OAuth CryptKey class
echo "Setting permissions for OAuth CryptKey class..."
if [ -f /var/www/html/vendor/league/oauth2-server/src/CryptKey.php ]; then
  chmod 644 /var/www/html/vendor/league/oauth2-server/src/CryptKey.php
  chown www-data:www-data /var/www/html/vendor/league/oauth2-server/src/CryptKey.php
fi

# Double check legacy config for site_url
if [ -f /var/www/html/public/legacy/config.php ]; then
  echo "Verifying legacy config..."
  SITE_URL=${SUITECRM_SITE_URL:-http://localhost}
  # Check if we need to append /public
  if [[ ! $SITE_URL == */public ]]; then
    SITE_URL="${SITE_URL}/public"
    echo "Updating legacy site_url to ${SITE_URL}"
  fi
fi

# Make sure .htaccess in legacy has correct RewriteBase
if [ -f /var/www/html/public/legacy/.htaccess ]; then
  echo "Updating legacy .htaccess RewriteBase..."
  # If site_url contains a path, extract it for RewriteBase
  SITE_PATH=$(echo "$SITE_URL" | awk -F/ '{print $4}')
  if [ -n "$SITE_PATH" ]; then
    REWRITE_BASE="/${SITE_PATH}/legacy"
  else
    REWRITE_BASE="/legacy"
  fi
  sed -i "s|RewriteBase .*|RewriteBase ${REWRITE_BASE}|g" /var/www/html/public/legacy/.htaccess
fi

echo "Entrypoint finished. Starting Apache..."
exec "$@"