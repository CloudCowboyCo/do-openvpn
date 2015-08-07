def userdata_openvpn()
return <<-EOM
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive;
export PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
export PRIVATE_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
#Install OpenVPN
apt-get update
apt-get install -y openvpn
apt-get install -y easy-rsa
#Generate Server Certificates
cp -r /usr/share/easy-rsa /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
mkdir keys
source ./vars
./clean-all
./pkitool --batch --initca
./pkitool --batch --server server
./build-dh
openssl dhparam -out /etc/openvpn/dh1024.pem 2048
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/ca.key /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn
cd /etc/openvpn/easy-rsa
source ./vars
./pkitool --batch user1

#add user/group openvpn
adduser --system --no-create-home --disabled-login openvpn
addgroup --system --no-create-home --disabled-login openvpn
#copy configuration files / unpack them
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gunzip /etc/openvpn/server.conf.gz
cd /etc/openvpn

#Configure aspects of the VPN server
echo "user openvpn" >> server.conf
echo "group openvpn" >> server.conf
echo 'push "redirect-gateway def1"' >> server.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j SNAT --to $PUBLIC_IP
service openvpn restart
EOM
end