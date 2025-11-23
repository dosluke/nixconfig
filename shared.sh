#!/usr/bin/env bash
set -e


NIXOS_DIR="/etc/nixos"
REPO_URL="git@github.com:dosluke/nixconfig.git"
GIT_USER_NAME="dosluke"
GIT_USER_EMAIL="dosluke@gmail.com"
TEMP_HARDWARE_CONFIG="/tmp/hardware-configuration.nix.backup"
BRANCH="main"
LOCAL_USER="me"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
	echo -e "${GREEN}[INFO] $*${NC}"
}

warn() {
	echo -e "${YELLOW}[WARN] $*${NC}"
}

error() {
	echo -e "${RED}[ERROR] $*${NC}"
}
