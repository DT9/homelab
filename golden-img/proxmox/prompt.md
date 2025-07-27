Generate a complete Packer JSON template to build a custom Debian 12 netinst ISO that automates installation with a preseed file and installs Proxmox VE. 

Requirements:
- Use the official Debian 11 netinst ISO as the base.
- Automate the Debian install with a preseed configuration served over HTTP by Packer.
- Include a preseed.cfg file that sets hostname to "proxmox-node", sets root password, partitions with LVM, uses automatic installation, and disables interactive prompts.
- Use the preseed late_command to download and execute a post-install shell script.
- The post-install shell script should add the Proxmox VE repository, import its GPG key, update apt, install "proxmox-ve", "postfix", and "open-iscsi", and enable the necessary systemd services.
- The Packer template should mount the ISO, boot with auto-install parameters pointing to the preseed file, and shut down cleanly after installation.
- Include SSH access configured with username root and password "yourpassword" for provisioning.
- Provide separate files named "preseed.cfg" and "post-install.sh" with the described contents.

Output the Packer JSON template, the preseed.cfg content, and the post-install.sh script with appropriate comments.


---

Generate a complete Packer JSON template to build a custom Debian 12 netinst ISO that automates installation with a preseed file and installs Proxmox VE.

Requirements:
- Use the official Debian 12 netinst ISO as the base.
- Automate the Debian install with a preseed configuration served over HTTP by Packer.
- Include a preseed.cfg file that:
  - Sets hostname to "proxmox-node".
  - Sets root password securely via Packer variables (do not hardcode).
  - Partitions with LVM and uses automatic installation.
  - Disables interactive prompts.
  - Enables unattended security upgrades.
  - Configures SSH for key-based authentication and disables root password login.
  - Includes firewall setup to allow only SSH and Proxmox GUI ports.
- Use the preseed late_command to download and execute a post-install shell script.
- The post-install shell script should:
  - Add the Proxmox VE repository and import its GPG key.
  - Update apt and install "proxmox-ve", "postfix", and "open-iscsi".
  - Enable necessary systemd services.
  - Configure Proxmox to enforce 2FA on the web GUI.
  - Set up SSL certificates using Let’s Encrypt or self-signed certs.
  - Harden SSH by disabling password authentication and restricting allowed users.
  - Enable and configure UFW firewall to restrict traffic.
- The Packer template should mount the ISO, boot with auto-install parameters pointing to the preseed file, and shut down cleanly after installation.
- Include SSH access configured with username root and SSH key injected securely using Packer variables.
- Provide separate files named "preseed.cfg" and "post-install.sh" with the described contents.
- Use Packer variables to avoid hardcoded secrets and facilitate secure deployment.

Output the Packer JSON template, the preseed.cfg content, and the post-install.sh script with appropriate comments emphasizing security features.
