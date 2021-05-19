awslocal s3api create-bucket \
  --bucket mybucket \
  --region us-east-1

awslocal s3api put-bucket-versioning \
    --bucket mybucket \
    --versioning-configuration Status=Enabled

 # ./package.sh
./create.sh
./invoke.sh

cat out.txt