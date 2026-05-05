# 🚀 Hysteria2 Architect Mega-Prompt & Deployer

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Protocol: QUIC](https://img.shields.io/badge/Protocol-QUIC-red.svg)](https://github.com/apernet/hysteria)
[![OS: Ubuntu 24.04](https://img.shields.io/badge/OS-Ubuntu%2024.04%20LTS-orange.svg)]()

本仓库开源了一套**系统架构师级别的大模型超级提示词 (Mega-Prompt)**，以及通过该提示词生成的**终极版 Hysteria 2 多用户部署面板**。

专为 **1C1G (1核 CPU，1G 内存)** 等处于性能边缘的 VPS 打造，榨干机器性能，构建坚如磐石的代理防线。

---

## 🛡️ 核心底层优化 (The 5 Pillars)

本脚本在底层无差别集成了以下 5 大护城河，确保高并发下的系统稳定性：
1. **【内存护城河】** 强制 2GB Swap 兜底，有效防止晚高峰流量洪峰导致的 OOM 进程自杀。
2. **【CPU 防过载】** 服务端硬锁定 300Mbps 上下行带宽，保护单核 CPU 算力，防止系统假死。
3. **【UDP 终极调优】** 针对 QUIC 协议特性，暴力扩容 UDP 收发缓冲区至 16MB。
4. **【原生加速】** 激活 Ubuntu 24.04 原生内核 BBR + FQ 算法，无需更换第三方内核。
5. **【并发破除】** 将 Ulimit 文件描述符限制提升至 1048576，彻底告别 "Too many open files"。

---

## 🚀 极速上手 (一键部署)

如果你有一台全新的 Ubuntu 24.04 LTS VPS，直接以 `root` 用户执行以下命令：

```bash
wget -O Hysteria2-Perfect.sh [https://raw.githubusercontent.com/yazige/Hysteria2-Ultimate/main/Hysteria2-Perfect.sh](https://raw.githubusercontent.com/yazige/Hysteria2-Ultimate/main/Hysteria2-Perfect.sh) && bash Hysteria2-Perfect.sh
