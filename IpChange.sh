#!/bin/bash
# HCR SQUAD 42 - Auto Install Script

# -------------------------------
# 🎨 HCR SQUAD 42
# -------------------------------
clear
echo -e "\e[31m┌───────────────────────────────────────┐\e[0m"
echo -e "\e[31m│         \e[0m  \e[31mFOR\e[0m HCR SQUAD 42      \e[31m│\e[0m"
echo -e "\e[31m└───────────────────────────────────────┘\e[0m"
echo ""

# -------------------------------
# 1️⃣ Update and Install Packages
# -------------------------------
echo -e "\e[1;33m[+] Updating & Upgrading Termux Packages...\e[0m"
pkg update -y && pkg upgrade -y

echo -e "\e[1;33m[+] Installing tur-repo & Required Packages...\e[0m"
pkg install tur-repo -y
pkg install tor privoxy netcat-openbsd curl -y

# -------------------------------
# 2️⃣ Setup Environment
# -------------------------------
echo -e "\e[1;32m[+] Setting Up Tor and Privoxy Configuration...\e[0m"
pkill tor
pkill privoxy
rm -rf ~/.tor_multi ~/.privoxy
mkdir -p ~/.tor_multi ~/.privoxy

# -------------------------------
# 3️⃣ Start Tor and Privoxy Services
# -------------------------------
echo -e "\e[1;34m[+] Launching Tor Nodes & Proxy Server...\e[0m"
PORTS=(9050 9060 9070 9080 9090)
CONTROL_PORTS=(9051 9061 9071 9081 9091)

for i in {0..4}; do
    TOR_DIR="$HOME/.tor_multi/tor$i"
    mkdir -p "$TOR_DIR"
    cat <<EOF > "$TOR_DIR/torrc"
SocksPort ${PORTS[$i]}
ControlPort ${CONTROL_PORTS[$i]}
DataDirectory $TOR_DIR
CookieAuthentication 0
EOF
    tor -f "$TOR_DIR/torrc" > /dev/null 2>&1 &
    sleep 2
done

# Privoxy Setup
cat <<EOF > "$HOME/.privoxy/config"
listen-address 127.0.0.1:8118
EOF
for port in "${PORTS[@]}"; do
    echo "forward-socks5 / 127.0.0.1:$port ." >> "$HOME/.privoxy/config"
done

privoxy "$HOME/.privoxy/config" > /dev/null 2>&1 &

# -------------------------------
# 4️⃣ IP Rotation Time Interval
# -------------------------------
echo -ne "\e[1;36mEnter IP rotation interval (in seconds, min 5s): \e[0m"
read -r ROTATION_TIME

if [[ ! "$ROTATION_TIME" =~ ^[0-9]+$ ]] || [[ "$ROTATION_TIME" -lt 5 ]]; then
    echo -e "\e[1;31mInvalid input! Using default 10 seconds.\e[0m"
    ROTATION_TIME=10
fi

# -------------------------------
# 5️⃣ Auto IP Changer Loop
# -------------------------------
while true; do
    for ctrl_port in "${CONTROL_PORTS[@]}"; do
        echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" | nc 127.0.0.1 $ctrl_port > /dev/null 2>&1
    done
    NEW_IP=$(curl --proxy http://127.0.0.1:8118 -s https://api64.ipify.org)
    echo -e "\e[1;32m🌐 New IP: $NEW_IP ✅\e[0m"
    echo -e "\e[1;34m[Proxy]: 127.0.0.1:8118 🛰️\e[0m"
    sleep "$ROTATION_TIME"
done




# Padding Start
: '
.......................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
