sudo bash -c "$(cat << 'EOF_SCRIPT'
#!/bin/bash

# ================= 颜色和前缀定义 =================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
PREFIX="**"

# ================= 辅助函数：环境依赖与网络优化 (共享) =================
function prepare_env_and_optimize() {
    echo -e "${YELLOW}${PREFIX} 正在检测并清理可能冲突的老旧 Hysteria 服务...${NC}"
    # 彻底关停并禁用老脚本的 hysteria.service，释放 443 端口
    if systemctl is-active --quiet hysteria; then
        systemctl stop hysteria 2>/dev/null || true
    fi
    systemctl disable hysteria 2>/dev/null || true

    echo -e "${YELLOW}${PREFIX} 正在更新组件并获取 IP...${NC}"
    apt-get update -y -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl wget openssl iptables iptables-persistent netfilter-persistent ufw > /dev/null 2>&1

    PUBLIC_IP=$(curl -4 -s --connect-timeout 5 icanhazip.com || curl -4 -s --connect-timeout 5 ifconfig.me)
    if [ -z "$PUBLIC_IP" ]; then
        echo -e "${RED}${PREFIX} ❌ 无法获取公网 IP，请检查 VPS 网络！${NC}"
        exit 1
    fi

    echo -e "${YELLOW}${PREFIX} 正在配置 2G 虚拟内存 (Swap)...${NC}"
    SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
    if [ -z "$SWAP_TOTAL" ] || [ "$SWAP_TOTAL" -lt 1900 ]; then
        swapoff -a 2>/dev/null
        rm -f /swapfile
        fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
        chmod 600 /swapfile
        mkswap /swapfile > /dev/null 2>&1
        swapon /swapfile 2>/dev/null
        grep -q "/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi

    echo -e "${YELLOW}${PREFIX} 正在启用原生 BBR+FQ 与 UDP 16MB 扩容...${NC}"
    cat << SYSCTL_EOF > /etc/sysctl.d/99-hysteria.conf
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
fs.file-max = 1048576
SYSCTL_EOF
    sysctl --system > /dev/null 2>&1

    echo -e "${YELLOW}${PREFIX} 正在破除系统全局并发连接数 (1024 ➔ 1048576)...${NC}"
    cat << EOF_LIMITS > /etc/security/limits.d/99-hysteria.conf
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF_LIMITS
    sed -i 's/.*DefaultLimitNOFILE.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/system.conf
    sed -i 's/.*DefaultLimitNOFILE.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/user.conf
    systemctl daemon-reexec

    echo -e "${YELLOW}${PREFIX} 正在部署 Hysteria 2 核心...${NC}"
    if [ ! -f "/usr/local/bin/hysteria" ]; then
        wget -q -O /usr/local/bin/hysteria https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64
        chmod +x /usr/local/bin/hysteria
    fi

    mkdir -p /etc/hysteria
    if [ ! -f "/etc/hysteria/server.key" ]; then
        openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -days 3650 -subj "/CN=bing.com" > /dev/null 2>&1
    fi
}

function configure_systemd_and_firewall() {
    cat << EOF_SERVICE > /etc/systemd/system/hysteria-server.service
[Unit]
Description=Hysteria 2 Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
WorkingDirectory=/etc/hysteria
User=root
Group=root
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF_SERVICE

    systemctl daemon-reload

    echo -e "${YELLOW}${PREFIX} 正在配置安全防火墙放行规则...${NC}"
    # UFW 放行 (针对 Ubuntu 等系统)
    ufw allow 443/tcp 2>/dev/null || true
    ufw allow 443/udp 2>/dev/null || true
    ufw allow 40000:50000/udp 2>/dev/null || true
    
    # iptables 强制放行 (针对纯净 Debian/CentOS 等系统)
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT -p udp --dport 443 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT -p udp --dport 40000:50000 -j ACCEPT 2>/dev/null || true
    netfilter-persistent save > /dev/null 2>&1 || true

    systemctl enable hysteria-server.service > /dev/null 2>&1
    systemctl restart hysteria-server.service
    sleep 2
}

# ================= A. 单用户无脑安装 (原版) =================
function install_single() {
    clear
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    echo -e "${CYAN}${PREFIX} Hysteria 2 团队版 - V10 架构师完美版 (单用户)${NC}"
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    
    echo -e "\n${YELLOW}⏳ 根据VPS的网络情况，全程需要1分半到2分钟，请耐心等待...${NC}\n"
    
    PASSWORD=$(tr -dc 'A-Za-z0-9!_.-' </dev/urandom | head -c 20)
    prepare_env_and_optimize

    cat << EOF2 > /etc/hysteria/config.yaml
listen: :443,40000-50000
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key
obfs:
  type: salamander
  salamander:
    password: ${PASSWORD}
auth:
  type: password
  password: ${PASSWORD}
masquerade:
  type: proxy
  proxy:
    url: https://news.ycombinator.com
    rewriteHost: true
bandwidth:
  up: 300 mbps
  down: 300 mbps
EOF2

    configure_systemd_and_firewall

    echo -e "${GREEN}🎉 部署大功告成！直接将以下配置分发即可：${NC}\n"
    
    echo -e "${YELLOW}【1. 手机端：Shadowrocket (小火箭) 节点链接】${NC}"
    echo -e "\n${GREEN}hysteria2://${PASSWORD}@${PUBLIC_IP}:443/?mport=40000-50000&sni=bing.com&obfs=salamander&obfsParam=${PASSWORD}&insecure=1#Team-HY2-Node${NC}\n"
    
    echo -e "${YELLOW}【2. 电脑端：Clash Verge (Windows/Mac) 配置文件】${NC}"
    cat << EOF3
proxies:
  - name: "Team-HY2-Node"
    type: hysteria2
    server: ${PUBLIC_IP}
    port: 443
    ports: 40000-50000
    password: ${PASSWORD}
    sni: bing.com
    skip-cert-verify: true
    obfs: salamander
    obfs-password: ${PASSWORD}
    up: 30
    down: 30

proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies:
      - "Team-HY2-Node"

rules:
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,🚀 节点选择
EOF3
    echo -e "\n${CYAN}💡 提示：冲突已自动解决，防火墙已打通，原生端口跳跃已激活！${NC}"
    echo ""
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# ================= B. 多用户独立账号安装 =================
function install_multi() {
    clear
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    echo -e "${CYAN}${PREFIX} Hysteria 2 多用户独立账号版 - 部署向导${NC}"
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    
    echo -e "${YELLOW}即将创建多用户配置。建议为每个成员分配独立账号以方便管理。${NC}"
    read -p "👉 请输入要创建的用户数量 (默认回车=10，建议≤20): " USER_COUNT
    USER_COUNT=${USER_COUNT:-10}

    if ! [[ "$USER_COUNT" =~ ^[0-9]+$ ]] || [ "$USER_COUNT" -le 0 ]; then
        echo -e "${RED}❌ 输入无效，请输入大于 0 的阿拉伯数字。${NC}"
        sleep 2; return
    fi

    echo -e "\n${YELLOW}⏳ 根据VPS的网络情况，全程需要1分半到2分钟，请耐心等待...${NC}\n"

    prepare_env_and_optimize

    OBFS_PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)
    echo "PUBLIC_IP=${PUBLIC_IP}" > /etc/hysteria/.env_multi
    echo "OBFS_PASSWORD=${OBFS_PASSWORD}" >> /etc/hysteria/.env_multi

    # 第一部分：写入配置文件头部
    cat << EOF2_HEAD > /etc/hysteria/config.yaml
listen: :443,40000-50000
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key
obfs:
  type: salamander
  salamander:
    password: ${OBFS_PASSWORD}
auth:
  type: userpass
  userpass:
EOF2_HEAD

    # 声明数组记录账密，用于打印
    declare -a M_NAMES
    declare -a M_PASSES

    # 第二部分：循环追加写入用户账号和密码
    for i in $(seq 1 $USER_COUNT); do
        UNAME="user${i}"
        UPASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10)
        M_NAMES[$i]=$UNAME
        M_PASSES[$i]=$UPASS
        echo "    ${UNAME}: ${UPASS}" >> /etc/hysteria/config.yaml
    done

    # 第三部分：写入配置文件尾部
    cat << EOF2_TAIL >> /etc/hysteria/config.yaml
masquerade:
  type: proxy
  proxy:
    url: https://news.ycombinator.com
    rewriteHost: true
bandwidth:
  up: 300 mbps
  down: 300 mbps
EOF2_TAIL

    configure_systemd_and_firewall

    clear
    echo -e "${GREEN}🎉 多用户部署大功告成！${NC}\n"
    
    echo -e "${YELLOW}【1. 手机端：各成员专属链接 (Shadowrocket/v2rayN)】${NC}"
    for i in $(seq 1 $USER_COUNT); do
        name="${M_NAMES[$i]}"
        pass="${M_PASSES[$i]}"
        echo -e "👤 用户 ${CYAN}[${name}]${NC} :"
        echo -e "${GREEN}hysteria2://${name}:${pass}@${PUBLIC_IP}:443/?mport=40000-50000&sni=bing.com&obfs=salamander&obfsParam=${OBFS_PASSWORD}&insecure=1#HY2-${name}${NC}\n"
    done
    
    echo -e "${YELLOW}【2. 电脑端：Clash Verge 各成员独立配置文件 (隔离分发版)】${NC}"
    echo -e "${CYAN}说明：请复制以下对应成员的整个 YAML 区块发给对应的人，避免多人使用同一配置。${NC}\n"
    
    for i in $(seq 1 $USER_COUNT); do
        name="${M_NAMES[$i]}"
        pass="${M_PASSES[$i]}"
        echo -e "--------------------------------------------------------"
        echo -e " 👇 👇 👇 给成员 ${CYAN}[${name}]${NC} 的完整 Clash 配置 👇 👇 👇"
        echo -e "--------------------------------------------------------"
        cat << EOF_YAML_SINGLE
proxies:
  - name: "HY2-${name}"
    type: hysteria2
    server: ${PUBLIC_IP}
    port: 443
    ports: 40000-50000
    password: "${name}:${pass}"
    sni: bing.com
    skip-cert-verify: true
    obfs: salamander
    obfs-password: ${OBFS_PASSWORD}
    up: 30
    down: 30

proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies:
      - "HY2-${name}"

rules:
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,🚀 节点选择
EOF_YAML_SINGLE
        echo -e "\n"
    done

    echo -e "${CYAN}💡 提示：冲突已自动清理，防火墙已打通，原生端口跳跃已激活！主菜单 [C] 随时管理独立账号！${NC}"
    echo ""
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# ================= C. 修改更新多用户密码 =================
function update_multi_user() {
    clear
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    echo -e "${CYAN}${PREFIX} 修改/更新多用户账号密码${NC}"
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"

    if [ ! -f "/etc/hysteria/config.yaml" ] || ! grep -q "type: userpass" /etc/hysteria/config.yaml; then
        echo -e "${RED}❌ 错误：未找到配置文件，或当前部署的不是【多用户模式】！${NC}"
        echo ""
        read -n 1 -s -r -p "按任意键返回..."
        return
    fi

    source /etc/hysteria/.env_multi 2>/dev/null
    PUBLIC_IP=${PUBLIC_IP:-$(curl -4 -s icanhazip.com)}

    echo -e "${YELLOW}📋 当前存在的用户列表：${NC}"
    declare -a u_names
    declare -a u_passes
    count=0

    # 稳健地解析 YAML 里的多用户字典
    users_raw=$(awk '/^[[:space:]]*userpass:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag {print}' /etc/hysteria/config.yaml | grep ":")
    
    while IFS=":" read -r name pass; do
        name=$(echo "$name" | tr -d ' ')
        pass=$(echo "$pass" | tr -d ' ')
        count=$((count+1))
        u_names[$count]=$name
        u_passes[$count]=$pass
        echo -e " [${CYAN}${count}${NC}] 用户名: ${GREEN}${name}${NC} \t| 密码: ${YELLOW}${pass}${NC}"
    done <<< "$users_raw"

    echo ""
    read -p "👉 请输入要修改密码的【账号编号】 (1-$count，输入 0 返回主菜单): " sel_idx

    if [[ "$sel_idx" -ge 1 && "$sel_idx" -le "$count" ]]; then
        target_user=${u_names[$sel_idx]}
        read -p "👉 请输入 [${target_user}] 的新密码 (直接回车将自动生成随机密码): " new_pass
        if [ -z "$new_pass" ]; then
            new_pass=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10)
        fi

        # 替换配置文件中的密码
        sed -i "s/^[[:space:]]*${target_user}:.*/    ${target_user}: ${new_pass}/" /etc/hysteria/config.yaml
        systemctl restart hysteria-server.service
        
        clear
        echo -e "${GREEN}✅ 用户 ${target_user} 的密码已成功更新！服务已热重启。${NC}\n"
        echo -e "${CYAN}================= 📝 最新用户列表与链接 =================${NC}"
        
        # 更新后重新解析并输出
        users_raw_updated=$(awk '/^[[:space:]]*userpass:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag {print}' /etc/hysteria/config.yaml | grep ":")
        while IFS=":" read -r name pass; do
            name=$(echo "$name" | tr -d ' ')
            pass=$(echo "$pass" | tr -d ' ')
            echo -e "👤 用户: ${CYAN}${name}${NC} | 密码: ${YELLOW}${pass}${NC}"
            echo -e "🔗 链接: ${GREEN}hysteria2://${name}:${pass}@${PUBLIC_IP}:443/?mport=40000-50000&sni=bing.com&obfs=salamander&obfsParam=${OBFS_PASSWORD}&insecure=1#HY2-${name}${NC}\n"
        done <<< "$users_raw_updated"
        echo -e "${YELLOW}💡 提示: 若该用户使用 Clash，请通知对方将其原配置中的 [password] 修改为新密码 \"${target_user}:${new_pass}\" 即可。${NC}"
    else
        echo -e "${YELLOW}操作取消。${NC}"
    fi

    echo ""
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# ================= D. 老节点底层网络调优 =================
function optimize_old_node() {
    clear
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"
    echo -e "${CYAN}${PREFIX} 老节点无损热升级方案 - [Swap + BBR + UDP + 并发解锁]${NC}"
    echo -e "${CYAN}${PREFIX} =========================================================${NC}"

    echo -e "${YELLOW}${PREFIX} [1/4] 正在检查并配置 2GB 虚拟内存 (Swap)...${NC}"
    SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
    if [ -n "$SWAP_TOTAL" ] && [ "$SWAP_TOTAL" -ge 1900 ]; then
        echo -e "${GREEN}${PREFIX} 当前 Swap 容量为 ${SWAP_TOTAL}MB，已达标，无需重复设置。${NC}"
    else
        echo -e "${YELLOW}${PREFIX} 当前 Swap 容量不足，正在安全扩容至 2GB...${NC}"
        swapoff -a 2>/dev/null
        rm -f /swapfile
        fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
        chmod 600 /swapfile
        mkswap /swapfile > /dev/null 2>&1
        swapon /swapfile
        if ! grep -q "/swapfile" /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        echo -e "${GREEN}${PREFIX} 虚拟内存 2GB 扩容成功！${NC}"
    fi

    echo -e "${YELLOW}${PREFIX} [2/4] 正在开启原生 BBR+FQ 并优化 UDP 缓冲区至 16MB...${NC}"
    cat << SYSCTL_EOF > /etc/sysctl.d/99-network-upgrade.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
fs.file-max = 1048576
SYSCTL_EOF
    sysctl --system > /dev/null 2>&1
    echo -e "${GREEN}${PREFIX} BBR+FQ 与 UDP 缓冲区扩容成功！${NC}"

    echo -e "${YELLOW}${PREFIX} [3/4] 正在破除系统与服务的全局并发连接数限制...${NC}"
    cat << EOF_LIMITS > /etc/security/limits.d/99-high-concurrency.conf
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF_LIMITS
    sed -i 's/.*DefaultLimitNOFILE.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/system.conf 2>/dev/null
    sed -i 's/.*DefaultLimitNOFILE.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/user.conf 2>/dev/null
    systemctl daemon-reexec
    echo -e "${GREEN}${PREFIX} 全局并发限制破除成功！${NC}"

    echo -e "${YELLOW}${PREFIX} [4/4] 正在检测代理服务状态...${NC}"
    # 强制清理老旧冲突
    if systemctl is-active --quiet hysteria; then
        systemctl stop hysteria 2>/dev/null || true
        systemctl disable hysteria 2>/dev/null || true
    fi

    if systemctl list-unit-files | grep -q "hysteria"; then
        echo -e "${YELLOW}${PREFIX} 检测到新版 Hysteria 服务，正在重启以接入最新底层网络环境...${NC}"
        systemctl restart hysteria-server.service 2>/dev/null || systemctl restart hysteria.service 2>/dev/null
        sleep 1
        echo -e "${GREEN}${PREFIX} 代理服务已成功重启并接管新环境！${NC}"
    else
        echo -e "${GREEN}${PREFIX} 未检测到 Hysteria 服务，底层环境已就绪，等待后续应用接入。${NC}"
    fi

    echo -e "\n${CYAN}=========================================================${NC}"
    echo -e "${CYAN}📋 老节点究极形态升级验证清单 (CheckList)${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    ERR=0
    FINAL_SWAP=$(free -m | awk '/^Swap:/{print $2}')
    if [ -n "$FINAL_SWAP" ] && [ "$FINAL_SWAP" -ge 1900 ]; then
        echo -e "${GREEN}[✔] 内存兜底: 当前为 ${FINAL_SWAP}MB，2GB 保护档已就绪。${NC}"
    else
        echo -e "${RED}[❌] 内存兜底: 失败 (当前 ${FINAL_SWAP}MB)${NC}"; ERR=1
    fi
    BBR_STATUS=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    FQ_STATUS=$(sysctl net.core.default_qdisc | awk '{print $3}')
    if [[ "$BBR_STATUS" == "bbr" ]] && [[ "$FQ_STATUS" == "fq" ]]; then
        echo -e "${GREEN}[✔] 拥塞控制: BBR + FQ 算法已双重激活。${NC}"
    else
        echo -e "${RED}[❌] 拥塞控制: 失败 (当前 TCP:$BBR_STATUS, QDISC:$FQ_STATUS)${NC}"; ERR=1
    fi
    UDP_RMEM=$(sysctl net.core.rmem_max | awk '{print $3}')
    if [ "$UDP_RMEM" -eq 16777216 ]; then
        echo -e "${GREEN}[✔] 极速防漏: 16MB 级 UDP 缓冲区已扩容。${NC}"
    else
        echo -e "${RED}[❌] 极速防漏: 失败 (当前 $UDP_RMEM)${NC}"; ERR=1
    fi
    if grep -q "1048576" /etc/security/limits.d/99-high-concurrency.conf; then
        echo -e "${GREEN}[✔] 海量并发: 软硬限制破除至 104 万。${NC}"
    else
        echo -e "${RED}[❌] 海量并发: 失败${NC}"; ERR=1
    fi
    echo -e "${CYAN}=========================================================${NC}\n"

    if [ "$ERR" == "1" ]; then
        echo -e "${RED}⚠️ 部分优化项未生效，请检查系统内核支持。${NC}"
    else
        echo -e "${GREEN}🎉 升级大功告成！尽情享受跑满带宽的快感吧！${NC}"
    fi

    echo ""
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# ================= 主菜单逻辑 =================
while true; do
    clear
    echo -e "${CYAN}=================================================================${NC}"
    echo -e "${CYAN}🚀 Hysteria 2 架构师综合管理面板 (Ubuntu 24.04 特化版)${NC}"
    echo -e "${CYAN}=================================================================${NC}"
    echo -e " ${GREEN}A.${NC} 一键无脑部署 (单用户版 - 包含原版 Clash 模板输出)"
    echo -e " ${GREEN}B.${NC} 多用户独立账号部署 (生成独立 Clash 配置文件、彻底隔离)"
    echo -e " ${YELLOW}C.${NC} 修改/更新多用户账号密码 (可提取链接或随时重置成员密码)"
    echo -e " ${YELLOW}D.${NC} 老节点底层网络优化 (无损热升级 BBR+UDP+Swap)"
    echo -e " ${RED}0.${NC} 退出脚本"
    echo -e "${CYAN}=================================================================${NC}"
    
    read -p "👉 请输入选项 [A/B/C/D/0]: " menu_choice
    case $menu_choice in
        A|a) install_single ;;
        B|b) install_multi ;;
        C|c) update_multi_user ;;
        D|d) optimize_old_node ;;
        0) echo -e "${GREEN}感谢使用，再见！${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ 无效的输入，请重新选择！${NC}"; sleep 1 ;;
    esac
done
EOF_SCRIPT
)"
