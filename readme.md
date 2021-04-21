# What does this do

This project tries to work around the fact that `boto3` doesn't provide an environment variable to override the Amazon AWS enpoint URLs it uses. E.g. `boto3.client('sts')` makes a call to `https:\\sts.amazonaws.com`. When using `localstack` this endpoint needs to be `http:\\$LOCALSTACK_HOSTNAME:4566` (where LOCALSTACK_HOSTNAME is an environment variable defined by localstack). What one needs to do is replace all of the calls to `boto3.client('my_service')` with 

`boto3.client('my_service', endpoint_url=f"http://{os.getenv('LOCALSTACK_HOSTNAME')}" if os.getenv('LOCALSTACK_HOSTNAME') else None)`

This might not be desirable or might be quite time consuming in large codebases as each call would need to be changed. 


This project provides a workaround to avoid making any code changes. Using docker-compose, a nginx reverse proxy container is launched alongside the localstack container, on a dedicated network, and it intercepts all calls to Amazon endpoints and redirects them to localstack:4566. Therefore no code changes are required in the lambdas, as the intercepts and redirects are all handled in the network. 


  # How does it work 

We have 2 Docker containers on a dedicated network, localstack, and nginx. nginx is aliased with the Amazon AWS endpoints that we need, e.g. `sts.amazonaws.com`, `s3.amazonaws.com`, `dynamodb.us-east-1.amazonaws.com`, etc. Additionally, any lambda containers are launched on the same network as the 2 ones mentioned before. This is not done by default, and has to be explicitly configured in the compose file (see `LAMBDA_DOCKER_NETWORK=localstackreverseproxy_lntk`). Any calls to the afore mentioned endpoints are then redicted by the network to the nginx container, which proxies them to localstack (see the `nginx/conf.d/default.conf` file to see how this is done). 

boto3 uses `https` endpoints so we need to provide valid certificates signed with our own certificate authority. These are configured in nginx, and the root certificate must be trusted on the lambda container such that the SSL verify process works. 

The afore mentioned certificates are not provided in this repo but there is a script that generates all of them. Please see the next section for instructions. 

# How to use this 

Tested on Ubuntu 18.04. 

## First run 
Start with a terminal in the root directory of this project. 

1) Generate the required certificates using the commands below. These create and sign certificates where we are own certificate authority.  

```
chmod +x gen_certs.sh
./gen_certs.sh
```

You will need to enter a passphrase every time you are prompted for it. You will be asked several time for other fields as well, press enter for all but the Common Name (FQDN) field, which you must set to `*.amazonaws.com`. If everything went well, you will end up with 8 files in the `nginx/conf.d/ssl` subfolder. Make note of the `myCA.pem`, as this is the certificate that must be trusted on each client making calls to the AWS endpoints. 

2) Check that all of the volumes specified in the `docker-compose.yml` file match your own configuration. 

3) Place the `myCA.pem` in the root of your lambda distribution package, and create the lambda with this environment variable: AWS_CA_BUNDLE=/var/task/myCA.pem. This tells `boto3` to use our root certificate for the SSL verification. If you are using the AWS CLI, you can pass this parameter to your `awslocal create-function` command: `--environment "Variables={AWS_CA_BUNDLE=/var/task/myCA.pem}"`. `/var/task` is needed as this is were the code is placed on the lambda container. 

4) Use `docker-compose up` to bring everything up. 

## How do I run this? 

If the first run steps were performed, do `docker-compose up`

## How do I add an extra service?

You will need to add a network alias for the `reverse` service in the `docker-compose.yml` file. Keep in mind that the certificate allows the `*.amazonaws.com` and the `*.us-east-1.amazonaws.com` domains only. If your new endpoint doesn't match any of these, you will need to add your new domain to the certificate signing request in the `gen_certs.sh` file (in the `[alt_names]` section). After that repeat steps 1 to 4 in the First run section.

# Troubleshooting

## My lambda container says network `localstackreverseproxy_lntk` does not exist. 

That usually means that the folder where your compose file is isn't called `localstack-reverse-proxy`. By default, docker-compose will create a network which is name as `FolderNameWithoutSpecialChars_MyNetworkNameFromCompose`. Our network is called `ntlk`, but Docker creates is as `localstackreverseproxy_lntk`. You will need to change `localstack_main`'s environment variable, from the compose file, to the value that matches your configuration: `LAMBDA_DOCKER_NETWORK=yourfoldername_lntk` 

## Running the lambda gives me SSL validation failed 

A few things. Make sure that you have included the CA root cert in your lambda, and that the AWS_CA_BUNDLE environment variable is set correctly. Redo step 4. 
Make sure your endpoint has been added as an alias, and also that the certificate signing request has covered your alias. 

## Invalid token when connecting to an AWS service 

This means your endpoint is not configured. You will need to follow the steps from How do I add an extra service.    
























