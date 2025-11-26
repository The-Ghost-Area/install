#!/bin/bash

echo "=============================="
echo " GENSYN RL-SWARM SETUP START "
echo "=============================="

# 1. System Update
sudo apt update && sudo apt upgrade -y

# 2. Install Required Packages
sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

# 3. Install Python
sudo apt install python3 python3-pip python3-venv python3-dev -y

# 4. Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs

# 5. Install Yarn
sudo npm install -g yarn

# 6. Clone RL-SWARM repo if not exists
cd ~
if [ ! -d "rl-swarm" ]; then
  git clone https://github.com/gensyn-ai/rl-swarm.git
fi

# 7. Create Screen Session
screen -dmS gensyn bash -c '

cd ~/rl-swarm

# Create Python venv
python3 -m venv .venv

# Activate venv
source .venv/bin/activate

# Run RL Swarm
./run_rl_swarm.sh

exec bash
'

echo "======================================"
echo " ✅ RL-SWARM Screen session started"
echo " Screen name : gensyn"
echo " To attach   : screen -r gensyn"
echo "======================================"
