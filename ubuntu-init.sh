#!/bin/bash

root_password=""
admin_password=123456
site=""
port=22
bash_aliases=""
install_ols=""
# Get the options
while getopts "p:r:Oa:s:" option; do
    case $option in
        p) # SSH Port
            port=$OPTARG;;
        r) # Root password
            root_password=$OPTARG;;
        b) # Bash aliases
            bash_aliases=1;;
        O) # Install OpenLiteSpeed
            install_ols=1;;
        a) # OpenLiteSpeed admin password
            admin_password=$OPTARG;;
        s) # Init site for OpenLiteSpeed
            site=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

echo "Updating Ubuntu..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
apt autoremove -y > /dev/null 2>&1
echo "Done!"

# Timezone
echo "Set Timezone to Asia/Ho_Chi_Minh"
timedatectl set-timezone Asia/Ho_Chi_Minh > /dev/null 2>&1

# Root password
if [[ ! -z "$root_password" ]]
then
  echo "Set root password"
  (echo $root_password; echo $root_password;) | passwd root > /dev/null 2>&1
fi

# Google Authenticator
echo "Installing Google Authenticator..."
apt install libpam-google-authenticator -y > /dev/null 2>&1
google-authenticator -t -C -d -f --rate-limit=3 --rate-time=30 --window-size=1
echo "Done!"

# Fail2ban
echo "Installing Fail2ban..."
apt install fail2ban -y > /dev/null 2>&1
systemctl enable --now fail2ban > /dev/null 2>&1
echo "Done!"

# Time sync
echo "Installing Time sync..."
apt install ntp -y > /dev/null 2>&1
sudo systemctl enable --now ntp > /dev/null 2>&1
echo "Done!"

# Config files
echo "Inject config files!"
ufw deny 22/tcp > /dev/null 2>&1
ufw allow $port/tcp > /dev/null 2>&1
wget -O /etc/ssh/sshd_config https://phu1237.github.io/ubuntu-init/sshd_config > /dev/null 2>&1
wget -O /etc/fail2ban/jail.local https://phu1237.github.io/ubuntu-init/jail.local > /dev/null 2>&1
wget -O /etc/pam.d/sshd https://phu1237.github.io/ubuntu-init/sshd > /dev/null 2>&1
sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config > /dev/null 2>&1
systemctl restart sshd > /dev/null 2>&1
echo "Done!"

# Docker
echo "Installing Docker..."
echo "> Set up the repository"
apt-get install \
    ca-certificates \
    curl \
    gnupg > /dev/null 2>&1
install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
chmod a+r /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null 2>&1
echo "> Installing Docker Engine..."
apt-get update > /dev/null 2>&1
apt-get remove docker docker-engine docker.io containerd runc -y > /dev/null 2>&1
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y > /dev/null 2>&1
echo "Done!"

# Bash aliases
if [[ ! -z "$bash_aliases" ]]
then
    echo "Inject bash alliases!"
    wget -O ~/.bash_aliases https://phu1237.github.io/ubuntu-init/bash_aliases > /dev/null 2>&1
    source ~/.bashrc > /dev/null 2>&1
    source ~/.bash_aliases > /dev/null 2>&1
    echo "Done!"
fi

# OpenLiteSpeed
if [[ ! -z "$install_ols" ]]
then
    echo "Cloning OpenLiteSpeed Docker..."
    git clone https://github.com/Phu1237/ols-docker-env.git > /dev/null 2>&1
    echo "Done!"
    cd ols-docker-env
    echo "Setting up OpenLiteSpeed..."
    docker compose up -d > /dev/null 2>&1
    echo "Done!"
    echo "Deleting Example virtual host files..."
    docker exec -it ols-docker-env-litespeed-1 bash -c "cd /usr/local/lsws && rm -rf Example && rm -rf conf/vhost/Example" > /dev/null 2>&1
    echo "Done!"
    bash bin/webadmin.sh -M enable > /dev/null 2>&1
    bash bin/webadmin.sh $admin_password > /dev/null 2>&1
    echo -------------------------------------------------
    echo "Server information"
    echo "> SSH port number: $port"
    echo "> User: root"
    if [[ ! -z "$root_password" ]]
    then
    echo "> Password: $root_password"
    else
    echo "> Password: Your current password"
    fi
    echo "OpenLiteSpeed information:"
    echo "> URL: http://IP:7080"
    echo "> User Name: admin"
    echo "> Password: $admin_password"
    if [[ ! -z "$site" ]]
    then
    echo "OpenLiteSpeed Virtual Host information:"
    echo "> Virtual Host name: $site"
    bash bin/domain.sh -m $site
    fi
    cd ~
fi
