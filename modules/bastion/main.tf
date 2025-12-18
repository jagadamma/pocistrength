data "aws_key_pair" "bastion_key" {
  key_name = "${var.pem_key}"
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.bastion.instance_type
  key_name      = data.aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id     = var.public_subnet_ids[0]  
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  user_data = "${file("${path.module}/userdata.sh")}"

  metadata_options {
    http_tokens  = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = var.bastion.bastion_volume_type
    volume_size = var.bastion.bastion_volume_size
    delete_on_termination = true
    encrypted = true
  }

  lifecycle {
    ignore_changes = [ ami,user_data ]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-bastion"
    }
  )
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

