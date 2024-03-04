# Steps to execute

## Create ssh key 
1. Navigate to the `invo/terraform` folder.
2. Generate an SSH key pair using the following command:

`ssh-keygen -t rsa -b 2048 -f example_key`

This will create a private key (`example_key`) and a corresponding public key (`example_key.pub`) in the `terraform` folder.

## Terraform steps 

1. Update your AWS access and secret keys in the `provider.tf` file located in the `invo/terraform` directory:
```hcl
access_key = "ACCESS_KEY"
secret_key = "SECRET_KEY"
```
Navigate to directory `invo/terraform`

```
terraform init
terraform plan -out plan.tfout
terraform apply
```

The existing terraform plan output can be found in `invo/terraform/output/plan.tfout`

# Script to prepare environment ( it runs along with Terraform )

File: `../ShadowTracker.sh` 
