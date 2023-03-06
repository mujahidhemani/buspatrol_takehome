# Run the container locally
1. Build the container image: `docker build -t buspatrol/takehome .`
2. Run the container, substituting <bucket-name> for the bucket name you want to create: `docker run --rm -it -v ~/.aws/:/root/.aws buspatrol/takehome:latest <bucket-name>`