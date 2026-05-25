# 🐧 LPIC Lab — Docker Environment

A self-contained Debian-based Docker environment for studying **LPIC-1** and **LPIC-2** certification topics.

---

## 📁 Repository Structure

```
lpic-lab/
├── Dockerfile            # Lab image definition
├── docker-compose.yml    # Persistent lab + ephemeral sandbox
├── scripts/              # Mount your own lab exercise scripts here
│   └── README.sh
└── README.md
```

---

## 🚀 Quick Start

### 1. Build the image

```bash
docker compose build
```

### 2. Start the persistent lab container

```bash
docker compose up -d lab
```

### 3. Enter the lab

**Option A — attach directly:**

```bash
docker exec -it lpic-lab fish
```

**Option B — SSH (more realistic for LPIC practice):**

```bash
ssh root@localhost -p 2222
# password: lpic
```

---

## 🗂️ Containers

### `lab` — Persistent Study Node

| Property | Value |
|---|---|
| Hostname | `lpic-lab` |
| IP | `172.30.0.10` |
| SSH port | `2222 → 22` |
| Root password | `lpic` |
| Restart policy | `unless-stopped` |
| Home volume | `lab-home` (persists across restarts) |
| Storage volume | `lab-storage` mounted at `/mnt/storage` |

Use this container for your regular LPIC study sessions. Your `/root` home directory and `/mnt/storage` are backed by named Docker volumes — they survive `docker compose restart` and even `docker compose down` (volumes are **not** removed unless you explicitly pass `-v`).

```bash
# Start
docker compose up -d lab

# Stop (data kept)
docker compose stop lab

# Destroy container but keep volumes
docker compose down

# Destroy everything including data ⚠️
docker compose down -v
```

---

### `sandbox` — Ephemeral Throwaway Node

A second container for destructive / risky experiments. **Everything is lost when you exit.**

```bash
# Spin up, do your experiment, then exit — gone.
docker compose --profile sandbox run --rm sandbox
```

The sandbox shares the same `lab-net` network as the persistent lab, so you can practice two-node networking scenarios (SSH between them, routing, firewall rules, etc.):

```bash
# From sandbox, SSH into the persistent lab:
ssh root@172.30.0.10
```

---

## 📦 What's Installed

### Shell & Terminal

`fish` · `tmux` · `screen` · `htop` · `btop` · `iotop` · `nano` · `vim` · `fzf` · `bat` · `fd-find` · `ripgrep` · `tree`

### Networking

`net-tools` · `iproute2` · `iputils-ping` · `dnsutils` · `mtr` · `traceroute` · `curl` · `wget` · `axel` · `ncat` · `nmap` · `tcpdump` · `openssh-client/server` · `iptables` · `nftables` · `isc-dhcp-client`

### LPIC Core Topics

| Category | Packages |
|---|---|
| Process & system | `procps` `psmisc` `sysstat` `lsof` `strace` `ltrace` `at` `cron` |
| Filesystem & storage | `parted` `fdisk` `gdisk` `e2fsprogs` `dosfstools` `lvm2` `mdadm` |
| Compression | `tar` `gzip` `bzip2` `xz-utils` `zip` `unzip` |
| Text processing | `grep` `sed` `gawk` `diffutils` `patch` |
| Package management | `apt-utils` `aptitude` `dpkg-dev` |
| Users & permissions | `sudo` `acl` `passwd` `login` |
| Boot & init | `systemd` `grub2-common` |
| Logging | `rsyslog` `logrotate` |
| Scripting | `bash` `python3` `perl` `git` `make` `gcc` |

---

## 🔬 Lab Topic Examples

### Filesystem & LVM

```bash
# The /mnt/storage volume acts as a second disk
lsblk
# Practice creating partitions, filesystems, LVM PVs/VGs/LVs inside it
```

### Networking

```bash
# Interface info
ip addr show
ip route show

# Firewall
iptables -L -n -v
nft list ruleset

# DNS
dig @8.8.8.8 example.com
nslookup example.com
```

### Process Management

```bash
ps aux
pstree -p
strace -p <PID>
lsof -p <PID>
```

### Systemd

```bash
systemctl list-units
journalctl -xe
systemctl status ssh
```

### Two-Node Networking (lab ↔ sandbox)

```bash
# Terminal 1: start sandbox
docker compose --profile sandbox run --rm sandbox

# From inside sandbox — SSH to persistent lab
ssh root@172.30.0.10    # password: lpic

# Practice: firewall rules, routing, port forwarding between nodes
```

---

## 🛠️ Customisation

### Change timezone

Edit `docker-compose.yml`:

```yaml
environment:
  - TZ=Asia/Tehran   # change to your timezone
```

### Add your own scripts

Drop `.sh` files into `./scripts/` — they appear inside the container at `/root/scripts` (read-only mount).

### Persist extra directories

Add another named volume in `docker-compose.yml`:

```yaml
volumes:
  lab-home:
  lab-storage:
  lab-configs:        # ← new

services:
  lab:
    volumes:
      - lab-configs:/etc/lab-configs
```

---

### Fix scripts folder permission

```bash
sudo chown -R $USER:$USER ./scripts
```

## ⚠️ Notes

- Both containers run with `--privileged` and `CAP_NET_ADMIN` / `CAP_SYS_ADMIN` to allow realistic labs (iptables, mount, LVM, etc.). **Do not expose the SSH port publicly.**
- Default root password is `lpic` — change it inside the container for any serious use: `passwd root`
- The image is built on **Debian Trixie** via ArvanCloud mirrors. Rebuild occasionally to get security updates: `docker compose build --no-cache`

---

## 📚 LPIC Resources

- [LPIC-1 Objectives](https://www.lpi.org/our-certifications/lpic-1-overview)
- [LPIC-2 Objectives](https://www.lpi.org/our-certifications/lpic-2-overview)
- [Linux Journey](https://linuxjourney.com)
- [The Linux Command Line (free book)](https://linuxcommand.org/tlcl.php)
