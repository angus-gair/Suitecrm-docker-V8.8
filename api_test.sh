#=======    create a user
# Access your container
sudo docker exec -it suitecrm_app bash

# Navigate to SuiteCRM directory
cd /var/www/html

# Create a client (example for password client)
php bin/console suitecrm:oauth2:create-client "My API Client" --grant-type=password

# For client credentials client
# php bin/console suitecrm:oauth2:create-client "My API Client" --grant-type=client_credentials --associated-user-id=1
#========


POST /Api/access_token
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "273657c4-8228-bc1b-980f-67b645dafe60",
  "client_secret": "Jamfinnarc1776!"
}