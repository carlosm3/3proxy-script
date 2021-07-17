#!/bin/bash
apt-get update;apt-get upgrade -y;apt-get autoremove -y;apt-get autoclean -y
apt-get install fail2ban software-properties-common -y;apt-get install build-essential libevent-dev libssl-dev -y
apt-get install ufw
cd /usr/local/etc
wget https://github.com/z3APA3A/3proxy/archive/0.8.12.tar.gz
tar zxvf 0.8.12.tar.gz
rm 0.8.12.tar.gz
mv 3proxy-0.8.12 3proxy
cd 3proxy
make -f Makefile.Linux
make -f Makefile.Linux install
mkdir log
cd cfg
rm 3proxy.cfg.sample
username=$(head /dev/urandom|tr -dc A-Za-z0-9|head -c 8);password=$(head /dev/urandom|tr -dc A-Za-z0-9|head -c 8)
echo "#!/usr/local/bin/3proxy
daemon

pidfile /usr/local/etc/3proxy/3proxy.pid

nserver 1.1.1.1
nserver 1.0.0.1

nscache 65536

timeouts 1 5 30 60 180 1800 15 60

users $username:CL:$password

log /usr/local/etc/3proxy/log/3proxy.log D

logformat \"- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T\"

archiver rar rar a -df -inul %A %F

rotate 30

internal 0.0.0.0
external 0.0.0.0

authcache ip 60

auth strong
allow $username

proxy -p3130 -a -n
" >> /usr/local/etc/3proxy/cfg/3proxy.cfg
chmod 700 3proxy.cfg
sed -i '14s/.*/       \/usr\/local\/etc\/3proxy\/cfg\/3proxy.cfg/' /usr/local/etc/3proxy/scripts/rc.d/proxy.sh
echo "#!/bin/bash
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start
exit 0
" >> /etc/rc.local
sudo chmod +x /etc/rc.local
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow out 53
sudo ufw allow out http
sudo ufw allow out https
sudo ufw limit in ssh
sudo ufw allow 3130
echo "y" | sudo ufw enable
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start
PUBLIC_IP=$(curl -s eth0.me)
printf "\n"
printf "==========================================================\n"
printf "        Proxy: $username:$password@$PUBLIC_IP:3130        \n"
printf "==========================================================\n"
printf "\n"