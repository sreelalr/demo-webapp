
# Creating Key
resource "aws_key_pair" "terraform-keys" {
  key_name   = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRn/vLCWaOHKnq3LpM4t5A4BcN7C6RJKWElrRUKHvmEMHAo3Ga95cGofjOfKXO0cOB62Ip2k2rP2U24WC8D/jlfzBXL4MVK4mSs4JYHuixWrIF+VfD2WYi6qO1djLqtdx+u3voFd6yYUZ2uQSZAFW1L1yLUZobvZLa32h7FhjdKxWQEXt0fx1fdM+CRsuiL1lCfEAERXmuKKAGvW9LbANfvRyB+kL83HnO7LU8aTdKsZ5Z4eu09DY0tgUCrZLE2lONdEWcCgumjSXoNTQqzC2vdCjwKzrETaOYkDd+EHvkNlBCTlz9PWYU9v1BZgfq4X9rnidwicGee2WWmCqD8QCjTt1gC8q0bgRkuYNpRKwsdppJ25qWJpbqMnDzcIYSdRq/ZBtPaBbWSxVEuGtjTa9r2560l0UIqYBnNHQmhdycnheG9hDjsF0qhyshy3S2bMBf/pd1+RLs5ne5BWFP8Kn5K55PjCxyRqRQhwhlXaR9xEzCkqFDZwNh3wXi+gfvivk= sreelal@vivobook"
}

#Create EC2 Instance
resource "aws_instance" "webserver" {
  count                  = var.item_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names[count.index]
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet[count.index].id
  key_name               = aws_key_pair.terraform-keys.key_name
  iam_instance_profile   = aws_iam_instance_profile.iam_ec2_profile.name
  user_data              = file("install_web.sh")

  provisioner "file" {
    source      = "demo"
    destination = "/home/ec2-user/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/terraform")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Web Server${count.index}"
  }

}

resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.terraform-keys.key_name
  availability_zone      = var.availability_zone_names[0]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.web-subnet[0].id
  user_data       = file("install_jenkins.sh")
  iam_instance_profile   = aws_iam_instance_profile.iam_ec2_profile.name

  
  tags = {
    Name = "Jenkins"
  }
}

#Create database
# resource "aws_db_instance" "default" {
#   allocated_storage      = var.rds_instance.allocated_storage
#   db_subnet_group_name   = aws_db_subnet_group.default.id
#   engine                 = var.rds_instance.engine
#   engine_version         = var.rds_instance.engine_version
#   instance_class         = var.rds_instance.instance_class
#   multi_az               = var.rds_instance.multi_az
#   name                   = var.rds_instance.name
#   username               = var.user_information.username
#   password               = var.user_information.password
#   skip_final_snapshot    = var.rds_instance.skip_final_snapshot
#   vpc_security_group_ids = [aws_security_group.database-sg.id]
# }

# resource "aws_db_subnet_group" "default" {
#   name       = "main"
#   subnet_ids = [aws_subnet.database-subnet[0].id, aws_subnet.database-subnet[1].id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }

resource "aws_ecr_repository" "simple-web-app" {
  name                 = "simple-web-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "Elastic Container Registry to store Docker Artifacts"
  }
}