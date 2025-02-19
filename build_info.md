# ubun-crm
5.75.135.254

update \etc\apache2\sites-available\000-default.conf
<VirtualHost *:80>
    # Change this to the IP or domain if you'd like:
    ServerName 5.75.135.254

    # Point to SuiteCRM 8's public directory:
    DocumentRoot /var/www/html/public

    <Directory "/var/www/html/public">
        # Apache needs to allow .htaccess to function for SuiteCRM rewrites:
        AllowOverride All
        Require all granted
        # Options could be expanded:
        Options FollowSymLinks
    </Directory>

    # Logging
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>



