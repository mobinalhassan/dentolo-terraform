# Creating a VPC
resource "aws_vpc" "postgresql_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Creating a subnet
resource "aws_subnet" "postgresql_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.postgresql_vpc.id
}

# Creating security group for DB
resource "aws_security_group" "postgresql_sg" {
  name_prefix = "postgresql-db-sg"

  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.postgresql_vpc.id
}

# Creating DB subnet group
resource "aws_db_subnet_group" "postgresql_subnet_sg" {
  name       = "postgresql-subnet-group"
  subnet_ids = [aws_subnet.postgresql_subnet.id]
}


# Creating parameter group (in case we are managing multiple instance)
resource "aws_db_parameter_group" "postgresql_prem_g" {
  name   = "postgresql-param-group"
  family = "postgres"
  parameters = {
    "shared_buffers"          = "1024MB"
    "work_mem"                = "4MB"
    "maintenance_work_mem"    = "256MB"
    "max_connections"         = "100"
    "effective_cache_size"    = "2048MB"
    "wal_buffers"             = "16MB"
    "checkpoint_completion_target" = "0.9"
  }
}

# Creating postgres database instance
resource "aws_db_instance" "dentolo-postgres" {
  identifier            = "dentolo-postgres"
  instance_class        = "db.t2.micro"
  engine                = "postgres"
  engine_version        = "11.12"
  name                  = "dentolo_db"
  username              = "dentolo_user"
  password              = "dentolo_password"
  db_subnet_group_name  = aws_db_subnet_group.postgresql_subnet_sg.name
  parameter_group_name  = aws_db_parameter_group.postgresql_prem_g.name
  vpc_security_group_ids = [aws_security_group.postgresql_sg.id]
  publicly_accessible   = true
  delete_automated_backups = true
  skip_final_snapshot     = true

  tags = {
    Name = "dentolo-tf-postgres"
  }
}

