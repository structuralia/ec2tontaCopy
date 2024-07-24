provider "aws" {
  region = "eu-west-3" # Paris
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
data "aws_s3_object" "base" {
  bucket = "tf-state-pharos-269433206282-eu-west-1"
  key    = "aws_vpc_tonta/Structuralia/dev/vptonta/terraform.tfstate"
}

resource "aws_instance" "web" {
    ami           = data.aws_ami.amazon_linux_2.id
    instance_type = "t3a.micro"
    subnet_id     = data.aws_s3_object.base.outputs.public_subnets.value[0]

    tags = {
        Name = "instancia-tonta"
    }
}
