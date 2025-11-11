# Notes - READ
- If you are not me, you will want to clone repo, go through several files and change to your info. Im considering consolidating to a single variable file in future.

- This repo is primarily for me, though I may update things for others if it aligns/is congruent to my own OS.

- The rebuild and sync is expecting/tested with a seperate partition mounted at /boot and UEFI not bios. Its possible it works in other configurations, but not tested.

- Refind is a UEFI bootloader and is installed via the rebuild script, which chainloads systemd-boot (enabled in boot.nix). Without systemd-boot, refind is unable to understand nixos generations.

- If you do not know what you are doing, please do not use this on your own system. Whether you do or dont know what youre doing, use a VM to test first. Every part of these scripts and configs can be destructive. I have rendered my own VMs almost bricked multiple times, if it wern't for nixos generations.

- I have not installed this on my main system yet. I am working on this from a VM until it is ready to install on my main system.

- On my main system, I keep my boot partition on a seperate drive to try to keep windows (I hate that i have to use it once in a blue moon) from overwriting Refind. This will eventually be the case with these configs as well, as i move closer to switching to NixOS for my main system.

# To Install

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

### 3. Clone and Initialize

```bash
sudo nix-shell -p git openssh --run "bash <(curl -s https://raw.githubusercontent.com/dosluke/nixconfig/main/rebuild.sh)"
```

### 4. Reboot
