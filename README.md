# Run the container locally
1. Build the container image: `docker build -t buspatrol/takehome .`
2. Run the container, substituting bucket-name for the bucket name you want to create: `docker run --rm -it -v ~/.aws/:/root/.aws buspatrol/takehome:latest <bucket-name>`

# Run on ECS
1. Deploy the terraform code: `terraform apply`
1. Login to ECS console.
1. Click on the task definiions
1. Select the `buspatrol` task definition and click Deploy > Run Task
1. Running the ECS Task: 
  1. Under Environment, choose Existing cluster and select the `buspatrol` cluster
  1. Under Networking, select the `buspatrol-vpc`
  1. Under Command override, replace `test123` with desired bucket name
  1. Click create to run the task
1. Under tasks, click the newly created task, from there you can click the logs tab to monitor the progress
