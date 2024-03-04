# Create an Application Load Balancer (ALB) with the specified attributes
resource "aws_lb" "example_alb" {
  name                          = "example-alb"
  internal                      = false
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.instance_sg.id]
  subnets                       = [aws_subnet.public_subnet.id , aws_subnet.public_subnet2.id]
  enable_deletion_protection    = false
  enable_http2                  = true

  tags = {
    Name = "example-alb"
  }

  # Ensure the ALB is created after the associated EC2 instance
  depends_on = [aws_instance.example_instance]
}

# Create a target group for the ALB to route traffic to the instances
resource "aws_lb_target_group" "example_target_group" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.myvpc.id
}

# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.example_target_group.arn
  target_id        = aws_instance.example_instance.id
  port             = 80
}

# Create a listener for the ALB to route incoming requests to the target group
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Define the default action to forward requests to the target group
  default_action {
    target_group_arn = aws_lb_target_group.example_target_group.arn
    type             = "forward"
  }
}
