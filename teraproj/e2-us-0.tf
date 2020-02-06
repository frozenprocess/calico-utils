resource "aws_eip" "reza-kube-master-nat" {
  vpc = true

  instance                  = aws_instance.reza-kube-master.id
  associate_with_private_ip = aws_instance.reza-kube-master.private_ip

  tags = {
      Name = "reza-kube-master-nat"
  }
}

resource "aws_eip" "reza-kube-1-nat" {
  vpc = true

  instance                  = aws_instance.reza-kube-1.id
  associate_with_private_ip = aws_instance.reza-kube-1.private_ip

  tags = {
      Name = "reza-kube-1-nat"
  }
}

resource "aws_eip" "reza-kube-2-nat" {
  vpc = true

  instance                  = aws_instance.reza-kube-2.id
  associate_with_private_ip = aws_instance.reza-kube-2.private_ip

  tags = {
      Name = "reza-kube-2-nat"
  }
}