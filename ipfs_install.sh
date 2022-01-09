#!/bin/env bash
# ====================================================
#   Copyright © 2021  All rights reserved.
#
#   Author        : Fiix.one
#   Email         :
#   File Name     : ipfs_install.sh
#   Last Modified : 2021-07-30 17:12
#   Describe      :
#
# ====================================================

cli_name="ipfs"
url_start="https://github.com/ipfs/go-ipfs/releases/download/v0.11.0/go-ipfs_v0.11.0_linux-"
file_type=".tar.gz"

_log() {
    local logtype=$1
    local text
    local time_now
    text="$(shift; echo "$@")"
    time_now="$(date +'%F %H:%M:%S')"
    case $logtype in
        info)
            echo -e "\033[32m[${time_now}] [Info]\t${text}\033[0m" ;;
        erro)
            echo -e "\033[31m[${time_now}] [Erro]\t${text}\033[0m" ;;
        warn)
            echo -e "\033[33m[${time_now}] [Warn]\t${text}\033[0m" ;;
        *)
            text="$*"
            echo -e "[${time_now}] [Logs]\t${text}" ;;
    esac
}

# Check Command
#
_chk_command() {
    if [[ $(command -v ${cli_name}) ]]; then
        _log erro "CLI ${cli_name} Already Installed"
        exit 1
    else
        _log info "CLI ${cli_name} Will Be Installing..."
    fi
}

# Check USER
#
_chk_user() {
    if [[ $(id -u) = 0 ]]; then
        _log info "User Check Done."
    else
        _log erro "Please Re-run $0 As 'root | sudo' . Exit..."
        exit 1
    fi
}

# Check CPU Hardware
#
_chk_hardware() {
    case "$(uname -m)" in
        x86_64)
          cpu_type="amd64" ;;
        aarch64)
          cpu_type="arm64" ;;
        armhf)
          cpu_type="arm" ;;
        armel)
          cpu_type="arm" ;;
        i386)
          cpu_type="386" ;;
        *)
          _log erro "This CPU Is Not Supported!"
          exit 1
    esac

    _log info "CPU Hardware: ${cpu_type}"
    _log info "CPU Hardware Check Done!"
}

# Install Binary File
#

_install() {
    set -e
    _log info "Start Install ${cli_name}"

    if [[ -e /tmp/${cli_name}_tmp ]]; then
        _log info "Clean The Cache."
        rm -rf /tmp/${cli_name}_tmp
    fi

    mkdir /tmp/${cli_name}_tmp
    cd /tmp/${cli_name}_tmp

    _log info "DownLoading Files ..."
    curl -sfL -o ${cli_name}${file_type} "${url_start}${cpu_type}${file_type}"
    tar -zxf ${cli_name}${file_type}
    cp -f go-ipfs/ipfs /usr/local/bin/
    chmod +x /usr/local/bin/${cli_name}

    _log info "Install Path Is $(whereis ${cli_name})"
    _log info "Install Done! Usage: ${cli_name} -h | --help"
}

# Set Service File
#
_set_ipfs_service() {
    _log info "Setting Service File"
    cat >/etc/systemd/system/ipfs-daemon.service <<EOF
[Unit]
Description=IPFS daemon
After=network.target

[Service]
User=root
Group=root
LimitCPU=infinity
LimitFSIZE=infinity
LimitDATA=infinity
LimitSTACK=infinity
LimitCORE=infinity
LimitRSS=infinity
LimitNOFILE=infinity
LimitAS=infinity
LimitNPROC=infinity
LimitMEMLOCK=infinity
LimitLOCKS=infinity
LimitSIGPENDING=infinity
LimitMSGQUEUE=infinity
LimitRTPRIO=infinity
LimitRTTIME=infinity
# optional path to ipfs init directory if not default ($HOME/.ipfs)
# Environment=IPFS_PATH=/root/.ipfs/
ExecStart=/usr/local/bin/ipfs daemon --enable-gc --enable-pubsub-experiment
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    _log info "Set service Done"
    _log warn "File Path: /etc/systemd/system/ipfs-daemon.service"
    _log warn "You Can Config '# Environment="IPFS_PATH=/root/.ipfs/" | User | Group'"
}

# Set IPFS
#
_set_ipfs() {
    _log info "Setting ipfs Config"
    if [ ! -e /root/.ipfs ]; then
    ipfs init
    fi
    systemctl stop ipfs-daemon
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
    ipfs config --json Addresses.API '"/ip4/0.0.0.0/tcp/5010"'
    ipfs config --json Swarm.ConnMgr '{"GracePeriod": "60s","HighWater": 200,"LowWater": 100,"Type": "basic"}'
    ipfs config --json Datastore.GCPeriod '"720h"'
    systemctl restart ipfs-daemon
    systemctl enable ipfs-daemon
    sleep 5s
    _log info "The installation is complete, Enjoy your node!"
    exit 0
}

# Start Script
_chk_command
_chk_user
_chk_hardware
_install
_set_ipfs_service
_set_ipfs
