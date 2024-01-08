# Mura App
This is created as a project for the Introduction to Cloud Computing course in BTH by utilizing various services offered by AWS, as well as the automation capabilities of Terraform, and the cluster orchestration capabilities provided by Kubernetes.
<br> <br>
## Steps for setting up the stack:
### Setting up the VPC, database and memcached
1. Generate a login stack key using the `ssh-keygen` command. Name the key "stack-key"
2. Change directory into the terraform directory and run `terraform init`. Don't forget to change the s3 bucket name in "terraform.tf" because that bucket won't exist soon!
3. Change "myip" in "variables.tf" to your own IP address as a CIDR block
4. Run `terraform plan` to check the terraform configuration and after confirming, run `terraform apply` to host the stack
### Host the application on Kubernetes cluster
1. Run `kops create cluster --name=your-cluster-name --state=s3://your-s3-bucket --zones=us-east-1a --node-count=2 --node-size=t3.small --control-plane-size=t3.medium --dns-zone=your-dns-hosted-zone --node-volume-size=8 --control-plane-volume-size=8` to create cluster configuration
2. Run `kops update cluster --name=your-cluster-name --yes --state=s3://your-s3-bucket` to perform cluster creation
3. Validate the cluster creation by `kops validate cluster --state=s3://your-s3-bucket`
4. Create VPC Peering connection between the terraform VPC and the cluster VPC
5. Adjust the route tables accordingly depending on the subnet CIDR blocks, as well as the security group rules for the MySQL and the Memcache instances to allow traffic from the worker nodes
6. Run git clone "https://github.com/Sonntd271/mura-app.git", change the IP addresses of MySQL and Memcache to yours
7. Create and push Docker image of the app to Docker Hub
8. Change directory to helm and run `helm install name-of-the-release .` to deploy the app to the kubernetes cluster 
