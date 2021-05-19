awslocal lambda delete-function --function-name lambda

# awslocal lambda create-function \
#   --function-name lambda \
#   --runtime python3.6 \
#   --region us-east-1 \
#   --zip-file fileb://lambda.zip \
#   --handler lambda.lambda_handler \
#   --role arn:aws:iam::0000000:role/lambda \
#   --environment "Variables={AWS_CA_BUNDLE=/var/task/myCA.pem}"



awslocal lambda create-function \
  --function-name lambda \
  --runtime python3.6 \
  --region us-east-1 \
  --code S3Bucket="__local__",S3Key="/home/christina/work/localstack-reverse-proxy/lambda/dist" \
  --handler lambda.lambda_handler \
  --role arn:aws:iam::0000000:role/lambda \
  --environment "Variables={AWS_CA_BUNDLE=/var/task/myCA.pem}"

