#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/ronald1404/ronald1404/refs/heads/main/configure-ssh.sh | sudo bash
set -e

echo "=== Gerador de chave SSH (ED25519) ==="
echo

# Pergunta o email
read -rp "Digite seu email corporativo: " EMAIL < /dev/tty

if [[ -z "$EMAIL" ]]; then
  echo "Erro: email não pode ser vazio."
  exit 1
fi

SSH_DIR="$HOME/.ssh"
BASE_KEY_NAME="id_ed25519"
KEY_PATH="$SSH_DIR/$BASE_KEY_NAME"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Evita sobrescrever chaves existentes
if [[ -f "$KEY_PATH" || -f "$KEY_PATH.pub" ]]; then
  i=1
  while [[ -f "${KEY_PATH}_$i" || -f "${KEY_PATH}_$i.pub" ]]; do
    ((i++))
  done
  KEY_PATH="${KEY_PATH}_$i"
fi

echo
echo "Gerando chave SSH em:"
echo "  $KEY_PATH"
echo

# Geração da chave
ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$KEY_PATH"

# Inicia ssh-agent se necessário
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  echo
  echo "Iniciando ssh-agent..."
  eval "$(ssh-agent -s)"
fi

# Adiciona a chave ao agent
ssh-add "$KEY_PATH"

echo
echo "=== Chave pública gerada ==="
echo
cat "${KEY_PATH}.pub"

echo
echo "Copie a chave acima e adicione ao GitHub/GitLab/Bitbucket."
