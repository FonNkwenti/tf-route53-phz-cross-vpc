source "amazon-ebs" "flask-app" {
  region           = "eu-west-1"
  instance_type    = "t2.micro"
  source_ami       = "ami-0c55b159cbfafe1f0"  # Example Ubuntu AMI
  ssh_username     = "ubuntu"
  ami_name         = "flask-app-ami {{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.flask-app"]

  # Update and install dependencies
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip"
    ]
  }

  # Install Flask
  provisioner "shell" {
    inline = [
      "pip3 install flask"
    ]
  }

  # Configure and start Flask app
  provisioner "shell" {
    inline = [
      # Create a simple Flask app
      "echo 'from flask import Flask' > app.py",
      "echo 'app = Flask(__name__)' >> app.py",
      "echo '@app.route(\"/\")' >> app.py",
      "echo 'def home():' >> app.py",
      "echo ' return \"Hello, Flask!\"' >> app.py",
      "echo 'if __name__ == \"__main__\":' >> app.py",
      "echo ' app.run(host=\"0.0.0.0\", port=80)' >> app.py",

      # Start Flask app (or set up a systemd service for auto-restart)
      "nohup python3 app.py &"
    ]
  }

  # Optional: Configure a systemd service to ensure Flask starts on boot
  provisioner "shell" {
    inline = [
      "echo '[Unit]' > /etc/systemd/system/flask.service",
      "echo 'Description=Flask Application' >> /etc/systemd/system/flask.service",
      "echo '[Service]' >> /etc/systemd/system/flask.service",
      "echo 'ExecStart=/usr/bin/python3 /home/ubuntu/app.py' >> /etc/systemd/system/flask.service",
      "echo 'Restart=always' >> /etc/systemd/system/flask.service",
      "echo '[Install]' >> /etc/systemd/system/flask.service",
      "echo 'WantedBy=multi-user.target' >> /etc/systemd/system/flask.service",
      "sudo systemctl enable flask.service",
      "sudo systemctl start flask.service"
    ]
  }
}
