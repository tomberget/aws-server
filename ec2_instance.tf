locals {
  availability_zone = format("%s%s", var.region, var.availability_zone)
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = local.availability_zone

  tags = {
    Name = "aws-subnet"
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = local.availability_zone
  size              = 20
  type              = "gp2"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.public_key["key_name"]
  public_key = var.public_key["public_key"]
}

resource "aws_spot_instance_request" "spot_instance_request" {
  for_each = var.ec2_instance_settings

  # General settings
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  spot_price                  = each.value.spot_price
  availability_zone           = local.availability_zone
  key_name                    = aws_key_pair.key_pair.key_name
  private_ip                  = cidrhost(aws_subnet.subnet.cidr_block, each.value.hostnum)
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.security_group.id]

  # Spot settings
  spot_type                      = "persistent"
  instance_interruption_behavior = "terminate"
  wait_for_fulfillment           = true

  credit_specification {
    cpu_credits = "standard"
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

}

# resource "aws_volume_attachment" "volume_attachment" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.ebs_volume.id
#   instance_id = aws_spot_instance_request.spot_instance_request.id
# }

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# A security group for the ELB so it is accessible via the VM
resource "aws_security_group" "security_group" {
  description = "Allow connection between NLB and target"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = aws_security_group.security_group.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_minecraft" {
  security_group_id = aws_security_group.security_group.id
  from_port         = 25565
  to_port           = 25565
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_route53_zone" "route53_zone" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "a_record" {
  for_each = var.ec2_instance_settings

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = each.key
  type    = "A"
  ttl     = "300"
  records = [aws_spot_instance_request.spot_instance_request[each.key].associate_public_ip_address]
}
