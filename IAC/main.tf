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

  # Puerto 5000 para Flask
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
    cidr_blocks = ["0.0.0.0/0"] # Para producción, restringe esto a tu IP
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
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_groups   = [aws_security_group.banco_sangre_sg.name]

  tags = {
    Name = "${var.project_name}-ec2"
  }

  # --- INICIO DE BLOQUES AÑADIDOS ---
  connection {
    type        = "ssh"
    user        = "ubuntu"
    
    # Ruta correcta a la llave (en la carpeta padre)
    private_key = file("../banco-sangre-key.pem") 
    
    host        = self.public_ip
  }

  # ==================================
  # == ¡ARREGLO #3: BORRAR Y RE-CREAR! ==
  # ==================================
  # Borra 'app' y la vuelve a crear vacía
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /home/ubuntu/app",
      "mkdir /home/ubuntu/app"
    ]
  }
  # ==================================

  # Copia la carpeta 'app' a la instancia
  provisioner "file" {
    source      = "../app/" # Sube el *contenido* de 'app'
    destination = "/home/ubuntu/app" # *Dentro* de la carpeta 'app'
  }

# Instala Python, Flask y ejecuta la app
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y", # <-- ¡AÑADE ESTA LÍNEA!
      "sudo apt-get install -y python3-venv python3-pip git",
      "sudo pip3 install flask",
      
      # Ejecuta la app en segundo plano
      "nohup python3 /home/ubuntu/app/app.py >/dev/null 2>&1 &"
    ]
  }
  # --- FIN DE BLOQUES AÑADIDOS ---
}