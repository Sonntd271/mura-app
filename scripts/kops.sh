#! /bin/bash

HOSTNAME="kops"

# ---------- Change hostname ---------- #
sudo sh -c 'echo $HOSTNAME > /etc/hostname'
sudo hostname "$HOSTNAME"

# ---------- Install Kubectl ---------- #
# Ref: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
sudo apt-get update -y && sudo apt-get install ca-certificates curl -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install kubectl -y

# ---------- Install kOps ---------- #
# Ref: https://kops.sigs.k8s.io/getting_started/install/
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
sudo chmod +x kops
sudo mv kops /usr/local/bin/kops

# ---------- Install Helm ---------- #
# Ref: https://helm.sh/docs/intro/install/
curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https -y # Test to see if can skip
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install helm -y

# ---------- Install Docker ---------- #
# Ref: https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu