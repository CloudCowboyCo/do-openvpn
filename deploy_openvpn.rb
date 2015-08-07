require './droplet_deploy.rb'
require 'droplet_kit'
require './ip_info.rb'
require './userdata_openvpn.rb'
require 'pry'
@token=''
systemInfo = {"name" => "openVPN"+rand(1000).to_s, "region" => "nyc3", "size" => "1gb", "image" => "ubuntu-14-04-x64", "user_data" => userdata_openvpn(), "ssh_keys" => ['982252']}
ip_public = deploy_droplet(systemInfo)
puts "time to sleep so everything can be generted properly"
sleep(60)

#{}`ssh -o StrictHostKeyChecking=no root@#{ip_public[0]}`
`scp -o StrictHostKeyChecking=no root@#{ip_public[0]}:/etc/openvpn/easy-rsa/keys/user1.crt /home/joshua/openvpn/`
`scp -o StrictHostKeyChecking=no root@#{ip_public[0]}:/etc/openvpn/easy-rsa/keys/user1.key /home/joshua/openvpn/`
`scp -o StrictHostKeyChecking=no root@#{ip_public[0]}:/etc/openvpn/easy-rsa/keys/ca.crt /home/joshua/openvpn/`
`tempbro=$(cat /home/joshua/openvpn/client.conf) && echo $tempbro | grep -v 1194 >/home/joshua/openvpn/client.conf`
`echo "remote #{ip_public[0]} 1194" > client.conf`
binding.pry
`sudo openvpn /home/joshua/openvpn/client.conf`
