#!/usr/bin/env bash

set -euo pipefail

BLUE="\e[34m"; GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"; BOLD="\e[1m"

step() {
  echo
  echo -e "${BLUE}${BOLD}[*] $1${RESET}"
}

echo -e "${BLUE}${BOLD}"
echo "============================================"
echo "   GENSYN RL-SWARM CPU-ONLY AUTO INSTALLER"
echo "============================================"
echo -e "${RESET}"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "${RED}Please script ko root user se mat chalao.${RESET}"
  echo "Normal user se run karo (jiske paas sudo ho)."
  exit 1
fi

# ------------------ STEP 1: System update ------------------
step "Step 1/4: System packages update & upgrade"
sudo apt update && sudo apt upgrade -y

# ------------------ STEP 2: Base deps ----------------------
step "Step 2/4: Base tools & Python install"
sudo apt install -y \
  screen curl build-essential git wget lz4 jq make gcc nano \
  automake autoconf tmux htop ncdu unzip \
  python3 python3-pip python3-venv python3-dev

# ------------------ STEP 3: Node + Yarn --------------------
step "Step 3/4: Node.js (22.x) & Yarn install"

# NodeSource add
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Nodejs install
sudo apt install -y nodejs

echo -e "${YELLOW}Trying: sudo npm install -g yarn${RESET}"
if ! sudo npm install -g yarn; then
  echo -e "${YELLOW}Warning:${RESET} yarn global install fail hua, lekin yeh optional hai."
fi

echo -e "${GREEN}Node version:${RESET} $(node -v || echo 'not found')"
echo -e "${GREEN}NPM version:${RESET}  $(npm -v || echo 'not found')"

# ------------------ STEP 4: rl-swarm setup -----------------
step "Step 4/4: rl-swarm clone + CPU start script"

cd "$HOME"

if [ -d "rl-swarm" ]; then
  echo -e "${YELLOW}Purana rl-swarm mil gaya.${RESET}"
  if [ -f "rl-swarm/swarm.pem" ]; then
    echo -e "${YELLOW}swarm.pem ka backup le raha hoon -> ~/swarm.pem.backup${RESET}"
    cp rl-swarm/swarm.pem "$HOME/swarm.pem.backup"
  fi
  echo -e "${YELLOW}Purana rl-swarm delete kar raha hoon...${RESET}"
  rm -rf rl-swarm
fi

git clone https://github.com/gensyn-ai/rl-swarm
cd rl-swarm

echo -e "${YELLOW}Python virtual env bana raha hoon...${RESET}"
python3 -m venv .venv
# just in case
if ! source .venv/bin/activate 2>/dev/null; then
  . .venv/bin/activate
fi

echo -e "${YELLOW}start_swarm_cpu.sh bana raha hoon...${RESET}"

cat > start_swarm_cpu.sh << 'EOF'
#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

python3 -m venv .venv
if ! source .venv/bin/activate 2>/dev/null; then
  . .venv/bin/activate
fi

SESSION="swarm"

if screen -list | grep -q "\.${SESSION}"; then
    echo "Swarm already running. Attach using: screen -r ${SESSION}"
    exit 0
fi

echo "Starting RL-Swarm (CPU mode) in screen session '${SESSION}'..."

screen -dmS "${SESSION}" bash -c '
echo -e "\e[1;34m===== Launching Gensyn RL-Swarm (CPU) =====\e[0m"
echo -e "\e[33mAttach logs:  screen -r swarm\e[0m"
echo
sleep 2
./run_rl_swarm.sh
echo
echo -e "\e[31mRL-Swarm stopped. Press ENTER to close session.\e[0m"
read
'

echo "Started! Attach via: screen -r ${SESSION}"
EOF

chmod +x start_swarm_cpu.sh

echo
echo -e "${GREEN}${BOLD}Installation complete!${RESET}"
echo
echo -e "${BOLD}Reboot hone ke baad:${RESET}"
echo -e "  1) Node start:   ${YELLOW}cd ~/rl-swarm && ./start_swarm_cpu.sh${RESET}"
echo -e "  2) Logs dekhne:  ${YELLOW}screen -r swarm${RESET}"
echo
echo -e "${YELLOW}System 5 second me reboot hoga...${RESET}"
sleep 5
sudo reboot
