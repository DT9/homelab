# BareMinimalist - Baremetal to production-ready cluster/fleet (WIP in-order)
- [x] iPXE/Network boot (Debian)
- [x] Ansible Proxmox + GPU Passthrough + Secrets Manager
- [ ] LXC
   - [ ] Proxmox Backup Server
   - [ ] Mesh VPN
- [ ] K8S
   - [ ] Admin Tools: k9s 
   - [ ] Security Admin Tools: 
   - [ ] Policy: opa or kyverno
   - [ ] IAM
      - [ ] IdP/SSO: keycloak Authelia
      - [ ] RBAC
      - [ ] BreakGlass
   - [ ] Networking
      - [ ] CNI / ServiceMesh / LB: Cilium
      - [ ] ZeroTrust: Netbird / mTLS
      - [ ] IDPS: Falco
      - [ ] Firewall: OPNsense with HA, VLANs, ACLs, WAN failover.
      - [ ] DNS/DHCP: AdGuard Unbound + Kea + external-dns
      - [ ] IPAM/CMDB: phpIPAM
      - [ ] Time: NTP/PTP
   - [ ] Storage: CephRook
     - [ ] Registry: Harbor
   - [ ] Cluster / Scaling
     - [ ] Rancher
     - [ ] Karpenter
   - [ ] Monitoring
      - [ ] SIEM: SecurityOnion + Prom/Graf/Alert
      - [ ] EDR / DLP: Wazuh
   - [ ] CICD / Gitops
      - [ ] Atlantis
      - [ ] ArgoCD
      - [ ] Signing: Cosign/Sigstore
      - [ ] SAST/DAST: checkov
   - [ ] Backup: Velero
   - [ ] Secrets: Vault ESO
   - [ ] CertMgmt: Cert-manager DNS01 SPIFFE
   - [ ] CostMgmt: Kubecost
   - [ ] Inventory: live asset inventory, ownership, data classification
   - [ ] SOAR
   - [ ] CTI
   - [ ] Honeypot
   - [ ] SupplyChain
     - [ ] Dependencies: Dependabot
     - [ ] SBOM: DependencyTrack + Trivy/Grype
   - [ ] Applications DevSecOps (Helm)
      - [ ] AI
         - [ ] Agent
         - [ ] RAG
         - [ ] Video
         - [ ] Audio
      - [ ] SAST/DAST: Atomic Semgrep
      - [ ] VulnMgmt
      - [ ] Phishing
      - [ ] ChaosEng: Litmus
      - [ ] GitRunner
      - [ ] VSCodeServer
      - [ ] Playbook / Runbook
   - [ ] Applications RedTeam (Helm)
   - [ ] Applications OSINT (Helm)
   - [ ] Applications Experimental (Helm)
      - [ ] HR / Marketing / Sales
      - [ ] RSS
      - [ ] Immich
      - [ ] NextCloud
- [ ] VM (Workstations)
   - [ ] W10 IoT LTSC Gaming
   - [ ] W11/12
      - [ ] Pwsh + Nix
   - [ ] MacOS
      - [ ] Nix
   - [ ] Linux
      - [ ] Nix
      - [ ] SIFT
      - [ ] Kali
      - [ ] netboot.xyz / iventoy
- [ ] Documentation / Maintenance / Governance
   - [ ] Overview + Tech Tier List (iterate deep research)
     - [ ] Diagrams: physical topology, IP/VLAN/DNS, cluster logical, mgmt VLAN/OOB, logging/telemetry, cert/identity flows
   - [ ] Defense-in-depth + kill switch runbook
   - [ ] HITL Play/Runbooks: incident/IR, DR failover, upgrade procedures, storage health
   - [ ] Contributor mgmt: PR templates, license, 
   - [ ] Regulations/Frameworks Collection: PCI DSS, ISO 127001, SOC2, NIST, 



Quick Wins (prioritized next steps)
Decide IdP (Keycloak) and wire SSO + MFA across Argo, Vault, Grafana, etc.
Baseline K8s security: PSA restricted, default-deny NetworkPolicies, LimitRanges.
Add Harbor + Cosign + Syft/Grype; enforce signed, scanned images via Kyverno.
Stand up external-dns + HA ingress + Authelia/OAuth2-Proxy for SSO front door.
Turn on Loki/Tempo/Otel collector; pipe K8s audit logs into SIEM.
Define DR: 3-2-1 backups, immutable offsite, monthly restore drills with RTO/RPO.
