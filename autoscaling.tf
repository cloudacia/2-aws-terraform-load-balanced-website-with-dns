
# AWS LAUNCH CONFIGURATION
resource "aws_launch_configuration" "as_conf01" {
  name_prefix          = "web_config"
  image_id             = var.aws_amis[var.aws_region]
  instance_type        = var.instance_type
  key_name             = aws_key_pair.ec2_public_key.id
  security_groups      = [aws_security_group.webserver.id, aws_security_group.administration.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile01.id
  user_data            = filebase64("script.sh")
}

# AWS AUTO SCALING GROUP
resource "aws_autoscaling_group" "as01" {
  vpc_zone_identifier  = [aws_subnet.subnet02.id, aws_subnet.subnet04.id]
  name                 = "as01"
  launch_configuration = aws_launch_configuration.as_conf01.id
  desired_capacity     = 4
  min_size             = 2
  max_size             = 4
  target_group_arns    = [aws_alb_target_group.alb_tg_webserver.arn]
  enabled_metrics      = ["GroupDesiredCapacity"]
  health_check_type    = "ELB"
}

# AWS AUTO SCALING POLICY UP
resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.as01.id
}

# AWS CLOUDWATCH ALARM UP
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as01.id
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}

# AWS AUTO SCALING POLICY DOWN
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.as01.id
}

# AWS CLOUDWATCH ALARM DOWN
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as01.id
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}
