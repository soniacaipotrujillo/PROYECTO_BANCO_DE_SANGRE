# ==========================
# AMI de Ubuntu más reciente
# ==========================
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# ==========================
# Security Group para EC2
# ==========================
resource "aws_security_group" "banco_sangre_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group para la app Banco de Sangre"
  vpc_id      = null # usará la VPC por defecto

  # Permitir HTTP (puerto 80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # (Opcional) permitir puerto 5000 si quieres probar Flask directo
  ingress {
    description = "Flask dev port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH para conectarte a la instancia
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # luego lo puedes restringir
  }

  # Salida a internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================
# Instancia EC2
# ==========================
resource "aws_instance" "banco_sangre_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  security_groups        = [aws_security_group.banco_sangre_sg.name]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
