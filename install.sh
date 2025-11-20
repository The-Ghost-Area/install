#!/usr/bin/env bash

set -e

BLUE="\e[34m"; GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"; BOLD="\e[1m"

echo -e "${BLUE}${BOLD}"
echo "============================================"
echo "   GENSYN RL-SWARM CPU-ONLY AUTO INSTALLER"
echo "============================================"
echo -e "${RESET}"

echo -e "${YELLOW}Step 1/4: Updating system packages...${RESET}"
sudo apt update && sudo apt upgrade -y

echo -e "${YELLOW}Step 2/4: Installing base packages...${RESET}"
sudo apt install -y screen curl build-essential git wget lz4 jq make gcc nano \
automake autoconf tmux htop ncdu unzip python3 python3-pip python3-venv python3-dev

echo -e "${YELLOW}Step 3/4: Installing Node.js (22.x) and Yarn...${RESET}"
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs

echo -e "${YELLOW}Trying to install Yarn globally (sudo npm install -g yarn)...${RESET}"
if ! sudo npm install -g yarn; then
  echo -e "${YELLOW}Warning:${RESET} yarn install failed, lekin npm installed hai, script continue karega."
fi

echo -e "${YELLOW}Step 4/4: Cloning RL-Swarm and creating start script...${RESET}"
cd ~

if [ -d "rl-swarm" ]; then
    echo -e "${RED}Directory 'rl-swarm' already exists. Deleting old copy...${RESET}"
    rm -rf rl-swarm
fi

git clone https://github.com/gensyn-ai/rl-swarm
cd rl-swarm

echo -e "${YELLOW}Creating Python virtual environment...${RESET}"
python3 -m venv .venv
source .venv/bin/activate || . .venv/bin/activate

echo -e "${YELLOW}Creating start_swarm_cpu.sh...${RESET}"
cat > start_swarm_cpu.sh << 'EOF'
#!/usr/bin/env bash

cd "$(dirname "$0")"

python3 -m venv .venv
source .venv/bin/activate || . .venv/bin/activate

SESSION="swarm"

if screen -list | grep -q "$SESSION"; then
    echo "Swarm already running. Attach using: screen -r swarm"
    exit 0
fi

echo "Starting RL-Swarm (CPU mode) inside screen session..."

screen -dmS $SESSION bash -c "
echo 'Launching RL-Swarm CPU node...'
sleep 2
./run_rl_swarm.sh
echo
echo 'RL-Swarm stopped. Press ENTER to close.'
read
"
echo "Started! Attach via: screen -r swarm"
EOF

chmod +x start_swarm_cpu.sh

echo -e "${GREEN}${BOLD}"
echo "============================================"
echo " INSTALLATION COMPLETE (CPU-ONLY MODE)!"
echo " RL-SWARM READY TO USE AFTER REBOOT"
echo "============================================"
echo -e "${RESET}"

echo -e "${YELLOW}System reboot ho raha hai 5 seconds me...${RESET}"
sleep 5
sudo reboot
