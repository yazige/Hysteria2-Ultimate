# 🚀 Hysteria2 Architect Mega-Prompt

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Protocol: QUIC](https://img.shields.io/badge/Protocol-QUIC-red.svg)](https://github.com/apernet/hysteria)
[![OS: Ubuntu 24.04](https://img.shields.io/badge/OS-Ubuntu%2024.04%20LTS-orange.svg)]()

本仓库开源了一套**系统架构师级别的大模型超级提示词 (Mega-Prompt)**，以及通过该提示词生成的**终极版 Hysteria 2 多用户部署脚本**。

专为 **1C1G (1核 CPU，1G 内存)** 等处于性能边缘的 VPS 打造，榨干机器的每一滴性能，打造坚如磐石的代理防线。

## 💡 为什么有这个项目？

网络上充斥着各种 Hysteria 2 的一键脚本，但它们大多没有针对“小内存、弱 CPU”的机器进行底层优化。当多人同时连接、流量遭遇洪峰时，往往会出现 OOM（内存溢出）死机、断流或内核崩溃。

本项目不仅提供了一个**带有多用户独立隔离管理面板**的终极脚本，更重要的是，提供了一套**如何调教大语言模型（如 ChatGPT / Claude / Gemini）写出如此硬核脚本的思维框架 (Prompt)**。

## 🛡️ 核心底层优化 (The 5 Pillars)

无论是脚本还是 Prompt，都严格贯彻了以下 5 大底层优化护城河：
1. **【内存护城河】** 强制 2GB Swap 兜底，告别晚高峰 OOM。
2. **【CPU 防过载】** 服务端硬锁定 300Mbps 上下行，防止单核 CPU 算力打满导致系统挂死。
3. **【极速防漏包】** 针对 QUIC 协议特性，暴力扩容 UDP 收发缓冲区至 16MB。
4. **【原生拥塞控制】** 激活 Ubuntu 24.04 原生内核 BBR + FQ，拒绝第三方内核编译风险。
5. **【海量并发破除】** 修改 Ulimit 软硬限制与 Systemd 全局设置，突破 1024 限制，提升至 104 万文件描述符。

## 🛠️ 如何使用？

本仓库为你提供了两条路径：

### 路径一：我想学习 Prompt 工程 (授人以渔)
1. 打开 [`Hysteria2-MegaPrompt.md`](./Hysteria2-MegaPrompt.md) 文件。
2. 复制全部内容。
3. 发送给你最喜欢的大语言模型（推荐使用最新的 Claude, GPT 或 Gemini最新模型）。
4. 观察 AI 是如何像一位资深架构师一样，为你一步步输出原理解析和终极代码的。

### 路径二：我是运维/实战派，我要直接用脚本 (授人以鱼)
如果你有一台全新的 Ubuntu 24.04 VPS，直接以 `root` 用户执行以下命令，即可一键拉取并运行面板脚本：

```bash
wget -O Hysteria2-Perfect.sh [https://raw.githubusercontent.com/yazige/Hysteria2-Ultimate/main/Hysteria2-Perfect.sh](https://raw.githubusercontent.com/yazige/Hysteria2-Ultimate/main/Hysteria2-Perfect.sh) && bash Hysteria2-Perfect.sh