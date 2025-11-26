#!/bin/bash

echo "=============================="
echo " GENSYN RL-SWARM SETUP START "
echo "=============================="

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Ensure curl is installed
if ! command -v curl &> /dev/null
then
    echo "curl not found, installing..."
    sudo apt install -y curl
else
    echo "curl already installed ✅"
fi

# 3. Install Required Packages
sudo apt install screen iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

# 4. Install Python
sudo apt install python3 python3-pip python3-venv python3-dev -y

# 5. Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs

# 6. Install Yarn
sudo npm install -g yarn

# 7. Clone RL-SWARM repo if not exists
cd ~
if [ ! -d "rl-swarm" ]; then
  git clone https://github.com/gensyn-ai/rl-swarm.git
fi

# 8. Start screen session and run RL-SWARM inside it
screen -dmS gensyn bash -c '
cd ~/rl-swarm

python3 -m venv .venv
source .venv/bin/activate

./run_rl_swarm.sh

exec bash
'

echo "======================================"
echo " ✅ RL-SWARM Screen session started"
echo " Screen name : gensyn"
echo " To attach   : screen -r gensyn"
echo "======================================"
