# Run the container locally
1. Build the container image: `docker build -t buspatrol/takehome .`
2. Run the container, substituting <bucket-name> for the bucket name you want to create: `docker run --rm -it -v ~/.aws/:/root/.aws buspatrol/takehome:latest <bucket-name>`

# Run on ECS
1. Deploy the terraform code: `terraform apply`
2. Login to ECS console.
3. Click on the task definiions
4. Select the `buspatrol` task definition and click Deploy > Run Task
5. 
  a. Under Environment, choose Existing cluster and select the `buspatrol` cluster
  b. Under Networking, select the `buspatrol-vpc`
  c. Under Command override, replace `test123` with desired bucket name
  d. Click create to run the task
6. Under tasks, click the newly created task, from there you can click the logs tab to monitor the progress
