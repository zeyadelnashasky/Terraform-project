output "web_sg_id" { value = aws_security_group.web_sg.id }
output "asg_name" { value = aws_autoscaling_group.asg.name }
output "alb_dns_name" { value = aws_lb.web_alb.dns_name }