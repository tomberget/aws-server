variable "region" {
  description = "Default region to use"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "Default availability zone to use"
  type        = string
  default     = "b"
}

variable "public_key" {
  description = "Public key for connecting to AWS EC2 instance"
  type        = map(string)
  default = {
    "key_name" = "",
  }
}

variable "ec2_instance_settings" {
  description = "EC2 instance settings"
  type        = map(map(string))
  default = {
    "default" = {
      "enabled"       = false,
      "ami"           = "ami-0a8e758f5e873d1c1",
      "instance_type" = "t3.medium",
      "spot_price"    = "0.02",
      "hostnum"       = "100",
      "ebs_volume"    = false,
    },
  }
}

variable "zone_id" {
  description = "Route53 hosted zone id"
  type = string
}
