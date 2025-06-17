#!/bin/bash

# ==============================================
# OptiVPN - Ultimate Server & VPN Optimizer
# Author: HOSEINLOL | Enhanced by Community
# Version: 0.0.1
# ==============================================


RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"


CPU_CORES=$(nproc)
RAM_GB=$(free -g | awk '/Mem:/ {print $2}')
SSD_NVME=$(lsblk -d -o rota | grep -c '0')


if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Run as root! Use: sudo -i${RESET}"
    exit 1
fi


system_info() {
    echo -e "${CYAN}${BOLD}⚙ System Specifications:${RESET}"
    echo -e "• CPU Cores: $CPU_CORES"
    echo -e "• RAM: ${RAM_GB}GB"
    echo -e "• Storage: $([ "$SSD_NVME" -gt 0 ] && echo "NVMe/SSD" || echo "HDD")"
    echo -e "• Kernel: $(uname -r)"
    echo -e "• Uptime: $(uptime -p)"
}


optimize_network() {
    echo -e "${CYAN}${BOLD}🚀 Applying Extreme Network Optimizations...${RESET}"
    
    
    sed -i '/# OptiVPN Ultimate/d' /etc/sysctl.conf
    
    
    cat <<EOF >> /etc/sysctl.conf

# OptiVPN Ultimate - Extreme Network Optimization
fs.file-max = 4194304
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.core.netdev_max_backlog = 1000000
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_ecn = 2
EOF

    
    if [ "$SSD_NVME" -gt 0 ]; then
        echo "net.core.busy_read = 50" >> /etc/sysctl.conf
        echo "net.core.busy_poll = 50" >> /etc/sysctl.conf
    fi

    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}✓ Network stack tuned for maximum performance${RESET}"
}


install_bbr() {
    echo -e "${CYAN}${BOLD}🚀 Installing BBR3 Congestion Control...${RESET}"
    
    
    if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        echo -e "${YELLOW}✓ BBR is already enabled${RESET}"
        return
    fi

    
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1

    
    modprobe tcp_bbr3 2>/dev/null
    if lsmod | grep -q "tcp_bbr3"; then
        echo "net.ipv4.tcp_congestion_control=bbr3" >> /etc/sysctl.conf
        echo -e "${GREEN}✓ BBR3 successfully loaded!${RESET}"
    else
        echo -e "${GREEN}✓ BBR (default) enabled${RESET}"
    fi
}


optimize_cpu() {
    echo -e "${CYAN}${BOLD}⚡ Optimizing CPU & Process Scheduling...${RESET}"
    
    # CPU Governor
    if command -v cpupower &>/dev/null; then
        cpupower frequency-set -g performance >/dev/null
    else
        for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo performance > "$i" 2>/dev/null
        done
    fi

    
    echo "* soft nofile 4194304" >> /etc/security/limits.conf
    echo "* hard nofile 4194304" >> /etc/security/limits.conf
    echo "root soft nofile 4194304" >> /etc/security/limits.conf
    echo "root hard nofile 4194304" >> /etc/security/limits.conf

    
    echo "kernel.panic = 10" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf

    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}✓ CPU & process scheduling optimized${RESET}"
}


optimize_memory() {
    echo -e "${CYAN}${BOLD}🧠 Optimizing Memory & Swap...${RESET}"
    
    
    if [ "$RAM_GB" -lt 8 ]; then
        swapoff -a
        sed -i '/swap/d' /etc/fstab
        echo -e "${YELLOW}⚠ Swap disabled (low RAM system)${RESET}"
    else
        
        echo "vm.swappiness = 10" >> /etc/sysctl.conf
        echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
    fi

    
    echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
    echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
    echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
    echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local

    
    echo "vm.oom_kill_allocating_task = 1" >> /etc/sysctl.conf

    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}✓ Memory & swap optimized${RESET}"
}


optimize_vpn() {
    echo -e "${CYAN}${BOLD}🔒 Applying VPN-Specific Optimizations...${RESET}"
    
    
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf

    
    echo "net.core.optmem_max = 4194304" >> /etc/sysctl.conf
    echo "net.ipv4.udp_mem = 786432 1048576 1572864" >> /etc/sysctl.conf

    
    if pgrep openvpn >/dev/null; then
        echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.conf
    fi

    
    echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf

    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}✓ VPN-specific optimizations applied${RESET}"
}


enable_ddos_protection() {
    echo -e "${CYAN}${BOLD}🛡️ Enabling DDoS Protection...${RESET}"
    
    
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf

    
    echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf

    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}✓ Basic DDoS protection enabled${RESET}"
}


clean_cache() {
    echo -e "${CYAN}${BOLD}🧹 Cleaning RAM Cache...${RESET}"
    sync
    echo 1 > /proc/sys/vm/drop_caches
    echo 2 > /proc/sys/vm/drop_caches
    echo 3 > /proc/sys/vm/drop_caches
    echo -e "${GREEN}✓ RAM cache cleared${RESET}"
}


benchmark_network() {
    echo -e "${CYAN}${BOLD}📊 Running Network Benchmark...${RESET}"
    
    if ! command -v iperf3 >/dev/null; then
        echo -e "${YELLOW}Installing iperf3...${RESET}"
        apt-get update && apt-get install -y iperf3 || yum install -y iperf3
    fi

    
    iperf3 -s -D >/dev/null 2>&1
    
    
    echo -e "${WHITE}"
    iperf3 -c localhost -t 10
    echo -e "${RESET}"
    
    
    pkill iperf3
    echo -e "${GREEN}✓ Network benchmark completed${RESET}"
}


show_menu() {
    clear
    echo -e "${GREEN}${BOLD}"
    echo -e "=============================================="
    echo -e "⚡ OptiVPN - Server Booster & Optimizer"
    echo -e "🌐 Version: 0.0.1 "
    echo -e "=============================================="
    echo -e "${RESET}"
    system_info
    echo -e ""
    echo -e "${CYAN}${BOLD}📌 Select Optimization:${RESET}"
    echo -e "1) 🚀 Extreme Network Boost (All Optimizations)"
    echo -e "2) 🔒 VPN-Specific Optimizations"
    echo -e "3) ⚡ CPU & Process Tuning"
    echo -e "4) 🧠 Memory & Swap Optimization"
    echo -e "5) 🛡️ Enable DDoS Protection"
    echo -e "6) 📊 Run Network Benchmark"
    echo -e "7) 🧹 Clean RAM Cache"
    echo -e "8) 🔄 Reboot Server (Recommended After Changes)"
    echo -e "0) ❌ Exit"
    echo -e ""
}


while true; do
    show_menu
    read -p "➡️  Your choice [0-8]: " choice
    
    case $choice in
        1)
            optimize_network
            install_bbr
            optimize_cpu
            optimize_memory
            optimize_vpn
            enable_ddos_protection
            ;;
        2)
            optimize_vpn
            ;;
        3)
            optimize_cpu
            ;;
        4)
            optimize_memory
            ;;
        5)
            enable_ddos_protection
            ;;
        6)
            benchmark_network
            ;;
        7)
            clean_cache
            ;;
        8)
            echo -e "${YELLOW}⚠ Rebooting server...${RESET}"
            reboot
            exit 0
            ;;
        0)
            echo -e "${GREEN}👋 Exiting OptiVPN Ultimate. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option!${RESET}"
            ;;
    esac
    
    read -p "Press Enter to continue..."
done
