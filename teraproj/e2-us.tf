variable "ubuntu" {}
variable "centOS" {}
variable "kube" {}


provider "aws" {
    region     = "us-east-2"
    shared_credentials_file = "~/.aws/credentials"
}

resource "aws_vpc" "reza-vpc-e2-us" {
    cidr_block = "172.16.0.0/16"
    assign_generated_ipv6_cidr_block  = true
    tags = {
        Name = "reza-vpc-cluster"
    }
}
# take only 10 ips from subnet since we wont exceed more than that
resource "aws_internet_gateway" "reza-igw" {
    vpc_id = aws_vpc.reza-vpc-e2-us.id

    tags = {
        Name = "reza-igw"
    }
}

resource "aws_subnet" "reza-cluster-sub-e2-us" {
    vpc_id            = aws_vpc.reza-vpc-e2-us.id
    # vpc_id            = var.vpc_id
    availability_zone = "us-east-2a"
    cidr_block        = cidrsubnet(aws_vpc.reza-vpc-e2-us.cidr_block, 12, 0)
    # cidr_block        = "172.16.0.0/28"
    tags = {
        name = "reza-sub-cluster-1"
    }
}
# since default route is not the way to go we make a new one
resource "aws_route_table" "reza_main_cluster_routes" {
    vpc_id = aws_vpc.reza-vpc-e2-us.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.reza-igw.id
    }
    
    tags = {
        Name = "reza-routes"
    }

}


# mac book key :)
resource "aws_key_pair" "reza-ssh" {
    key_name   = "reza-ssh"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1o4KwdaZX6+ZIreTiEui9s+EbSPWgy06VVMeMSHC3zP4rOfBQK6LSQuyVChTqumtX6EcN0U9xuAwey8OsRzQWn1yJ80T2/QhRgiPBRz1NrPJ+ZTPW3Zcx4mQiGthVJvoRKTD2naaV2W2c1t2c04DFqomPXfoSH7aTgofFymRkYcR90BRksVeEYIG263mQsuZusyorf2pz4ZKhB28TLAChWDiUeVg3+jQnXfJXR2+odDYqJdO4Hp2FLeeUMH0CLegliksaI9erPcll2S1XMCmb6iBsNVX/9HcBw3SLNpOlXXGl5SLVrqVdwOzslxdDNlzhTNhiHtzHgugmrfu1jDlB ice@iCEs-MacBook-Pro.local"
}

resource "aws_security_group" "reza-cluster-sgp-rules" {
    name        = "reza-cluster-sgp-rules"
    vpc_id      = aws_vpc.reza-vpc-e2-us.id
    # description = "Reza"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        # maybe restrict it in future?
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow Internal network to communicate"
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["172.16.0.0/28"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "reza-cluster-sgp-rules"
    }

}

resource "aws_instance" "reza-kube-master" {
    ami           = var.ubuntu
    instance_type = "t3.small"
    key_name      = "reza-ssh"
    availability_zone = "us-east-2a"
    subnet_id = aws_subnet.reza-cluster-sub-e2-us.id
    # security_groups = [aws_security_group.reza-cluster-sgp-rules.id]
    #aws additions
    vpc_security_group_ids = [aws_security_group.reza-cluster-sgp-rules.id]
    monitoring = false
    # dynamic public ip
    associate_public_ip_address = false
    tags = {
        Name = "reza-kube-master"
    }
    credit_specification {
        cpu_credits = "unlimited"
    }
    disable_api_termination = false
    ebs_optimized = false
}




resource "aws_instance" "reza-kube-1" {
    ami           = var.kube
    instance_type = "t3.small"
    key_name      = "reza-ssh"
    availability_zone = "us-east-2a"
    subnet_id = aws_subnet.reza-cluster-sub-e2-us.id
    # security_groups = [aws_security_group.reza-cluster-sgp-rules.id]
    #aws additions
    vpc_security_group_ids = [aws_security_group.reza-cluster-sgp-rules.id]
    monitoring = false
    # dynamic public ip
    associate_public_ip_address = false
    tags = {
        Name = "reza-kube-1"
    }
    credit_specification {
        cpu_credits = "unlimited"
    }
    disable_api_termination = false
    ebs_optimized = false

}

resource "aws_instance" "reza-kube-2" {
    ami           = var.kube
    instance_type = "t3.small"
    key_name      = "reza-ssh"
    availability_zone = "us-east-2a"
    subnet_id = aws_subnet.reza-cluster-sub-e2-us.id
    # security_groups = [aws_security_group.reza-cluster-sgp-rules.id]
    #aws additions
      vpc_security_group_ids = [aws_security_group.reza-cluster-sgp-rules.id]
    monitoring = false
    # dynamic public ip
    associate_public_ip_address = false
    tags = {
        Name = "reza-kube-2"
    }
    credit_specification {
        cpu_credits = "unlimited"
    }
    disable_api_termination = false
    ebs_optimized = false
}

# resource "aws_instance" "reza-kube-3" {
#     ami           = var.ubuntu
#     instance_type = "t3.small"
#     key_name      = "reza-ssh"
#     availability_zone = "us-east-2a"
#     subnet_id = aws_subnet.reza-cluster-sub-e2-us.id
#     # security_groups = [aws_security_group.reza-cluster-sgp-rules.id]
#     #aws additions
#     #   vpc_security_group_ids = [aws_security_group.reza-cluster-sgp-rules.id]
#     monitoring = false
#     # dynamic public ip
#     associate_public_ip_address = false
#     tags = {
#         Name = "reza-kube-3"
#     }
#     credit_specification {
#         cpu_credits = "unlimited"
#     }
#     disable_api_termination = false
#     ebs_optimized = false
# }

# resource "aws_instance" "reza-kube-4" {
#     ami           = var.ubuntu
#     instance_type = "t3.small"
#     key_name      = "reza-ssh"
#     availability_zone = "us-east-2a"
#     subnet_id = aws_subnet.reza-cluster-sub-e2-us.id
#     # security_groups = [aws_security_group.reza-cluster-sgp-rules.id]
#     #aws additions
#     #   vpc_security_group_ids = [aws_security_group.reza-cluster-sgp-rules.id]
#     monitoring = false
#     # dynamic public ip
#     associate_public_ip_address = false
#     tags = {
#         Name = "reza-kube-4"
#     }
#     credit_specification {
#         cpu_credits = "unlimited"
#     }
#     disable_api_termination = false
#     ebs_optimized = false
# }
