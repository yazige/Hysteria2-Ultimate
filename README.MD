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
```

注：执行后将进入可视化彩色交互面板。日常管理可随时通过 bash Hysteria2-Perfect.sh 唤出。

##  🎛️ 面板菜单解析与业务场景应用
本面板提供四个核心选项，覆盖从个人使用到团队运维的全场景：

🟢 A. 一键无脑部署 (单用户版)
适合场景：个人独享、快速测试。

业务优势：继承最纯粹的架构优化，一键生成随机高强度密码。

输出：自动打印 Shadowrocket 链接 及 Clash Verge YAML 完整配置。

🟢 B. 多用户独立账号部署 (彻底隔离分发)
适合场景：工作室、中小团队、跨境电商运营组。

业务优势：独立账密，彻底隔离。一人离职只需重置单人密码，不影响全员。

输出：循环为每个成员生成独立的 Clash 配置文件区块。你可以直接将对应的代码块发给特定的成员，实现物理隔离分发。

🟡 C. 修改/更新多用户账号密码 (精准管控)
适合场景：人员流动、权限回收、账号安全重置。

操作逻辑：输入成员编号即可重置密码。

优势：无损热更新。服务平滑重启，其他在线成员完全无感，不会断网。

🟡 D. 老节点底层网络优化 (无损热升级)
适合场景：已安装 HY2 但经常卡顿、断流或死机的老节点。

效果：不破坏原有配置，原地升级 Swap、UDP 缓冲区、并发限制等架构级优化。

##  🧠 进阶：学习 Mega-Prompt 工程
如果你对如何通过 Prompt 工程调教 AI 输出此类硬核代码感兴趣，请查看 Hysteria2-MegaPrompt.md。该文件展示了如何定义角色、设定硬性指标以及构建自动化输出规范。

##  📝 License
本项目基于 MIT License 开源。
