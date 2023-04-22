#!/bin/bash

set -e

# 取消对连接数的限制
echo "1. 取消对连接数的限制"
echo "*               soft    nofile          65535" >> /etc/security/limits.conf
echo "*               hard    nofile          65535" >> /etc/security/limits.conf
echo "fs.file-max=1000000" >> /etc/sysctl.conf
sysctl -p

# 关闭 swap 虚拟内存
echo "2. 关闭 swap 虚拟内存"
swapoff -a
sed -i '/swap/d' /etc/fstab

# 针对 BBR 进行优化，使用 Cloudflare 的优化方式
echo "3. 优化 BBR (使用 Cloudflare)"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
echo "net.ipv4.tcp_ecn=1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
sysctl -p

# 优化本机连接数，快速关闭 TIME_WAIT 连接
echo "4. 优化本机连接数，快速关闭 TIME_WAIT 连接"
echo "net.ipv4.tcp_tw_reuse=1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout=30" >> /etc/sysctl.conf
sysctl -p

# 打开 root 远程登录 SSH 的权限，并随机更改 root 密码
echo "5. 打开 root 远程登录 SSH 权限 (可选)"
read -p "是否要打开 root 远程登录 SSH 权限并随机更改密码? (Y/N): " choice
if [ "$choice" == "Y" ] || [ "$choice" == "y" ]; then
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    service ssh restart
    new_password=$(openssl rand -base64 12)
    echo "root:$new_password" | chpasswd
    echo "已设置新的 root 密码为: $new_password"
fi

# 安装指定软件
echo "6. 安装 wget、curl、iperf3 和 net-tools"
apt-get update
apt-get install -y wget curl iperf3 net-tools

echo "优化完成。"
