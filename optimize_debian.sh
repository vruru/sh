#!/bin/bash

# 打开 root 远程登录 SSH 的权限，并随机更改 root 密码
echo "1. 打开 root 远程登录 SSH 权限 (可选)"
read -p "是否要打开 root 远程登录 SSH 权限并随机更改密码? (Y/N): " choice
if [ "$choice" == "Y" ] || [ "$choice" == "y" ]; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    new_password=$(openssl rand -base64 12)
    echo "root:$new_password" | chpasswd
    echo "已设置新的 root 密码为: $new_password"
    service ssh restart
fi

# 取消对连接数的限制
echo "2. 取消对连接数的限制"
echo "*               soft    nofile          65535" >> /etc/security/limits.conf
echo "*               hard    nofile          65535" >> /etc/security/limits.conf

# 关闭 swap 虚拟内存
echo "3. 关闭 swap 虚拟内存"
swapoff -a
sed -i '/swap/d' /etc/fstab

modprobe ip_conntrack
# 系统优化
echo "4. 系统优化"
cat << EOF >> /etc/sysctl.conf
fs.file-max=2097152
fs.inotify.max_user_instances=65536
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_retries1=3
net.ipv4.tcp_retries2=5
net.ipv4.tcp_orphan_retries=3
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_max_tw_buckets=5000
net.ipv4.tcp_max_syn_backlog=131072
net.core.netdev_max_backlog=131072
net.core.somaxconn=32768
net.ipv4.tcp_notsent_lowat=16384
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_autocorking=0
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
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
net.ipv4.udp_rmem_min=16384
net.ipv4.udp_wmem_min=16384
net.ipv4.tcp_mem=262144 1048576 4194304
net.ipv4.udp_mem=262144 1048576 4194304
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ping_group_range=0 2147483647
net.netfilter.nf_conntrack_max=4194304
net.nf_conntrack_max=655360
net.netfilter.nf_conntrack_tcp_timeout_established=1200
net.core.rps_sock_flow_entries=32768
net.ipv4.neigh.default.gc_stale_time=60
net.core.dev_weight=128
net.core.netdev_budget=10000
net.core.netdev_budget_usecs=4096
vm.swappiness=10
net.ipv4.route.gc_timeout=100
net.ipv4.neigh.default.gc_thresh1=1024
net.ipv4.neigh.default.gc_thresh2=4096
#net.ipv6.conf.all.disable_ipv6=1
net.core.optmem_max=65535
net.ipv4.tcp_dsack=1
net.ipv4.tcp_low_latency=1
vm.dirty_ratio=60
vm.dirty_background_bytes=4194304
vm.dirty_background_ratio=10
vm.dirty_bytes=8388608
vm.dirty_writeback_interval=500
net.ipv4.tcp_max_orphans=32768
kernel.pid_max=65536
vm.max_map_count=262144
vm.vfs_cache_pressure=1000
vm.overcommit_memory=1
kernel.shmmax=4294967295
kernel.shmall=268435456
net.ipv4.udp_max_bufsize=8388608
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_base_mss=65535
net.ipv4.tcp_mtu_discover=1
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
EOF
sysctl -p || true
echo "优化完成。"

# 安装指定软件
echo "5. 安装 wget、curl、iperf3、net-tools、dnsutil"
apt-get update
apt-get install -y wget curl iperf3 net-tools dnsutils
