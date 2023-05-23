provider "aws" {
  region = "ap-northeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#vpc 
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "medtech"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "medtech-igw"
  }
}

#route table
resource "aws_route_table" "main-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  
  
  tags = {
    Name = "medtech-rt"
  }
}

#dev-subnet
resource "aws_subnet" "dev_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.10.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "dev-subnet"
  }
}

#qa-subnet
resource "aws_subnet" "qa_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.10.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "qa-subnet"
  }
}

#uat-subnet
resource "aws_subnet" "uat_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.10.3.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "uat-subnet"
  }
}

#devops-subnet
resource "aws_subnet" "devops_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.10.4.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "devops-subnet"
  }
}
#route table-dev-association
resource "aws_route_table_association" "rt-as-dev" {
    subnet_id = aws_subnet.dev_subnet.id
    route_table_id = aws_route_table.main-rt.id
  
}
#route table-qa-association
resource "aws_route_table_association" "rt-as-qa" {
    subnet_id = aws_subnet.qa_subnet.id
    route_table_id = aws_route_table.main-rt.id
  
}
#route table-uat-association
resource "aws_route_table_association" "rt-as-uat" {
    subnet_id = aws_subnet.uat_subnet.id
    route_table_id = aws_route_table.main-rt.id
  
}
#route table-devops-association
resource "aws_route_table_association" "rt-as-devops" {
    subnet_id = aws_subnet.devops_subnet.id
    route_table_id = aws_route_table.main-rt.id
  
}
#security grp for ec2 
resource "aws_security_group" "medtech-sg" {
  name        = "medtech-sg"
  description = "Allow Web ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Tomcat from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "medtech-sg"
  }
}
#sg for lb
#security grp for ec2 
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "medtech-sg"
  }
}


#network interface for dev
resource "aws_network_interface" "dev-nf" {
  subnet_id       = aws_subnet.dev_subnet.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.medtech-sg.id]

}
#network interface for qa
resource "aws_network_interface" "qa-nf" {
  subnet_id       = aws_subnet.qa_subnet.id
  private_ips     = ["10.10.2.50"]
  security_groups = [aws_security_group.medtech-sg.id]

}
#network interface for uat
resource "aws_network_interface" "uat-nf" {
  subnet_id       = aws_subnet.uat_subnet.id
  private_ips     = ["10.10.3.50"]
  security_groups = [aws_security_group.medtech-sg.id]

}

#network interface for devops
resource "aws_network_interface" "devops-nf" {
  subnet_id       = aws_subnet.devops_subnet.id
  private_ips     = ["10.10.4.50"]
  security_groups = [aws_security_group.medtech-sg.id]

}



# creating elastic IP
resource "aws_eip" "dev-eip" {
  vpc = true
  network_interface =  aws_network_interface.dev-nf.id
  associate_with_private_ip = "10.10.1.50"
  depends_on =[
    aws_internet_gateway.igw
  ] 
  instance = aws_instance.dev-ec2.id
}

#network interface for dev
resource "aws_network_interface" "dev-nf" {
  subnet_id       = aws_subnet.dev_subnet.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.medtech-sg.id]

}


#creating ec2 instance in dev subnet
resource "aws_instance" "dev-ec2" {
 ami="ami-06fdbb60c8e83aa5e" 
 instance_type = "t3.large"
 availability_zone = var.availability_zone
 key_name = "tok-key"
 count = 5
 network_interface {
   device_index = 0
   network_interface_id = aws_network_interface.dev-nf.id
 }
 tags = {
   Name = "dev-ec2-1"
 }
 
}
