This project redirects amazon endpoints, hardcoded into libraries such as `boto3`, to `localstack`.


This has implemented as follows: a docker compose file with 2 services. One is localstack, the other is nginx. Calls made to Amazon services are directed to the nginx container, which in turn redirects them to localstack. This allows running lambdas that should connect to Amazon endpoints fully in localstack. 


You will need to generate certificates for nginx and place in the ssl folder. 


Use this command: 

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
```
Then copy then into the ssl folder:
```
cp /etc/ssl/private/nginx-selfsigned.key ./nginx/ssl
cp /etc/ssl/certs/nginx-selfsigned.crt ./nginx/ssl
```

Make sure to put `10.5.0.3` as `Common Name` when prompted. 


To add additional endpoints that need to point back to localstack, please add new entries in the `localstack` service's `extra_hosts` category. Use the same IP address that was used for `sts.amazonaws.com`. That is the `reverse`'s service static IP address. 


Start everything up with `docker-compose up`. Then deploy lambdas into localstack without having to configure endpoints in the code.
