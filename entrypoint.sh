#!/usr/bin/env bash
set -e

# Exit if not run as root
sudo -i
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo."
  echo "Usage: sudo $0"
  exit 1
fi

echo "Running with proper privileges..."


# 1) Wait for MariaDB
echo "Waiting for MariaDB at $DB_HOST..."
until nc -z -v -w30 "$DB_HOST" 3306
do
  echo "Waiting for database connection..."
  sleep 5
done
echo "Database is up!"

# 2) If SuiteCRM not present, copy or download
if [ ! -f /var/www/html/public/legacy/composer.json ]; then
  echo "No SuiteCRM found. Downloading..."
  cd /var/www/html
  # Example: download 8.8.0
  curl -Ls https://suitecrm.com/download/165/suite88/565090/suitecrm-8-8-0.zip -o suitecrm.zip
  unzip suitecrm.zip
  # The zip may have a subfolder inside it. Adjust your paths accordingly.
  mv suitecrm-8.8.0/* ./
  mv suitecrm-8.8.0/.* ./ || true
  rm -rf suitecrm-8.8.0 suitecrm.zip
fi

# 3) Run composer (if needed)
if [ -f /var/www/html/composer.json ]; then
  echo "Installing backend dependencies..."
  composer install --no-interaction --ignore-platform-reqs
fi

# 4) If not installed, install via CLI
if [ ! -f /var/www/html/public/legacy/config.php ]; then
  echo "Running CLI install..."
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

# 5) Set file permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 2755 {} \;
find /var/www/html -type f -exec chmod 0644 {} \;
chmod +x /var/www/html/bin/console

# 6) Generate or verify OAuth2 keys
mkdir -p /var/www/html/public/legacy/Api/V8/OAuth2
cd /var/www/html/public/legacy/Api/V8/OAuth2

if [ ! -f private.key ]; then
  echo "Generating OAuth2 private/public keys..."
  openssl genrsa -out private.key 2048
  openssl rsa -in private.key -pubout -out public.key
  chmod 600 private.key public.key
  chown www-data:www-data private.key public.key
fi

echo "Entrypoint finished. Starting Apache..."
exec "$@"
