#!/bin/bash


blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
bred(){
    echo -e "\033[31m\033[01m\033[05m$1\033[0m"
}
byellow(){
    echo -e "\033[33m\033[01m\033[05m$1\033[0m"
}

architecture=""
case $(uname -m) in
    x86_64)  architecture="amd64" ;;
    aarch64)  architecture="arm64" ;;
esac


function install_smartpi(){

if [[ $architecture = "amd64" ]]; then
cp /etc/apt/sources.list /etc/apt/sources.list.bak
rm -rf /etc/apt/sources.list

cat > /etc/apt/sources.list << EOF
deb http://mirrors.163.com/debian buster main
deb-src http://mirrors.163.com/debian buster main
deb http://mirrors.163.com/debian-security/ buster/updates main
deb-src http://mirrors.163.com/debian-security/ buster/updates main
deb http://mirrors.163.com/debian buster-updates main
deb-src http://mirrors.163.com/debian buster-updates main
EOF
fi

apt-get -y update
apt -y install curl
wget https://github.com/pymumu/smartdns/releases/download/Release42/smartdns.1.2023.05.07-1641.x86_64-linux-all.tar.gz
tar zxf smartdns.1.2023.05.07-1641.x86_64-linux-all.tar.gz
cd smartdns
chmod +x ./install
./install -i
rm -rf /etc/smartdns/smartdns.conf
cat > /etc/smartdns/smartdns.conf <<-EOF

bind [::]:5599

cache-size 512

prefetch-domain yes

rr-ttl 300
rr-ttl-min 60
rr-ttl-max 86400

log-level info
log-file /var/log/smartdns.log
log-size 128k
log-num 2

server 202.96.64.68
server 202.96.69.38
server 119.29.29.29
server 223.5.5.5
server-tcp 202.96.64.68
server-tcp 202.96.69.38
server-tcp 119.29.29.29
server-tcp 223.5.5.5
server-tls 8.8.8.8
server-tls 8.8.4.4

EOF

cp /etc/smartdns/smartdns.conf /etc/smartdns/smartdns.conf.bak

systemctl enable smartdns
systemctl start smartdns

curl -sSL https://install.pi-hole.net | bash

sed -i '/PIHOLE_DNS/d' /etc/pihole/setupVars.conf
sed -i '$a PIHOLE_DNS_1=127.0.0.1#5599' /etc/pihole/setupVars.conf
sed -i '/DNSMASQ_LISTENING/d' /etc/pihole/setupVars.conf
sed -i '$a DNSMASQ_LISTENING=local' /etc/pihole/setupVars.conf

rm -rf /etc/resolv.conf

cat > /etc/resolv.conf << EOF
nameserver 119.29.29.29
nameserver 223.5.5.5
nameserver 180.76.76.76
EOF

pihole restartdns > /dev/null 2>&1
	green " ===========================请重启debian系统=============================="
	green " SmartPi安装完成"
    green " 系统：>=debian12"
	green " ===========================请重启debian系统=============================="

}

function update_smartdns(){
if test -s /etc/smartdns/smartdns.conf.bak; then
	rm -rf /etc/smartdns/smartdns.conf.bak
	cp /etc/smartdns/smartdns.conf /etc/smartdns/smartdns.conf.bak
	./install -u
	rm -rf /root/smartdns*
fi
wget https://github.com/pymumu/smartdns/releases/download/Release42/smartdns.1.2023.05.07-1641.x86_64-linux-all.tar.gz
tar zxf smartdns.1.2023.05.07-1641.x86_64-linux-all.tar.gz
cd smartdns
chmod +x ./install
./install -i
if test -s /etc/smartdns/smartdns.conf.bak; then
	rm -rf /etc/smartdns/smartdns.conf
	cp /etc/smartdns/smartdns.conf.bak /etc/smartdns/smartdns.conf
fi
systemctl enable smartdns
systemctl restart smartdns
pihole restartdns
	green " ===========================请重启debian系统=============================="
	green " SmartPi更新完成"
    green " 系统：>=debian12"

	green " ===========================请重启debian系统=============================="
}

function m_pass(){
    red " =================================="
    red " 修改pi-hole密码"
    red " =================================="
    pihole -a -p
    red " =================================="
    red " pi-hole密码修改完成"
    red " =================================="
}

function rebuil_pi-hole(){
    green " ================================"
    green " 开始重新安装pi-hole"
    green " ================================"
    pihole -r
    green " ================================"
    green " pi-hole安装完成"
    green " ================================"
}

start_menu(){
    clear
    green " ========================================================================"
    green " 简介：debian一键安装SmartPi"
    green " 系统：>=debian12"
    green " ========================================================================"
    echo
    green  " 1. 一键安装SmartPi"
	green  " 2. 一键更新SmartPi"
	green  " 3. 重新安装pi-hole"
	green  " 4. 更改pi-hole密码"
    yellow " 0. 退出脚本"
    echo
    read -p " 请输入数字:" num
    case "$num" in
    1)
    install_smartpi
    ;;
    2)
    update_smartdns
    ;;
	3)
    rebuil_pi-hole 
    ;;
	4)
    m_pass 
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "输入的数字不正确，请重新输入"
    sleep 1s
    start_menu
    ;;
    esac
}

start_menu
