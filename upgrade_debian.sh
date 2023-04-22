#!/bin/sh

upgrade_to_buster() {
    echo "正在升级至 Debian 10 (buster)..."
    sed -i 's/stretch/buster/g' /etc/apt/sources.list
    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y

    # 清理旧的包和依赖
    echo "正在清理旧的包和依赖..."
    apt-get autoremove -y
    apt-get autoclean

    echo "正在重启系统以应用 Debian 10 (buster) 的更改..."
    reboot
}

upgrade_to_bullseye() {
    echo "正在升级至 Debian 11 (bullseye)..."
    sed -i 's/buster/bullseye/g' /etc/apt/sources.list
    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y

    # 清理旧的包和依赖
    echo "正在清理旧的包和依赖..."
    apt-get autoremove -y
    apt-get autoclean

    echo "正在重启系统以应用 Debian 11 (bullseye) 的更改..."
    reboot
}

check_version() {
    version=$(grep -oP '(?<=VERSION_CODENAME=)[a-z]+' /etc/os-release)

    if [ "$version" = "stretch" ]; then
        echo "当前版本：Debian 9 (stretch)"
        upgrade_to_buster
    elif [ "$version" = "buster" ]; then
        echo "当前版本：Debian 10 (buster)"
        upgrade_to_bullseye
    elif [ "$version" = "bullseye" ]; then
        echo "当前版本：Debian 11 (bullseye)"
        echo "您的系统已是最新版，无需进一步操作。"
        exit 0
    else
        echo "不支持的 Debian 版本。此脚本仅支持从 Debian 9 (stretch) 或 Debian 10 (buster) 升级至 Debian 11 (bullseye)。"
        exit 1
    fi
}

check_version