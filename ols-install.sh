echo "Updating Ubuntu..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
apt autoremove -y > /dev/null 2>&1
echo "Done!"
echo "Set Timezone to Asia/Ho_Chi_Minh"
timedatectl set-timezone Asia/Ho_Chi_Minh > /dev/null 2>&1
echo "Set root password"
(echo $1; echo $1;) | passwd root > /dev/null 2>&1
# passwd root
echo "Installing Google Authenticator..."
apt install libpam-google-authenticator -y > /dev/null 2>&1
google-authenticator -t -C -d -f --rate-limit=3 --rate-time=30 --window-size=1
echo "Done!"
echo "Installing Fail2ban..."
apt install fail2ban -y > /dev/null 2>&1
systemctl enable --now fail2ban > /dev/null 2>&1
echo "Coping /etc/fail2ban/jail.conf to /etc/fail2ban/jail.local"
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local > /dev/null 2>&1
echo "Done!"
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
  tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "> Installing Docker Engine..."
apt-get update > /dev/null 2>&1
apt-get remove docker docker-engine docker.io containerd runc -y > /dev/null 2>&1
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y > /dev/null 2>&1
echo "Done!"
echo "Cloning OpenLiteSpeed Docker..."
git clone https://github.com/Phu1237/ols-docker-env.git > /dev/null 2>&1
echo "Done!"
cd ols-docker-env
echo "Setting up OpenLiteSpeed..."
docker compose up -d > /dev/null 2>&1
echo "Done!"
bash bin/webadmin.sh -M enable > /dev/null 2>&1
bash bin/webadmin.sh 8tjNWjmM > /dev/null 2>&1
echo "OpenLiteSpeed information:"
echo "> URL: http://IP:7080"
echo "> User Name: admin"
echo "> Password: $2"
bash bin/domain.sh -m $3
cd ~
