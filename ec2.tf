resource "aws_instance" "my_ec2" {
  # Amazon Linux 2023 AMI for Tokyo Region
  ami                    = "ami-095af7cb7ddb447ef"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.main[0].id # 1つ目のSubnetに配置
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "my-ec2-instance"
  }
}