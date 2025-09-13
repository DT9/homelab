


# BIOS
- update bios > deepsleeps4s5 > fanspeed > Tjmax 85c -20 curve > pxe oprom >
	- cpu 40/80c 25/100% > T30 50/80c 40%+ > mobo 10/80c 10/15%
# WINDOWS by hand
- MSI: GPU .85v 1890 +600mhz (shift enter enter <849)
	- optional fanControls: t30max(cpu gpu). cpu time avg 5s. 
- debloat https://github.com/memstechtips/UnattendedWinstall 
	- https://github.com/HotCakeX/Harden-Windows-Security
- power (balanced, perf, saver) > advanced > pci express > link state power management > max saving
- ryzen master > auto pbo undervolt > bios > advanced tweaker > pbo > curve optimizer > all cores negative. + ryzen-chipset driver
- ncpa.cpl > wifi > ipv4 > advanced > interface metric priority > 1
- win > remote desktop > + features
- vr 10bit 150mbps VDXRruntime ultra 90hz 
	- OpenComposite/OpenXR OverrideResolution3k FoveatedRender sharpen ~60%, FOV ~96%
# W11 Script
- unigetui + scoop choco. protonvpn, wifi analyzer, occt, msi afterburner, memtestvulkun, elgato, vortexmods, sysinternals, dlssSwapper tinynvidiaupdater jdownloader steam yubicoauth everything anydesk WSL 
- portable: ludisave playnite clamav fakeflashtest rufus rookie ARMGDDN turingPython snappyDriver winaero nvidiaProfileInspector hyperHDR WinDbg(bsod) drivestoreexplorer ventoy wiztree 
- test: hyperv net3.5 capcut bulkrename fileconverter 
- bitlocker nvme
``` winstall choco scoop.sh
# window features
wsl --install
# winget
@'
Git.Git Meta.Oculus VirtualDesktop.Streamer Malwarebytes.Malwarebytes
'@ -split '\s+' | ForEach-Object { winget install --id=$_ -e }
# scoop - user, not admin
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
# scoop pkgs
scoop bucket add extras
scoop bucket add games
scoop bucket add versions
scoop bucket add nonportable
scoop install extras/fancontrol extras/unigetui extras/twinkle-tray main/nanazip main/notepadplusplus extras/tailscale extras/vortex extras/sharex extras/crystaldiskinfo extras/crystaldiskmark extras/wiztree main/docker extras/docker-desktop extras/qbittorrent extras/revouninstaller extras/cursor extras/parsec 
# choco pwsh admin
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco pkgs
choco install -y amd-ryzen-master amd-ryzen-chipset
# brew install from macos
```

# UNIX
```shell
set -euo pipefail
sudo -v
#wifi
sudo sysctl -w net.inet.ip.ttl=65
# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/dt/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
#nix 
curl -L https://nixos.org/nix/install | sh
# brew
brew install tealdeer tmux neovim gh lazygit lazydocker direnv ncdu lf \ 
golang node \
utm raycast visual-studio-code amazon-q cloudflare-warp \
ripgrep fd jq yq fzf lnav wyne/tap/fasder anglegrinder \
kubectl k9s helm tfenv tgenv kubectx k3d trivy dive \
uv conda basictex dotenvx/brew/dotenvx \ # python
anki mas \
chart-testing \
lima docker
# security tools - TODO: brim, sysdig inspect, 
uv python install 3.12
echo "3.12" > ~/.python-version
uv tool install oletools pre-commit
# python 
pre-commit install; 
# zshrc
echo 'eval "$(fasder --init auto aliases)"' >> ~/.zshrc
echo "" > ~/.envrc
# term/theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# config
git config --global user.name "dt9"
git config --global user.email "dt9@github.com"
# aws
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
# term
brew install --cask ghostty
# file mgr
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
# editor
brew install helix
git clone https://github.com/LazyVim/starter ~/.config/nvim
```
# MACOS
```
set -euo pipefail
sudo -v
# dock cleanup
defaults write "com.apple.dock" "persistent-apps" -array; killall Dock
# brew cask
brew install --cask deepl steermouse bettertouchtool appcleaner megasync brave-browser arc kap krisp cleanshot betterdisplay orbstack tailscale obsidian alt-tab jordanbaird-ice
# brew quar
brew install --no-quarantine syntax-highlight
# mac apps: crystalfetch(w11arm) easyres windowsapp glkvm
mas install 688211836 6454431289 1295203466 6740846845
```
# mac manual
- capslock -> ctrl 
	- ipv4 wifi for vpn - ipv6 link local only
- [[License Keys]] btt bartender cleanshotx 
- restore config: raycast, btt, 
- manual setup: alt-tab, megasync, 
- manual download: sidebar
# CONTAINER
- sys: portainer traefik watchtower authentik tailscale-netbird uptimekuma cloudflare homepage dockge beszel scrutiny(smart) healthchecks ntfy/Apprise SpeedtestTracker docker-guacamole 
- dl: transmission jdownloader nextcloud
- ai: ollama n8n grafana prometheus OpenWebUI 
- file: handbrake/HRConvert2 pinchflat(YT) 
- app: komga photoprism ispy(cctv) paperless-ngx audiobookshelf freshrss rss-bridge vscodeserver Stirling-PDF commafeed
- sec: tpot crowdsec cyberchef opnsense suricata/snort securityonion wazuh/ossec awesome-docker-security 
- paid: brightdata(proxy) 
- build deep research tools list https://medium.com/@use.abhiram/top-17-docker-security-tools-4399dd64548c
