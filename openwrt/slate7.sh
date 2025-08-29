# setup pw
# tether one-click

# zerotier join 6ab565387a9084c1
# tailscale

# ssh
vi /Users/dennis.truong/.ssh/known_hosts
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.8.1
ssh root@192.168.8.1

# pxe - manual
wget http://boot.netboot.xyz/ipxe/netboot.xyz.efi
wget "https://github.com/DT9/homelab/raw/refs/heads/master/ipxe/MAC-9c-6b-00-93-c0-56.ipxe?$(date +%s)"
cat /root/MAC-9c-6b-00-93-c0-56.ipxe
wget -O /www/preseed.cfg "https://github.com/DT9/homelab/raw/refs/heads/master/ipxe/preseed.cfg?$(date +%s)"
cat /www/preseed.cfg
uci set dhcp.@dnsmasq[0].enable_tftp='1' && uci set dhcp.@dnsmasq[0].tftp_root='/root' && uci set dhcp.@dnsmasq[0].dhcp_boot='netboot.xyz.efi' && uci commit dhcp && /etc/init.d/dnsmasq restart

# fan set 70

# adguard

# dhcp/subnet 10.10.0.1/16

# repeater failover

# wan to lan: bridge br-lan + eth0 > turn off > port change

curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join 6ab565387a9084c1

curl -fsSL https://tailscale.com/install.sh | sh