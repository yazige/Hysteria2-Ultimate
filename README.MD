# 🚀 Hysteria2 Architect Mega-Prompt & Deployer

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Protocol: QUIC](https://img.shields.io/badge/Protocol-QUIC-red.svg)](https://github.com/apernet/hysteria)
[![OS: Ubuntu 24.04](https://img.shields.io/badge/OS-Ubuntu%2024.04%20LTS-orange.svg)]()

本仓库开源了一套**系统架构师级别的大模型超级提示词 (Mega-Prompt)**，以及通过该提示词生成的**终极版 Hysteria 2 多用户部署面板**。

专为 **1C1G (1核 CPU，1G 内存)** 等处于性能边缘的 VPS 打造，榨干机器性能，构建坚如磐石的代理防线。

软件适配：
软件适配:
- **手机端**: ios 【小火箭Shadowrocket、[V2box](https://apps.apple.com/us/app/v2box-v2ray-client/id6446814690)】，安卓 【[Neko Box](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)】
- **PC端**: windows/Mac 【[Clash Verge](https://github.com/clash-verge-rev/clash-verge-rev/releases)、[hiddify-app](https://github.com/hiddify/hiddify-app)】
---

## 🛡️ 核心底层优化

本脚本在底层无差别集成了以下优化，确保高并发下的系统稳定性：

* **⚡ 算力大解放（原生端口跳跃）：** 废弃了传统的、高 CPU 消耗的 `iptables` 流量重定向转发。改用 Hysteria 2 原生的高性能多端口监听（监听 `:443,40000-50000`），将每一分算力都留给数据加解密，彻底解放 1核 CPU。
* **🛡️ 幽灵服务自愈（零端口冲突）：** 很多 VPS 连不上是因为之前的旧代理程序死死霸占着 443 端口。本脚本在安装和优化前，会自动检索并彻底注销、清理系统中名为 `hysteria` 的老旧冲突服务，实现 100% 顺滑升级。
* **🌊 极速防漏（16MB UDP 缓冲区）：** 针对 GFW 精准阻断大流量 UDP 的特性，将系统套接字最大接收与发送缓冲区（`rmem_max`/`wmem_max`）扩容至 16MB，应对 1Gbps 带宽带来的瞬时数据洪峰，极大降低丢包率和连接卡顿。
* **🚦 多用户独立 QoS（防止资源挤兑）：** 采用 Hysteria 2 的 `userpass` 隔离认证。脚本内置了**强制限速算法**（默认为每个成员上/下行限速 30 Mbps），防止个别成员因大文件下载瞬间跑满 CPU 或榨干服务器带宽，保障全员丝滑体验。
* **🧩 并发解锁与内存兜底：** * 自动将系统的最大连接数（文件描述符限制）从 1024 强力破除至 **104 万**，满足多用户、多设备同时在线的大流量高并发请求。
  * 自动划分 2GB 的 SSD 虚拟交换分区 (Swap) 进行内存兜底，彻底预防 1G 内存机器因高并发 OOM（内存溢出）导致的服务闪退。
* **🧱 自动打通本地防火墙：** 无论系统使用的是 `UFW` 还是原生 `iptables`，脚本部署时会自动、强制放行 443 端口和 40000-50000 端口段，再也不会出现“服务正常却全球 Timeout”的尴尬。

---

## 🚀 极速上手 (一键部署)

如果你有一台全新的 Ubuntu 24.04 LTS VPS，直接以 `root` 用户执行以下命令：

```bash
wget -O Hysteria2-Perfect.sh https://raw.githubusercontent.com/yazige/Hysteria2-Ultimate/main/Hysteria2-Perfect.sh && sed -i 's/\r//g' Hysteria2-Perfect.sh && bash Hysteria2-Perfect.sh
```

*注：执行后将进入可视化彩色交互面板。日常管理可随时通过 `bash Hysteria2-Perfect.sh` 唤出。*

---

## 🎛️ 面板菜单解析与业务场景应用

本面板提供四个核心选项，覆盖从个人使用到团队运维的全场景：

### 🟢 A. 一键无脑部署 (单用户版)

- **适合场景**：个人独享、快速测试。
- **业务优势**：继承最纯粹的架构优化，一键生成随机高强度密码。
- **输出**：自动打印 **Shadowrocket 链接** 及 **Clash Verge YAML 完整配置**。

### 🟢 B. 多用户独立账号部署 (彻底隔离分发)

- **适合场景**：工作室、中小团队、跨境电商运营组。
- **业务优势**：**独立账密，彻底隔离**。一人离职只需重置单人密码，不影响全员。
- **输出**：循环为每个成员生成独立的 **Clash 配置文件区块**。你可以直接将对应的代码块发给特定的成员，实现物理隔离分发。

### 🟡 C. 修改/更新多用户账号密码 (精准管控)

- **适合场景**：人员流动、权限回收、账号安全重置。
- **操作逻辑**：输入成员编号即可重置密码。
- **优势**：**无损热更新**。服务平滑重启，其他在线成员完全无感，不会断网。

### 🟡 D. 老节点底层网络优化 (无损热升级)

- **适合场景**：已安装 HY2 但经常卡顿、断流或死机的老节点。
- **效果**：不破坏原有配置，原地升级 Swap、UDP 缓冲区、并发限制等架构级优化。

---

## 🧠 进阶：学习 Mega-Prompt 工程

如果你对如何通过 Prompt 工程调教 AI 输出此类硬核代码感兴趣，请查看 [`Hysteria2-MegaPrompt.md`](./Hysteria2-MegaPrompt.md)。该文件展示了如何定义角色、设定硬性指标以及构建自动化输出规范。

---

## 📝 License

本项目基于 [MIT License](https://opensource.org/licenses/MIT) 开源。
