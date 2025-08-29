# Proxmox Configuration Enhancement Plan - Pseudo Code

## Overview
This document provides detailed pseudo code for enhancing the Proxmox VE configuration across 5 key phases.


## Phase 2: Storage & Backup Configuration

### 2.1 Configure Backup Storage: Proxmox Backup Server (PBS) - True Incrementals

**PBS Benefits:**
- **True incremental backups** with deduplication
- **Version history** with point-in-time recovery
- **Encryption** and compression built-in
- **Web interface** for backup management
- **Much smaller storage footprint** than full snapshots

```pseudocode
FUNCTION configure_backup_storage():
    // File: group_vars/all/main.yml
    // Configure PBS storage backend
    pve_storages:
        - name: "pbs-backup"
          type: "pbs"
          server: "pbs.local"           // PBS server hostname/IP
          datastore: "backup-store"     // PBS datastore name
          content: ["backup"]
          username: "proxmox@pbs"       // PBS user account
          password: "{{ vault_pbs_password }}"  // From vault
          fingerprint: "{{ vault_pbs_fingerprint }}"  // PBS certificate fingerprint
          
    // File: group_vars/pve01/vault.yml
    ADD PBS credentials:
        vault_pbs_password: "your_pbs_user_password"
        vault_pbs_fingerprint: "SHA256:your_pbs_server_fingerprint"
        
    MANUAL PBS SETUP REQUIRED:
        1. Install PBS on separate system/VM:
           - Download PBS ISO from Proxmox
           - Install on dedicated hardware/VM
           - Configure datastore and user accounts
        2. Get PBS fingerprint: pvecm expected-fingerprint
        3. Create backup user in PBS web interface
        4. Test connection from Proxmox
END FUNCTION
```

### 2.2 Configure Additional Storage: Single Disk + LVM-Thin Primary

**Single disk setup - configure LVM-Thin as main VM storage:**

```pseudocode
FUNCTION configure_additional_storage():
    // File: group_vars/all/main.yml
    ADD to pve_storages:
        
    ISO Storage:
        - name: "iso-storage"
          type: "dir"
          path: "/var/lib/vz/template/iso"
          content: ["iso"]
          maxfiles: 10
          
    Container Templates:
        - name: "vztmpl-storage"
          type: "dir" 
          path: "/var/lib/vz/template/cache"
          content: ["vztmpl"]
          
    IF multiple_disks_available THEN:
        ZFS Pool Configuration:
            pve_zfs_enabled: true
            pve_zfs_pools:
                - name: "rpool"
                  devices: ["/dev/sdb", "/dev/sdc"]
                  raidlevel: "mirror"
    END IF
END FUNCTION
```

### 2.3 Automated PBS Backup Configuration: True Incrementals with Deduplication

**PBS Backup Features:**
- **Incremental**: Only changed blocks are transferred
- **Deduplication**: Identical data blocks stored once
- **Encryption**: Client-side encryption before transmission
- **Retention**: Flexible keep policies (daily/weekly/monthly/yearly)

```pseudocode
FUNCTION configure_automated_backups():
    // File: group_vars/pve01/monitoring.yml
    CONFIGURE PBS backup jobs:
        
    pve_backup_jobs:
        - id: "daily-pbs-backup"
          schedule: "02:00"  // 2 AM daily
          storage: "pbs-backup"  // PBS storage configured above
          retention:
            keep_last: 7       // Keep last 7 backups
            keep_daily: 14     // Keep daily for 2 weeks
            keep_weekly: 8     // Keep weekly for 2 months
            keep_monthly: 12   // Keep monthly for 1 year
            keep_yearly: 3     // Keep yearly for 3 years
          nodes: ["{{ inventory_hostname }}"]
          mode: "snapshot"     // Consistent snapshots
          compress: true       // PBS handles compression
          encrypt: true        // Client-side encryption
          notes: "Daily incremental backup to PBS"
          
        // Optional: Separate job for critical VMs
        - id: "critical-vm-backup"
          schedule: "*/4 * * *"  // Every 4 hours
          storage: "pbs-backup"
          vmid: [100, 101, 102]  // Specify critical VM IDs
          retention:
            keep_last: 24      // Keep last 24 (4-hour intervals)
            keep_daily: 7
          notes: "Critical VMs - 4-hourly backup"
    
    PBS ADVANTAGES:
        - First backup = full size
        - Subsequent backups = only changed blocks
        - 90%+ space savings typical
        - Fast incremental backups (minutes, not hours)
        - Point-in-time file-level recovery
END FUNCTION
```

### 2.4 PBS Installation and Setup (Manual Prerequisites)

**PBS requires separate installation - cannot be automated via Ansible:**

```pseudocode
MANUAL PBS SETUP PROCESS:
    
    OPTION 1 - Dedicated Hardware/VM:
        1. Download PBS ISO from proxmox.com
        2. Install on separate system (minimum 2GB RAM, 32GB disk)
        3. Configure network and storage during installation
        4. Access web interface: https://pbs-server:8007
        
    OPTION 2 - LXC Container on Proxmox:
        1. Create privileged LXC container (Ubuntu/Debian)
        2. Add PBS repository and install packages
        3. Configure datastore and certificates
        
    PBS INITIAL CONFIGURATION:
        1. Create datastore: /backup (or external mount)
        2. Create backup user account: proxmox@pbs
        3. Generate API token or set user password
        4. Note PBS server certificate fingerprint
        5. Configure retention policies
        6. Test backup/restore functionality
        
    INTEGRATION TESTING:
        1. Add PBS storage in Proxmox web UI
        2. Run test backup job manually
        3. Verify backup appears in PBS interface
        4. Test restore procedure
        5. Monitor PBS logs and disk usage
END MANUAL SETUP
```

---

## Phase 3: Monitoring & Notifications

### 3.1 Basic Monitoring Setup. 

```pseudocode
FUNCTION configure_monitoring():
    // File: group_vars/pve01/monitoring.yml
    UNCOMMENT AND CONFIGURE:
        
    InfluxDB Integration:
        pve_metric_servers:
            - id: "influxdb-main"
              server: "monitoring.local"  // Replace with actual server
              port: 8086
              type: "influxdb"
              token: "{{ vault_influxdb_token }}"
              organization: "homelab"
              bucket: "proxmox-metrics"
              
    // File: group_vars/pve01/vault.yml
    ADD: vault_influxdb_token: "your_influxdb_token_here"
    
    Alternative - Prometheus:
        pve_extra_packages:
            - prometheus-node-exporter
        
        Configure systemd service:
            systemctl enable prometheus-node-exporter
            systemctl start prometheus-node-exporter
END FUNCTION
```

### 3.2 Email Notifications. email mr.dennis.truong@gmail.com

```pseudocode
FUNCTION configure_email_notifications():
    // File: group_vars/all/main.yml or monitoring.yml
    ADD datacenter configuration:
        
    pve_datacenter_cfg:
        email_from: "proxmox@{{ inventory_hostname }}.local"
        notify:
            package-updates: "mailto:mr.dennis.truong@gmail.com"
            replication: "mailto:mr.dennis.truong@gmail.com"
            fencing: "mailto:mr.dennis.truong@gmail.com"
            
    CONFIGURE system mail:
        pve_extra_packages:
            - postfix
            - mailutils
            
    Postfix configuration:
        relayhost: "[smtp.gmail.com]:587"
        smtp_sasl_auth_enable: yes
        smtp_sasl_password_maps: hash:/etc/postfix/sasl_passwd
        smtp_use_tls: yes
        
    // File: group_vars/pve01/vault.yml
    ADD: vault_gmail_app_password: "your_gmail_app_password"
        
    CREATE /etc/postfix/sasl_passwd:
        [smtp.gmail.com]:587 mr.dennis.truong@gmail.com:{{ vault_gmail_app_password }}
        
    MANUAL SETUP:
        1. Generate Gmail app password in Google Account settings
        2. Add password to vault.yml
        3. Test with: echo "Test" | mail -s "Proxmox Test" mr.dennis.truong@gmail.com
END FUNCTION
```

### 3.3 Log Forwarding Setup

```pseudocode
FUNCTION configure_log_forwarding():
    // File: group_vars/pve01/monitoring.yml
    UNCOMMENT AND CONFIGURE:
        
    Syslog forwarding:
        pve_syslog_servers:
            - server: "logs.local"  // Replace with log server
              port: 514
              protocol: "udp"
              facility: "daemon"
              
    Install rsyslog modifications:
        pve_extra_packages:
            - rsyslog-relp
            
    Custom rsyslog config:
        CREATE /etc/rsyslog.d/50-proxmox-remote.conf:
            *.* @@logs.local:514
            
    Restart services:
        systemctl restart rsyslog
END FUNCTION
```

---

## Phase 4: Network & VPN Configuration

### 4.1 VPN Setup: Use Existing NetBird/VPN Playbooks

**Skip this section** - you already have VPN playbooks configured.

```pseudocode
FUNCTION configure_vpn():
    // File: group_vars/pve01/vault.yml
    UPDATE with actual values:
        vault_zerotier_network_id: "your_actual_network_id"
        vault_zerotier_api_token: "your_zerotier_api_token"
        vault_tailscale_auth_key: "tskey-auth-your_actual_key"
        
    // Choose ONE VPN solution:
    IF using_zerotier THEN:
        pve_extra_packages:
            - zerotier-one
            
        Configure ZeroTier:
            zerotier_networks:
                - "{{ vault_zerotier_network_id }}"
            zerotier_api_token: "{{ vault_zerotier_api_token }}"
            
    ELSE IF using_tailscale THEN:
        Install Tailscale:
            curl -fsSL https://tailscale.com/install.sh | sh
            tailscale up --authkey="{{ vault_tailscale_auth_key }}"
    END IF
END FUNCTION
```

### 4.2 Network Bridge Configuration. explain whats this for

```pseudocode
FUNCTION configure_network_bridges():
    // File: group_vars/all/main.yml or new network.yml
    ADD network configuration:
        
    pve_network_bridges:
        - name: "vmbr0"
          address: "10.144.0.2/24"
          gateway: "10.144.0.1"
          bridge_ports: "eth0"
          comment: "Main VM bridge"
          
        - name: "vmbr1"  
          address: "192.168.100.1/24"
          comment: "Internal VM network"
          bridge_ports: "none"
          
    Configure VLAN if needed:
        - name: "vmbr0.100"
          vlan_id: 100
          address: "10.100.0.2/24"
          comment: "VLAN 100 for guests"
END FUNCTION
```

### 4.3 Firewall Configuration

```pseudocode
FUNCTION configure_firewall():
    // File: group_vars/pve01/security.yml (create if not exists)
    ADD firewall rules:
        
    pve_firewall_enabled: true
    pve_firewall_policy_in: "DROP"
    pve_firewall_policy_out: "ACCEPT"
    
    pve_firewall_rules:
        // Management access
        - action: "ACCEPT"
          type: "in"
          dport: 22
          proto: "tcp"
          source: "10.144.0.0/24"
          comment: "SSH from LAN"
          
        - action: "ACCEPT"
          type: "in"
          dport: 8006
          proto: "tcp"
          source: "10.144.0.0/24"
          comment: "Proxmox web interface"
          
        // VPN access
        - action: "ACCEPT"
          type: "in"
          dport: "9993"
          proto: "udp"
          comment: "ZeroTier"

        // netbird and tailscale too please
          
        // Deny all other
        - action: "DROP"
          type: "in"
          comment: "Default deny"
END FUNCTION
```

---

## Phase 5: System Hardening

### 5.1 Security Package Installation

```pseudocode
FUNCTION install_security_packages():
    // File: group_vars/all/main.yml
    UPDATE pve_extra_packages:
        - htop
        - vim
        - curl
        - wget
        - fail2ban
        - ufw
        - rkhunter
        - chkrootkit
        - aide
        - ntp
        - unattended-upgrades
        
    Configure automatic security updates:
        unattended_upgrades_enabled: true
        unattended_upgrades_auto_reboot: true
        unattended_upgrades_auto_reboot_time: "03:00"
END FUNCTION
```

### 5.2 System Maintenance Schedules

```pseudocode
FUNCTION configure_maintenance_schedules():
    // File: group_vars/pve01/monitoring.yml
    ADD maintenance windows:
        
    pve_maintenance_windows:
        - name: "security-updates"
          schedule: "0 3 * * 1"  // Monday 3 AM
          duration: "2h"
          description: "Weekly security updates"
          commands:
            - "apt update && apt upgrade -y"
            - "rkhunter --update && rkhunter --check --skip-keypress"
            
        - name: "system-cleanup"
          schedule: "0 4 1 * *"  // First of month 4 AM
          duration: "1h" 
          description: "Monthly system cleanup"
          commands:
            - "apt autoremove -y"
            - "apt autoclean"
            - "journalctl --vacuum-time=30d"
            
    Configure logrotate:
        logrotate_configs:
            - name: "proxmox"
              path: "/var/log/pve/*.log"
              rotate: 4
              weekly: true
              compress: true
              delaycompress: true
END FUNCTION
```

### 5.3 NTP and Time Synchronization

**Why time sync matters:**
- **Log timestamps** accuracy for troubleshooting
- **SSL certificate** validation (time-sensitive)
- **Backup scheduling** precision
- **Authentication tokens** (Kerberos, etc.)

**For homelab: systemd-timesyncd is adequate and already configured by default.**

```pseudocode
FUNCTION configure_ntp():
    // SKIP complex NTP configuration
    // systemd-timesyncd is already enabled and sufficient
    
    OPTIONAL - verify time sync is working:
        COMMANDS to check:
            timedatectl status
            systemctl status systemd-timesyncd
            
    IF you need custom NTP servers:
        EDIT /etc/systemd/timesyncd.conf:
            [Time]
            NTP=0.pool.ntp.org 1.pool.ntp.org
            
        THEN restart:
            systemctl restart systemd-timesyncd
            
    // Skip chrony/ntpd installation - overkill for single node
END FUNCTION
```

---

## Implementation Testing Procedures

### Pre-Implementation Checklist

```pseudocode
FUNCTION pre_implementation_check():
    VERIFY:
        - Ansible can connect to target host
        - Root SSH access is working
        - Target system has sufficient disk space
        - Network connectivity to package repositories
        - Backup of current configuration exists
        
    COMMANDS to run:
        ansible -i inventory pve01 -m ping
        ansible -i inventory pve01 -m setup | grep ansible_memtotal
        ansible -i inventory pve01 -m command -a "df -h"
END FUNCTION
```

### Post-Phase Testing

```pseudocode
FUNCTION test_each_phase():
    PHASE 1 Testing:
        - Login to web UI with pveadmin user
        - Verify SSH key-only authentication
        - Check fail2ban status: fail2ban-client status
        - Verify SSL certificate in browser
        
    PHASE 2 Testing:
        - Check storage configuration in web UI
        - Create test backup manually
        - Verify backup files exist in target location
        - Test restore procedure with test VM
        
    PHASE 3 Testing:
        - Verify metrics in monitoring system
        - Send test email notification
        - Check log forwarding: logger "test message"
        - Verify logs appear in remote system
        
    PHASE 4 Testing:
        - Test VPN connectivity from external network
        - Verify VM network bridge functionality
        - Test firewall rules with nmap scan
        - Check network routing tables
        
    PHASE 5 Testing:
        - Verify automatic updates are configured
        - Check NTP synchronization: timedatectl
        - Run security scan: rkhunter --check
        - Test maintenance scripts manually
END FUNCTION
```

### Rollback Procedures

```pseudocode
FUNCTION rollback_procedures():
    FOR each_phase:
        BEFORE making changes:
            - Create configuration backup
            - Document current state
            - Test rollback procedure
            
        IF problems_occur THEN:
            PHASE 1: Restore SSH config, disable fail2ban
            PHASE 2: Remove storage configs, restore backups
            PHASE 3: Stop monitoring services, restore configs
            PHASE 4: Reset network config, disable VPN
            PHASE 5: Revert security changes, stop services
            
        ALWAYS:
            - Keep original configuration files as .bak
            - Maintain change log with timestamps
            - Test system functionality after rollback
END FUNCTION
```


## Execution Order

1. **Phase 1**: Security foundation must be established first
2. **Phase 2**: Storage and backup before adding complexity
3. **Phase 3**: Monitoring to track system health during further changes
4. **Phase 4**: Network configuration after core system is stable
5. **Phase 5**: Final hardening and maintenance automation


## Required Manual Steps

Some configurations require manual intervention:
- Generating SSH keys if not existing
- Obtaining SSL certificates or API tokens
- Configuring external monitoring systems (InfluxDB, Grafana)
- Setting up email relay credentials
- Testing and validating each phase before proceeding

---

*This pseudo code serves as a comprehensive guide for implementing each phase systematically and safely.*