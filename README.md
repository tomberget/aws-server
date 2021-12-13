# AWS-Server

Create one or more AWS EC2 spot price instance.

- Choose whether or not to include an additional volume (EBS)
- Use your own *SSH key*
- Update your *Route53 Hosted zone* with the *EC2* instances created
- Expose ports `22`, `80` and `25565` (Minecraft) for ingress traffic
- Enable all egress traffic

## Prerequisites

- A *S3* bucket and *DynamoDB* for **Terraform state**
- A pre-made *SSH key*
- *Hosted Zone ID*
- An idea about *price*, *AMI*, *instance type* and *spot price* you are willing to pay

## Variables that need to be defined

These variables can either be defined as environmental variables, or added to a `.tfvars` file:

- `ec2_instance_settings`, please have a look at [./variables.tf](./variables.tf) for what is necessary
- `public_key`, namely the `key_name` and `public_key` information
- `zone_id` which is your *Hosted Zone ID* from *Route53*

> Note! You may need to also change `region` and/or `availability_zone`, depending on your preference and geographic location.

## How to use Terraform

### Initate Terraform using Terraform Init

```bash
terraform init -reconfigure -backend-config="dynamodb_table=${TERRAFORM_STATE_DYNAMODB_TABLE}" -backend-config="bucket=${TERRAFORM_STATE_AWS_BUCKET}"
```

### See what you are planning to create

```bash
terraform plan -var-file filename.tfvars
```

### Apply your approved plan

```bash
terraform apply -var-file filename.tfvars
```

> Omit the `-var-file filename.tfvars` part if everything is defined using environmental variables.

## Finally

Play some **Minecraft**, or have some other fun :)
