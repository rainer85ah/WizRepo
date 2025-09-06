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

variable "source_ami" {
  type = string
  default = "ami-0fb0b230890ccd1e6"
}

variable "subnet_id" {
  type = string
  default = "subnet-0b0fb0b9f166e8868"
}

source "amazon-ebs" "ubuntu" {
  region        = "us-east-1"
  source_ami    = var.source_ami
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "ec2-mongodb-ubuntu-{{timestamp}}"

  subnet_id     = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "ec2-mongodb-ubuntu"
  }
}

build {
  name    = "ec2-mongodb-ubuntu"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./wizexercise.txt"
    destination = "/tmp/wizexercise.txt"
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
      "sudo apt-get install -y gnupg wget software-properties-common",

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

      # Enable authentication
      "sudo sed -i '/#security:/a security:\\n  authorization: \"enabled\"' /etc/mongod.conf",
      "sudo systemctl restart mongod",

      # Create admin user
      "sudo mongosh --eval 'db.getSiblingDB(\"admin\").createUser({user:\"mongodb_admin\", pwd:\"pass123\", roles:[{role:\"root\", db:\"admin\"}]})'",

      # Setup backup script
      "sudo mv /tmp/backup_mongo_to_s3.sh /usr/local/bin/backup_mongo_to_s3.sh",
      "sudo chmod +x /usr/local/bin/backup_mongo_to_s3.sh",
      "echo '0 16 * * * root S3_BUCKET_NAME=$S3_BUCKET_NAME /usr/local/bin/backup_mongo_to_s3.sh > /var/log/mongodb_backup.log 2>&1' | sudo tee /etc/cron.d/mongodb_backup",
      "sudo systemctl restart cron"
    ]
  }
}
