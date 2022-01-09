#!/bin/env bash
# ====================================================
#   Copyright © 2021  All rights reserved.
#
#   Author        : Fiix.one
#   Email         :
#   File Name     : speedtest_install.sh
#   Last Modified : 2021-12-30 07:21
#   Describe      :
#
# ====================================================

cli_name="speedtest"
url_start="https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-"
file_type=".tgz"

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
            cpu_type="x86_64" ;;
        aarch64)
            cpu_type="aarch64" ;;
        armhf)
            cpu_type="armhf" ;;
        armel)
            cpu_type="armel" ;;
        i386)
            cpu_type="i386" ;;
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
    cp -f ./${cli_name} /usr/local/bin/
    chmod +x /usr/local/bin/${cli_name}

    _log info "Install Path Is $(whereis ${cli_name})"
    _log info "Install Done! Usage: ${cli_name} -h | --help"
}


# Start Script
_chk_command
_chk_user
_chk_hardware
_install
