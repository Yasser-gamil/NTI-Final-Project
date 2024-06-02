resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg-"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0e87fae068ae8d4e0" # amazon linux
  instance_type = "t3.medium"
  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }
  key_name = "jenkins-instance"  

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]  # Reference to the security group we just defined
  subnet_id              = element(aws_subnet.public.*.id, 0)

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_backup_vault" "jenkins_backup_vault" {
  name = "jenkins-backup-vault"
}

resource "aws_backup_plan" "jenkins_backup_plan" {
  name = "jenkins-daily-backup"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.jenkins_backup_vault.name
    schedule          = "cron(0 5 * * ? *)" # Daily at 5 AM UTC

    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_selection" "jenkins_backup_selection" {
  iam_role_arn = "arn:aws:iam::767397878056:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup" # Update with your backup service role
  name         = "jenkins-backup-selection"
  plan_id      = aws_backup_plan.jenkins_backup_plan.id

  resources = [
    aws_instance.jenkins.arn
  ]
}

# Add an output for the Jenkins instance public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
