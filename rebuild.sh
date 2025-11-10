#!/usr/bin/env bash
set -e

NIXOS_DIR="/etc/nixos"
REPO_URL="git@github.com:dosluke/nixconfig.git"
GIT_USER_NAME="dosluke"
GIT_USER_EMAIL="dosluke@gmail.com"


if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (use sudo)"
  exit 1
fi



mkdir -p "$NIXOS_DIR"
cd "$NIXOS_DIR" #VERY IMPORTANT FOR GIT COMMANDS

echo ""
echo "==> SYNCING"


git config --global init.defaultBranch main

# Initialize git if needed
git init 2>/dev/null || true

git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
git add -A
git commit -m "Local changes for rebuild"
git fetch origin
git push -u origin main 2>/dev/null || git push -u origin main --force
git pull --rebase




echo ""
echo "==> REBUILDING"

sudo nixos-rebuild switch --show-trace \
&& sudo refind-install --yes \
&& echo COPYING CUSTOM REFIND CONFIG. THIS IS MANAGED FROM NIXOS CONFIGURATUION \
&& sudo cp /etc/nixos/refind.conf /boot/EFI/refind/refind.conf



