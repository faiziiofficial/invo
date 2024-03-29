# Create a VPC with the specified CIDR block and enable DNS support and DNS hostnames
resource "aws_vpc" "myvpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "myvpc"
  }
}

# Create a public subnet in the specified availability zone with a CIDR block
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Create another public subnet in a different availability zone
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Create an SSH key pair using the generated public key
resource "aws_key_pair" "example_key" {
  key_name   = "example_key" # Reference name generated by ssh-keygen command
  public_key = file("example_key.pub") # Reference name generated by ssh-keygen command
}

# Create a security group for EC2 instances with SSH and HTTP ingress rules
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for EC2 instance"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.myvpc.id
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

# Create a route table and define a route to the internet gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Launch an EC2 instance in the public subnet with a specified AMI, instance type, key pair, and security group
resource "aws_instance" "example_instance" {
  ami                              = "ami-0440d3b780d96b29d"
  instance_type                    = "t2.xlarge"
  key_name                         = aws_key_pair.example_key.key_name
  subnet_id                        = aws_subnet.public_subnet.id
  associate_public_ip_address      = true
  vpc_security_group_ids           = [aws_security_group.instance_sg.id] 

  # Execute remote commands on the instance after provisioning
  provisioner "remote-exec" {
    inline = [
      "echo 'DB_HOST=${aws_db_instance.default.endpoint}' > db_endpoint && sudo yum install git -y && git clone https://github.com/chanakyacool/invo && cd invo && sudo bash ShadowTracker.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("example_key")
      host        = self.public_ip
    }
  }

  # Ensure the instance is created after the associated database instance
  depends_on = [aws_db_instance.default]
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}
