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
1. TBA ;)
