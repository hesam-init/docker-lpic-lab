FROM docker.arvancloud.ir/debian:trixie

ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

# ── Mirror setup ────────────────────────────────────────────────────────────
RUN rm /etc/apt/sources.list.d/debian.sources
# RUN echo "deb http://mirror.arvancloud.ir/debian trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list
RUN echo "deb http://repo.iut.ac.ir/debian/ trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list

# ── Base system update ───────────────────────────────────────────────────────
RUN apt update && apt upgrade -y --no-install-recommends

# ── Shell & terminal tools ───────────────────────────────────────────────────
RUN apt install -y --no-install-recommends \
    fish tmux screen \
    htop btop iotop \
    nano vim less \
    fzf bat fd-find ripgrep \
    tree

# ── Networking tools ─────────────────────────────────────────────────────────
RUN apt install -y --no-install-recommends \
    ca-certificates \
    net-tools iproute2 iputils-ping \
    dnsutils bind9-dnsutils \
    mtr traceroute \
    wget curl axel \
    netcat-openbsd nmap \
    tcpdump \
    openssh-client openssh-server \
    iptables nftables \
    isc-dhcp-client

# ── LPIC-1 / LPIC-2 essential packages ──────────────────────────────────────
RUN apt install -y --no-install-recommends \
    # Process & system management
    procps psmisc sysstat \
    lsof strace ltrace \
    at cron \
    # Filesystem & storage
    parted fdisk gdisk \
    e2fsprogs dosfstools \
    lvm2 mdadm \
    mount util-linux \
    # Compression & archiving
    tar gzip bzip2 xz-utils zip unzip \
    # Text processing (LPIC staples)
    grep sed gawk \
    diffutils patch \
    # Package management tools
    apt-utils aptitude \
    dpkg-dev \
    # Users & permissions (shadow suite is inside 'passwd' on Debian)
    sudo acl \
    passwd login \
    # Boot & init
    systemd systemd-sysv \
    grub2-common \
    # Logging
    rsyslog logrotate \
    # Misc utilities
    time bc \
    man-db manpages \
    locales tzdata \
    which file

# ── Development / scripting ──────────────────────────────────────────────────
RUN apt install -y --no-install-recommends \
    bash \
    python3 python3-pip \
    perl \
    git \
    make gcc

# ── Cleanup ──────────────────────────────────────────────────────────────────
RUN apt clean && rm -rf /var/lib/apt/lists/*

# ── Locale & timezone ────────────────────────────────────────────────────────
# update-locale fails in Docker (no running locale env); write the file directly
RUN locale-gen en_US.UTF-8 && \
    echo "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" > /etc/default/locale
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ── SSH setup (lab needs it) ─────────────────────────────────────────────────
RUN mkdir -p /var/run/sshd && \
    echo 'root:lpic' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ── Fish as default shell ────────────────────────────────────────────────────
RUN chsh -s /usr/bin/fish root

# ── Fish config: helpful prompt & abbreviations ──────────────────────────────
RUN mkdir -p /root/.config/fish && cat > /root/.config/fish/config.fish << 'EOF'
set fish_greeting "🐧 LPIC Lab Container — $(hostname)"
EOF

WORKDIR /root

EXPOSE 22

# Start SSH + drop into fish
CMD service ssh start && exec /usr/bin/fish