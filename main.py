import boto3
import botocore
import sys

# check a paramater was passed, throw error and exit if missing
try:
    bucket_name = sys.argv[1]
except:
    print ("missing bucket name parameter")
    sys.exit(1)

client = boto3.client('s3')

# create bucket, throw error if bucket creation fails
try: 
    resp = client.create_bucket(
        Bucket = bucket_name
    )
except botocore.exceptions.ClientError as error:
    print (error.response['Error']['Message'])
    sys.exit(1) 
else:
    print("S3 bucket:", bucket_name, "created!")