sudo passwd root

echo "192.168.254.158 proxmox.local debian" >> /etc/hosts

echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg 

sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg 
### 7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87

apt update && apt full-upgrade -y

apt install proxmox-default-kernel

systemctl reboot

apt install proxmox-ve postfix open-iscsi chrony -y

apt remove linux-image-amd64 'linux-image-6.1*' -y

## re-add windows to grub > false
# vi /etc/default/grub.d/proxmox-ve.cfg

# nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"

# nano /etc/modules
# vfio
# vfio_iommu_type1
# vfio_pci
# vfio_virqfd

# echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
# echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf

# echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
# echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
# echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf

# echo "options vfio-pci ids=10de:2206,10de:1aef disable_vga=1"> /etc/modprobe.d/vfio.conf
# update-initramfs -u

echo "UPDATE PROXMOX"
apt update && apt upgrade -y
apt install ipmitool -y


# =================================================================================================
# Create Fan Cron Job
#
echo "ADDING POWER MAN CRON JOB"
crontab -l > mycron
echo "* * * * * /bin/bash /root/power-man.sh >> /var/log/power-man.log 2&>1" >> mycron
crontab mycron
rm mycron


# =================================================================================================
# Configure IOMMU
echo "CONFIGURE IOMMU"
SEARCH="GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\""
REPLACE="GRUB_CMDLINE_LINUX_DEFAULT=\"quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off\""
sed -i 's/$SEARCH/$REPLACE/' /etc/default/grub
update-grub


# =================================================================================================
# Passthrough GPU
echo "Handling VFIO"
echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules

echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf


# =================================================================================================
# Get Vendor IDs for NVIDIA GPUs
echo "Handling GPU VENDORS"
lspci > "pci_devices.txt"
grep NVIDIA pci_devices.txt > gpu_match.txt
grep -o "[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]" gpu_match.txt > gpu_extract.txt

cat < gpu_id_codes.txt

# Grab the PCIe Number
while IFS= read -r line; do
    lspci -n -s $line | awk '{print $3}' >> gpu_id_codes.txt
done < gpu_extract.txt

# Eliminate identical entries
sort gpu_id_codes.txt|uniq > output.txt

# Now add them to the options
OPTIONS=""

while IFS= read -r line; do
        if [ -z "$OPTIONS" ]; then
                OPTIONS="${line}"
        else
                OPTIONS="${OPTIONS},${line}"
        fi
done < output.txt

echo "options vfio-pci ids=${OPTIONS} disable_vga=1"> /etc/modprobe.d/vfio.conf

rm output.txt
rm gpu_id_codes.txt
rm gpu_extract.txt
rm gpu_match.txt
rm pci_devices.txt

echo update-initramfs -u
reboot now


update-grub


bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"

## configure vmbr0 
# IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | grep '^192.168.254') && \
# GW=$(ip route | grep default | awk '{print $3}') && \
# IFACE=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}') && \
# sudo tee /etc/network/interfaces.d/vmbr0 > /dev/null <<EOF
# auto vmbr0
# iface vmbr0 inet static
#     address $IP
#     gateway $GW
#     bridge-ports $IFACE
#     bridge-stp off
#     bridge-fd 0
# EOF 


curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=tskey-auth-kqjhqwQSLc11CNTRL-MFPUA1sPPEYJrdZToDsg9YiHFd3kEnbY --advertise-exit-node


# host
sudo mkdir /mnt/ntfs
apt install ntfs-3g -y
mount -t ntfs-3g /dev/nvme0n1p4 /mnt/ntfs
# datacenter > directory mappings > ntfs + /mnt/ntfs

# guest
# hardware > add virtiofs > ntfs
sudo mkdir /mnt/ntfs
sudo mount -t virtiofs ntfs /mnt/ntfs
