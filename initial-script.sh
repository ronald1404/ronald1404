#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Execute este script como root (sudo)."
  exit 1
fi

echo "Atualizando o sistema..."
apt update
apt upgrade -y

echo "Instalando utilitários básicos..."
apt install -y \
  tmux \
  git \
  curl \
  neovim \
  net-tools \
  dnsutils \
  whois \
  tcpdump \
  wget \
  build-essential \
  unzip \
  tree \
  bashtop \
  zsh \
  neofetch \
  bind9-utils \
  telnet \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common

echo "Criando diretório temporário..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Baixando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo "Baixando Discord..."
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"

echo "Baixando Visual Studio Code..."
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

echo "Instalando pacotes .deb..."
apt install -y ./google-chrome-stable_current_amd64.deb ./discord.deb ./vscode.deb

echo "Instalando Docker..."

apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable
EOF

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker "$SUDO_USER"

echo "Instalando AWS CLI v2..."
cd "$TMP_DIR"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

echo "Instalando kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -m 0755 kubectl /usr/local/bin/kubectl

echo "Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Instalando eksctl..."
curl -sL https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

echo "Instalando Terraform e Packer..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
> /etc/apt/sources.list.d/hashicorp.list

apt update
apt install -y terraform packer

echo "Instalando Ansible..."
apt install -y ansible

echo "Limpando arquivos temporários..."
cd /
rm -rf "$TMP_DIR"

echo "Instalação concluída. Reinicie a sessão para usar Docker sem sudo."
