provider "aws" {
  region = "eu-west-1" # Irlanda
}


# ---------------------------------------------------------
# Data source que obtiene ultma version AMI Amazon Linux 2
# ---------------------------------------------------------
data "aws_ami" "amazon_linux_2" {
    owners      = ["amazon"]
    most_recent = true
  
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
    
    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
}

# ---------------------------------------------------------
# Estado remoto
# ---------------------------------------------------------
data "aws_s3_object" "terraform_state" {
  bucket = "tf-state-pharos-269433206282-eu-west-1"
  key    = "aws_vpc_tonta/Structuralia/dev/vptonta/terraform.tfstate"
}

# Verify that the file content is not null
locals {
  # Debug: Print the state file content
  debug_state_content = "${data.aws_s3_object.terraform_state.body}"

  tfstate_content = data.aws_s3_object.terraform_state.body != null && data.aws_s3_object.terraform_state.body != "" ? data.aws_s3_object.terraform_state.body : "{}"
  tfstate        = jsondecode(coalesce(tfstate_content, "{}"))
}

# ---------------------------------------------------------
# AWS instance resource
# ---------------------------------------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3a.micro"
  subnet_id     = local.tfstate.outputs.public_subnets.value[0]

  tags = {
    Name = "instancia-tonta"
  }

  # Debug: Print the instance subnet ID
  debug_subnet_id = "${local.tfstate.outputs.public_subnets.value[0]}"
