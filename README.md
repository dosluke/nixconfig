# To Install

If you are not me, you will want to clone repo, go through several files and change to your info. Im considering consolidating to a single variable file in future.

### 1. Generate SSH Key

```bash
sudo ssh-keygen -t ed25519 -C "dosluke@gmail.com"
sudo cat /root/.ssh/id_ed25519.pub
```

Press Enter for default location and no passphrase

### 2. Add SSH Key to GitHub

1. https://github.com/settings/keys
2. New SSH key
3. Paste public key and save

### 3. Remove default configuration.nix
```bash
sudo rm -f /etc/nixos/configuration.nix
```

### 4. Clone and Initialize

```bash
sudo nix-shell -p git openssh --run "bash <(curl -s https://raw.githubusercontent.com/dosluke/nixconfig/main/rebuild.sh)"
```
