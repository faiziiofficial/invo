# Create a Key Management Service (KMS) key for RDS encryption
resource "aws_kms_key" "my_kms_key" {
  description               = "My KMS Key for RDS Encryption"
  deletion_window_in_days  = 30
}

# Create a security group for MySQL database
resource "aws_security_group" "mysql_sg" {
  name        = "db_sg"
  description = "Security group for DB"

  # Define ingress rule to allow MySQL traffic from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Associate security group with the VPC
  vpc_id = aws_vpc.myvpc.id
}

# Create private subnets for the RDS instances in different availability zones
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}

# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "my_db_subnet_group" {
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet2.id
  ]
}

# Create an RDS instance
resource "aws_db_instance" "default" {
  allocated_storage         = 50
  engine                    = "mysql"
  engine_version            = "5.7"
  db_subnet_group_name      = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.mysql_sg.id]
  auto_minor_version_upgrade = false
  backup_retention_period   = 7
  identifier                = "ha-mysql"
  instance_class            = "db.t3.medium"
  kms_key_id                = aws_kms_key.my_kms_key.arn
  multi_az                  = true 
  password                  = "secret1234"
  username                  = "phalcon"
  storage_encrypted         = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "my-db"

  timeouts {
    create = "1h"
    delete = "1h"
    update = "1h"
  }
}

# Output the connection endpoint of the RDS instance
output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(aws_db_instance.default.endpoint, null)
}
