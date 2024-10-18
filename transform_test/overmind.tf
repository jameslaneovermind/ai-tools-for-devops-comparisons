resource "aws_instance" "arm_instance" {
  ami                         = "ami-0047583bbf9a6fdb7"
  instance_type               = "t4g.medium"
  availability_zone           = "eu-west-2a"
  subnet_id                   = "subnet-09d5f6fa75b0b4569"
  vpc_security_group_ids      = ["sg-0a563b49fc92f135d"]
  associate_public_ip_address = true

  tags = {
    Name                               = "arm"
    aws:autoscaling:groupName          = "eks-arm-20240410075707442800000003-bec76381-5b85-12e0-0ba0-951a2f314fda"
    aws:ec2:fleet-id                   = "fleet-f41fc695-88a5-c42d-0e1a-290077c45745"
    aws:ec2launchtemplate:id           = "lt-09482971fcfcabd67"
    aws:ec2launchtemplate:version      = "23"
    aws:eks:cluster-name               = "dogfood"
    eks:cluster-name                   = "dogfood"
    eks:nodegroup-name                 = "arm-20240410075707442800000003"
    k8s.io/cluster-autoscaler/dogfood  = "owned"
    k8s.io/cluster-autoscaler/enabled  = "true"
    kubernetes.io/cluster/dogfood      = "owned"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  iam_instance_profile = "eks-bec76381-5b85-12e0-0ba0-951a2f314fda"
}