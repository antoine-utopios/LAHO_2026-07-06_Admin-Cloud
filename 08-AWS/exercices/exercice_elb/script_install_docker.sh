sudo dnf install -y docker 
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user 
sudo docker run -d --name nginx --restart always -p 80:80 nginx:alpine