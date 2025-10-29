terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "devops-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create Security Group
resource "aws_security_group" "devops" {
  name   = "devops-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# Create Key Pair
resource "aws_key_pair" "devops" {
  key_name   = "devops-key"
  public_key = tls_private_key.devops.public_key_openssh
}

# Generate private key
resource "tls_private_key" "devops" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.devops.private_key_pem
  filename        = "${path.module}/../terraform-key.pem"
  file_permission = "0400"
}

# Create EC2 Instances
resource "aws_instance" "controller" {
  ami                    = "ami-0360c520857e3138f"  # Ubuntu 20.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops.id]
  key_name               = aws_key_pair.devops.key_name

  tags = {
    Name = "controller"
  }
}

resource "aws_instance" "swarm_manager" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops.id]
  key_name               = aws_key_pair.devops.key_name

  tags = {
    Name = "swarm-manager"
  }
}

resource "aws_instance" "swarm_worker_a" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops.id]
  key_name               = aws_key_pair.devops.key_name

  tags = {
    Name = "swarm-worker-a"
  }
}

resource "aws_instance" "swarm_worker_b" {
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops.id]
  key_name               = aws_key_pair.devops.key_name

  tags = {
    Name = "swarm-worker-b"
  }
}

# Create Elastic IPs
resource "aws_eip" "controller" {
  instance = aws_instance.controller.id
  domain   = "vpc"

  tags = {
    Name = "controller-eip"
  }
}

resource "aws_eip" "swarm_manager" {
  instance = aws_instance.swarm_manager.id
  domain   = "vpc"

  tags = {
    Name = "swarm-manager-eip"
  }
}

resource "aws_eip" "swarm_worker_a" {
  instance = aws_instance.swarm_worker_a.id
  domain   = "vpc"

  tags = {
    Name = "swarm-worker-a-eip"
  }
}

resource "aws_eip" "swarm_worker_b" {
  instance = aws_instance.swarm_worker_b.id
  domain   = "vpc"

  tags = {
    Name = "swarm-worker-b-eip"
  }
}
