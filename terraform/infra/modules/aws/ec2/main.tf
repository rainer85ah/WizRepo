resource "aws_key_pair" "my_key" {
  key_name   = "ssh_key"
  public_key = file("${path.module}/ssh_key.pub")
}

data "hcp_packer_version" "mongo_base" {
  bucket_name  = "mongodb-ami"
  channel_name = "latest"
}

data "hcp_packer_artifact" "mongo_ami" {
  bucket_name         = data.hcp_packer_version.mongo_base.bucket_name
  version_fingerprint = data.hcp_packer_version.mongo_base.fingerprint
  platform            = "aws"
  region              = var.aws_region
}

# Define an EC2 instance with MongoDB in each public subnet
resource "aws_instance" "db_instance" {
  count                       = 3
  ami                         = data.hcp_packer_artifact.mongo_ami.external_identifier
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.privileged_instance_profile.name
  vpc_security_group_ids      = [ var.ec2_instance_sg_id ]
  key_name                    = aws_key_pair.my_key.key_name

  user_data = templatefile("${path.module}/scripts/mongo-init.sh", {
    index    = count.index
    node0_ip = aws_instance.db_instance[0].private_ip
    node1_ip = aws_instance.db_instance[1].private_ip
    node2_ip = aws_instance.db_instance[2].private_ip
  })

  tags = {
    Name = "${var.name}-mongodb-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
