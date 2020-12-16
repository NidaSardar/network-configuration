# Basic  Network configuration with terraform.

The script is able to configure basic network settings which includes:

- Public subnets,
- Private subnets,
- Public Route table for public subnets allowing internet access,
- Private route table for private subnets allowing access through NAT.

## Package files.

a- main.tf : contains actual resource creation script.

b- variables.tf : contaions variable declaration.

c- variables.tfvars: contains values for variables.

## Steps to Deploy.

1. Modify the variables.tfvars according to your values.

2. Run: 
    
     terraform init

     terraform apply -var-file="variables.tfvars"

3. It will configure the basic network settings in your account. 