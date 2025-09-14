packer {
  required_plugins {
    amazon = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

hcp_packer_registry {
  bucket_name       = "mongodb-ami"
  bucket_description = "MongoDB AMIs"

  build_labels = {
    environment = "dev"
    os          = "ubuntu"
    db          = "mongodb"
  }
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_ec2_type" {
  type = string
  default = "t3.medium"
}

variable "source_ami" {
  type = string
  default = "ami-0fb0b230890ccd1e6"
}

variable "subnet_id" {
  type = string
  default = "subnet-0c822fa70219ace73"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  source_ami    = var.source_ami
  subnet_id     = var.subnet_id
  associate_public_ip_address = true

  instance_type = var.aws_ec2_type
  ssh_username  = "ubuntu"
  ami_name      = "mongodb-ubuntu-ami-{{timestamp}}"

  tags = {
    Name = "mongodb-ubuntu-ami"
  }
}

build {
  name    = "ec2-mongodb-ubuntu"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./mongod.conf"
    destination = "/tmp/mongod.conf"
  }

  provisioner "file" {
    source      = "./backup_mongo_to_s3.sh"
    destination = "/tmp/backup_mongo_to_s3.sh"
  }

  provisioner "shell" {
    inline = [
      # Wait for cloud-init to finish its bootstrap process
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",

      # Update and install dependencies
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y gnupg wget software-properties-common netcat unzip",

      # Download aws cli
      "wget -qO /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip",
      "unzip /tmp/awscliv2.zip",
      "sudo ./aws/install",
      "sudo rm -rf /tmp/awscliv2.zip",

      # Download MongoDB GPG key safely
      "wget -qO /tmp/mongodb-server-6.0.gpg https://www.mongodb.org/static/pgp/server-6.0.asc",

      # Convert to keyring format and move to /usr/share/keyrings
      "sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg /tmp/mongodb-server-6.0.gpg",

      # Add MongoDB repository for Ubuntu 20.04 (focal)
      "echo 'deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list",

      # Install MongoDB
      "sudo apt-get update -y",
      "sudo apt-get install -y mongodb-org mongodb-mongosh",

      # Enable and start MongoDB
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",

      # Wait for MongoDB to be ready
      "until nc -z 127.0.0.1 27017; do echo 'Waiting for MongoDB to start...'; sleep 1; done",

      # Create admin user
      "mongosh --eval 'db.getSiblingDB(\"admin\").createUser({user: \"mongodb_admin\", pwd: \"pass123\", roles: [{role: \"root\", db: \"admin\"}]})'",

      # Override MongoDB config
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo chown root:root /etc/mongod.conf",
      "sudo chmod 644 /etc/mongod.conf",
      "sudo systemctl restart mongod",

      # Persist environment variables for cron and scripts
      "sudo tee /etc/profile.d/custom_env.sh > /dev/null <<EOF",
      "export S3_BUCKET_NAME=wiz-s3-bucket-db-backups",
      "export MONGO_ADMIN_USER=mongodb_admin",
      "export MONGO_ADMIN_PASS=pass123",
      "EOF",
      "sudo chmod +x /etc/profile.d/custom_env.sh",

      # Setup backup script
      "sudo mv /tmp/backup_mongo_to_s3.sh /usr/local/bin/backup_mongo_to_s3.sh",
      "sudo chmod +x /usr/local/bin/backup_mongo_to_s3.sh",

      # Install cron job safely
      "echo '0 * * * * root /usr/local/bin/backup_mongo_to_s3.sh >> /var/log/mongodb_backup.log 2>&1' | sudo tee /etc/cron.d/mongodb_backup",
      "sudo chmod 644 /etc/cron.d/mongodb_backup",
      "sudo systemctl restart cron"
    ]
  }
}
