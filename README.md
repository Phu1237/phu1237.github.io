# phu1237.github.io

## Fast initialization your Ubuntu server

```bash
wget -O install.sh https://phu1237.github.io/ubuntu-init.sh
sudo bash install.sh -p <ssh_port> -r <new_root_password> -O -a <ols_admin_password> -s <virtual_host_name>
sudo rm install.sh
```

Arguments:
- `-p`: your new SSH port
- `-r`: your new root password
- `-b`: bash aliases
- `-O`: install OpenLiteSpeed
  - `-a`: OpenLiteSpeed admin password
  - `-s`: Virtual hostname

For example

```bash
wget -O install.sh https://phu1237.github.io/ubuntu-init.sh
sudo bash install.sh -r 12345678 -O -a 12345678 -s example.com
sudo rm install.sh
```
