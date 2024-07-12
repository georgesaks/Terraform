#Create EC2 Instance
resource "aws_instance" "server_jenkins" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.SGG_Jenkins.id]
  associate_public_ip_address = true

  tags = {
    Name = "server_jenkins"
  }



  user_data = <<-EOF
    #!/bin/bash
    #Update the package index
    apt-get update
    # Install the default JDK (or specify a version if needed)
    apt-get install -y default-jdk
    # Set the JAVA_HOME environment variable
    JAVA_HOME=$(sudo update-alternatives --config java | grep -oP '(?<=\s)[^/]+(/[^/]+)+(?=/bin/java)')
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/jdk.sh
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
    # Source the profile to load the environment variables
    source /etc/profile.d/jdk.sh
    # Download the Jenkins GPG key and save it to /usr/share/keyrings/jenkins-keyring.asc
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    # Add the Jenkins repository to the system's APT sources list
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    # Update the local package index to include the latest information about available packages
    apt-get update
    # Install Jenkins using the apt-get package manager
    apt-get install -y jenkins
    # Start Jenkins at boot
    systemctl enable jenkins
    EOF

}

# Create Instance Security Group
resource "aws_security_group" "SGG_Jenkins" {
  name        = "SGG_Jenkins"
  description = "Allow SSH and Web traffic from my IP and allow all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SG_Jenkins"
  }

  # Create Ingress Rule to allow Web Traffic
  ingress {
    cidr_blocks = [var.cidr_blocks]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  # Create Ingress Rule to allow SSH from my IP
  ingress {
    cidr_blocks = [var.cidr_blocks]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    # Create Ingress Rule to allow Port 8080 from my IP
    cidr_blocks = [var.cidr_blocks]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  egress {
    # Create Egress Rule
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

}

# Make S3 private bucket for Jenkins' artifact  
resource "aws_s3_bucket" "bucket-server-jenkins-saks1vzprv" {
  bucket = "bucket-server-jenkins-saks1vzprv"

  tags = {
    Name = "bucket-server-jenkins-saks1vzprv"
  }
}

# Create S3 bucket ownership control
resource "aws_s3_bucket_ownership_controls" "jenkins-bucket-acl-ownershippq" {
  bucket = aws_s3_bucket.bucket-server-jenkins-saks1vzprv.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# Create S3 bucket acl
resource "aws_s3_bucket_acl" "jenkins-bucket-acllq" {
  bucket = aws_s3_bucket.bucket-server-jenkins-saks1vzprv.id
  acl    = "private"
}