import boto3
import os


def lambda_handler(event, context):
    print(vars(context))
    print(os.getcwd())

    print(context.aws_request_id)
    print('connect to s3:')
    print(boto3.client('s3').list_buckets())
    print('s3 ok')

    aws_identity = boto3.client('sts').get_caller_identity()
    print(aws_identity)

    print('connect to dynamodb')
    print(boto3.client('dynamodb').list_tables())
    print('dynamodb ok')

    print('connect to stepfunctions')
    print(boto3.client('stepfunctions').list_activities())
    print('stepfunctions ok')

    return {"all_good": "yes"}
