provider "aws" {
region = 
}

resource "aws_vpc" "MAIN-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "zone A VPC"
    }
}

resource "aws_subnet" "public-subnet-zone-A" {
  vpc_id     = aws_vpc.MAIN-vpc.id
  cidr_block = "10.0.0.0/24"
  availabilty_zone = "us-west-2a"

  tags = {
    Name = "Public zone-A sub"
  }
}

resource "aws_internet_gateway" "inter-gw" {
  vpc_id = aws_vpc.MAIN-vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public-route-table-A" {
  vpc_id = aws_vpc.MAIN-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inter-gw.id
  }

  tags = {
    Name = "public Route Table A"
  }
}

resource "aws_route_table_association" "rout-A-public" {
  subnet_id      = aws_subnet.public-subnet-zone-A.id
  route_table_id = aws_route_table.public-route-table-A.id
}

resource "aws_instance" "public-web-zone-A" {
  ami = ""
  instance_type = ""
  subnet_id      = aws_subnet.public-subnet-zone-A.id
  vpc_security_group_ids = [aws_security_group.public-ec2-tls.id]
 associate_public_ip_address = true
 
  key_name = ""
  
  tags = {
    Name = "public web zone A"
  }
}

resource "aws_security_group" "public-ec2-tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.MAIN-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private ec2 tls"
  }
}

resource "aws_nat_gateway" "public-nat-gw-zone-A" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.public-subnet-zone-A.id

  tags = {
    Name = "public NAT gw zone A"
  }
  depends_on = [aws_internet_gateway.inter-gw]
}


resource "aws_subnet" "private-subnet-zone-A" {
  vpc_id     = aws_vpc.MAIN-vpc.id
  cidr_block = "10.0.0.0/24"
  availabilty_zone = "us-west-2a"

  tags = {
    Name = "private zone-A sub"
  }
}

resource "aws_route_table" "private-route-table-A" {
  vpc_id = aws_vpc.MAIN-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    instancd_id = aws_instance.public-web-zone-A.id
  }

  tags = {
    Name = "private Route Table A"
  }
}

resource "aws_route_table_association" "rout-A-private" {
  subnet_id      = aws_subnet.private-subnet-zone-A.id
  route_table_id = aws_route_table.private-route-table-A.id
}

resource "aws_instance" "private-DB-zone-A" {
  ami = ""
  instance_type = ""
  subnet_id      = aws_subnet.private-subnet-zone-A.id
  vpc_security_group_ids = [aws_security_group.private-ec2-tls.id]
  key_name = ""
  
  tags = {
    Name = "private DB zone A"
  }
}

resource "aws_security_group" "private-ec2-tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.MAIN-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private ec2 tls"
  }
}


