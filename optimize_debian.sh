#!/bin/bash

set -e

# 打开 root 远程登录 SSH 的权限，并随机更改 root 密码
echo "1. 打开 root 远程登录 SSH 权限 (可选)"
read -p "是否要打开 root 远程登录 SSH 权限并随机更改密码? (Y/N): " choice
if [ "$choice" == "Y" ] || [ "$choice" == "y" ]; then
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    service ssh restart
    new_password=$(openssl rand -base64 12)
    echo "root:$new_password" | chpasswd
    echo "已设置新的 root 密码为: $new_password"
fi

# 取消对连接数的限制
echo "2. 取消对连接数的限制"
echo "*               soft    nofile          65535" >> /etc/security/limits.conf
echo "*               hard    nofile          65535" >> /etc/security/limits.conf

# 关闭 swap 虚拟内存
echo "3. 关闭 swap 虚拟内存"
swapoff -a
sed -i '/swap/d' /etc/fstab

# 安装指定软件
echo "4. 安装 wget、curl、iperf3、net-tools、dnsutils"
apt-get update
apt-get install -y wget curl iperf3 net-tools dnsutils

# 系统优化
echo "5. 系统优化"
cat << EOF >> /etc/sysctl.conf
fs.file-max=1000000
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_ecn=1
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=30

# 添加您提供的设置
net.core.rps_sock_flow_entries=32768
fs.inotify.max_user_instances=65536
net.ipv4.neigh.default.gc_stale_time=60
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_retries1=3
net.ipv4.tcp_retries2=8
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_max_tw_buckets=32768
net.core.dev_weight=4096
net.core.netdev_budget=65536
net.core.netdev_budget_usecs=4096
net.ipv4.tcp_max_syn_backlog=262144
net.core.netdev_max_backlog=32768
net.core.somaxconn=32768
net.ipv4.tcp_notsent_lowat=16384
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_keepalive_intvl=15
vm.swappiness=1
net.ipv4.route.gc_timeout=100
net.ipv4.neigh.default.gc_thresh1=1024
net.ipv4.neigh.default.gc_thresh2=4096
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.tcp_mem=262144 1048576 4194304
net.ipv4.udp_mem=262144 524288 1048576
EOF

sysctl -p

echo "优化完成。"
