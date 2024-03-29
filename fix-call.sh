#!/bin/bash

clear
udpport=7300
echo -e "\ninput UDPGW Port :"
printf "Default Port is \e[33m${udpport}\e[0m, let it blank to use this Port: "
read udpport

apt update -y
apt install git cmake -y

git clone https://github.com/Vahid-Spacer/badvpn /root/spacer

mkdir /root/spacer/badvpn-build

cd  /root/spacer/badvpn-build

cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &
wait
make &
wait

cp udpgw/badvpn-udpgw /usr/local/bin

cat >  /etc/systemd/system/videocall.service << ENDOFFILE
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:${udpport} --max-clients 999
User=videocall

[Install]
WantedBy=multi-user.target
ENDOFFILE

useradd -m videocall
systemctl enable videocall
systemctl start videocall

