provider "aws" {
  region = var.region
}

locals {
  tags = {
    Name = "Terraform"
  }
}

# VPC 
## Reponsável por colocar em uma mesma rede todos os recursos ligados a essa VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = local.tags
}


# Internet Gateway
## Resposável por receber os dados vindo do **cliente** na internet e jogar para dentro da VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

# Subnet
# Restringe o acesso na rede para uma determinada zona (Nessa caso a zona A)
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Public 1a"
  }
}

# Subnet
# Restringe o acesso na rede para uma determinada zona (Nessa caso a zona B)
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Public 1b"
  }
}

# Subnet
# Restringe o acesso na rede para uma determinada zona (Nessa caso a zona A - Porém privada)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Private 1a"
  }
}

# Subnet
# Restringe o acesso na rede para uma determinada zona (Nessa caso a zona B - Porém privada)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Private 2b"
  }
}

# AWS Route table
## Irá fazer o redirecionamento do trafico entre as zonas publicas
# ira permtir o roteamento com internet gateway
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform public"
  }
}

# AWS Route table
## Irá fazer o redirecionamento do trafico entre as zonas privadas 
## não ira permtir o roteamento com internet gateway
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Terraform private"
  }
}

# AWS Route table Association
## Associação de tabelas de IP entre a rede publica de zona A
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public.id
}

# AWS Route table Association
## Associação de tabelas de IP entre a rede publica de zona B
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public.id
}

# AWS Route table Association
## Associação de tabelas de IP entre a rede privada de zona A
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.rt_private.id
}

# AWS Route table Association
## Associação de tabelas de IP entre a rede privada de zona B
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow public inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80 #http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 #https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_a_cidr]
  }

  tags = {
    Name = "Web Server"
  }
}

resource "aws_security_group" "db" {
  name        = "db"
  description = "Allow incoming database connections"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database"
  }
}