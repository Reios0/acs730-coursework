resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.instance_count
  alarm_name          = "${local.name}-cpu-high-${count.index}"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = var.alarm_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
}
