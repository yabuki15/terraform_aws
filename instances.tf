# ---Bastion---
resource "aws_instance" "bastion" {
  ami           = "ami-095af7cb7ddb447ef"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# ---Private Instance---
resource "aws_instance" "private" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet }

  ami           = "ami-095af7cb7ddb447ef"
  instance_type = "t3.micro"
  subnet_id     = each.value.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_instances.id]

  tags = {
    Name = "${var.project_name}-private-server-${each.key + 1}"
  }
}

# ---Public SNAT Instances---
data "template_file" "snat_user_data" {
  template = file("${path.module}/user_data.sh")
}

resource "aws_instance" "public_snat" {
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet }

  ami                    = "ami-095af7cb7ddb447ef"
  instance_type          = "t3.micro"
  subnet_id              = each.value.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.public_snat_instances.id, aws_security_group.bastion.id]
  source_dest_check      = false
  user_data              = data.template_file.snat_user_data.rendered

  tags = {
    Name = "${var.project_name}-public-snat-server-${each.key + 1}"
  }
}