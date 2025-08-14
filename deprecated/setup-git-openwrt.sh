
ln -s /tmp/mountd/disk2_part1/debian /www/ipxe

# repo sparse
opkg install git openssh-keygen	openssh-client	

ssh-keygen -t ed25519 -C "dtruong1@ualberta.ca"
cat ~/.ssh/id_ed25519.pub # add this to the github repo

cd /tmp/mountd/disk2_part1/homelab
git init
git remote add origin git@github.com:DT9/homelab.git
git config core.sparseCheckout true
echo "ipxe" >> .git/info/sparse-checkout
git pull origin main

# update only the files that are in the sparse checkout
#git read-tree -mu HEAD 


# methods to ipxe boot
1. usb eg. ventoy
2. local network eg. dnsmasq, tinkerbell smee
3. remote network eg. dhcprelay > tinkerbell
3. partition boot eg. grub / refind



wget https://boot.ipxe.org/ipxe.efi


kubectl delete daemonset kubernetes-zerotier-bridge -n kube-system