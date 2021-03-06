
# AWS SECURITY GROUP FOR EC2 INSTANCES
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow incoming traffic to port 80/TCP"
  vpc_id      = aws_vpc.vpc_dev.id
  tags = {
    Name = "webserver"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS SECURITY GROUP FOR THE LOAD BALANCER
resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow incoming traffic to port 80/TCP"
  vpc_id      = aws_vpc.vpc_dev.id
  tags = {
    Name = "ALB"
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
}
