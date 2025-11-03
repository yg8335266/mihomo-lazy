# mihomo 懒人版

<div align="center">

**基于 mihomo 内核的一键部署方案 | 包含完整配置和 Web UI 控制面板**

[![最新版本](https://img.shields.io/github/v/release/hubentuan/mihomo-lazy)](https://github.com/hubentuan/mihomo-lazy/releases/latest)
[![下载量](https://img.shields.io/github/downloads/hubentuan/mihomo-lazy/total)](https://github.com/hubentuan/mihomo-lazy/releases)
[![Star](https://img.shields.io/github/stars/hubentuan/mihomo-lazy)](https://github.com/hubentuan/mihomo-lazy)

</div>

---

## ✨ 功能特点

- 🚀 **一键部署** - 双击即用，无需复杂配置
- 🎨 **精美面板** - 内置 Zashboard Web UI 控制面板
- 🔄 **智能清理** - 自动清理旧进程，避免端口冲突
- ⚡ **开机自启** - 支持设置开机自动启动
- 📊 **实时监控** - 启动日志实时显示，一键停止查看
- 📁 **任意路径** - 支持安装到任意目录，不限制盘符

---

## 📥 下载安装

### 1️⃣ 下载完整版

> ⚠️ 由于 mihomo.exe 核心文件较大（32MB），完整版仅在 Release 提供下载

前往 **[Releases](https://github.com/hubentuan/mihomo-lazy/releases/latest)** 页面下载 `mihomo-lazy.zip`

### 2️⃣ 解压文件

将压缩包解压到任意目录（**建议使用英文路径**）

### 3️⃣ 首次配置

1. 打开 `config.yaml` 文件，填写你的**机场订阅链接**
2. **右键** `首次安装.bat`，选择 **"以管理员身份运行"**
3. 等待启动日志稳定，按 **Enter** 键退出查看
4. 完成！🎉

---

## 🎯 快速使用

### 日常启动
**双击** `start-mihomo.vbs` 即可后台启动

### 访问控制面板

| 方式 | 地址 | 特点 |
|------|------|------|
| **本地面板** ⭐ | http://127.0.0.1:9090/ui/zashboard | 无需联网，速度快，隐私好 |
| **在线面板** | https://zash.xiaoyaogpt.com | 任意设备访问，方便记忆 |

### 常用操作
```
✅ 启动服务    → 双击 start-mihomo.vbs
⏹️ 停止服务    → 双击 停止运行.bat
🔄 重启服务    → 双击 重启.bat
🔌 开启代理    → 双击 开启系统代理.bat
🔌 关闭代理    → 双击 关闭系统代理.bat
⚙️ 开机自启    → 双击 开启开机自动.bat
❌ 取消自启    → 双击 关闭开机自动.bat
📥 更新配置    → 双击 更新配置.bat
```

---

## 📁 文件结构
```
mihomo懒人版/
├── 📦 mihomo.exe              # 核心程序（32MB，仅在 Release 提供）
├── ⚙️ config.yaml             # 配置文件（需填写订阅链接）
│
├── 🔧 首次安装.bat             # 首次安装脚本（必须先运行）
├── ▶️ start-mihomo.vbs        # 日常启动脚本（自动清理旧进程）
├── ⏹️ 停止运行.bat            # 停止服务
├── 🔄 重启.bat                # 重启服务
│
├── 🔌 开启系统代理.bat         # 手动开启系统代理
├── 🔌 关闭系统代理.bat         # 手动关闭系统代理
│
├── ⚙️ 开启开机自动.bat         # 设置开机自启动
├── ❌ 关闭开机自动.bat         # 取消开机自启动
│
├── 📥 更新配置.bat             # 从 Gist 下载最新配置
│
├── 📝 启动脚本-路径模板.bat     # 路径配置版启动脚本（适用于路径问题）
├── 📝 start-mihomo-路径配置版.vbs  # 路径配置版VBS脚本（静默启动）
├── 📖 路径配置说明.md          # 路径配置详细说明文档
│
└── 📂 zashboard/             # Web UI 文件夹
```

---

## 🎨 控制面板功能

<table>
<tr>
<td width="50%">

### 📊 实时监控
- 上传/下载速度
- 实时流量统计
- 活跃连接数

### 🌐 节点管理
- 快速切换节点
- 延迟测试
- 节点分组

</td>
<td width="50%">

### 📋 规则管理
- 自定义规则
- 规则优先级
- 规则集管理

### 📝 日志查看
- 实时请求日志
- 连接详情
- 调试信息

</td>
</tr>
</table>

---

## ⚙️ 配置说明

### 默认端口
```yaml
混合端口（HTTP + SOCKS5）：7890
Web UI 控制面板：9090
```

### 修改端口

编辑 `config.yaml` 文件：
```yaml
mixed-port: 7890                        # 代理端口
external-controller: 127.0.0.1:9090    # 面板端口
```

修改后运行 `重启.bat` 使配置生效

### 从 Gist 更新配置

如果你将配置文件托管在 GitHub Gist，可以使用 `更新配置.bat` 快速下载并覆盖本地配置：

#### 使用步骤：

1. **上传配置到 Gist**
   - 前往 https://gist.github.com
   - 创建新 Gist，文件名设为 `config.yaml`
   - 粘贴你的配置内容并保存

2. **获取 Gist 原始地址**
   - 在 Gist 页面点击右上角 **"Raw"** 按钮
   - 复制浏览器地址栏的完整 URL
   - 格式类似：`https://gist.githubusercontent.com/username/abc123.../raw/config.yaml`

3. **配置脚本**
   - 右键编辑 `更新配置.bat`
   - 找到 `GIST_URL` 这一行
   - 替换为你刚才复制的 URL

4. **使用**
   - 双击 `更新配置.bat` 即可自动下载最新配置
   - 脚本会自动备份旧配置（保存为 `config.yaml.backup`）
   - 下载完成后运行 `重启.bat` 使配置生效

#### 优势：
- ✅ 多设备同步配置文件
- ✅ 版本控制，可查看历史修改
- ✅ 一键更新，无需手动复制粘贴
- ✅ 自动备份，更新失败自动恢复

---

## ❓ 常见问题

<details>
<summary><b>Q: 为什么仓库里没有 mihomo.exe？</b></summary>

由于文件较大（32MB），GitHub 仓库不适合直接存放。请前往 [Releases](https://github.com/hubentuan/mihomo-lazy/releases/latest) 页面下载完整压缩包。
</details>

<details>
<summary><b>Q: 首次安装失败怎么办？</b></summary>

1. 确保以**管理员身份**运行 `首次安装.bat`
2. 检查 `config.yaml` 中是否正确填写了订阅链接
3. 查看启动日志中的错误提示
4. 确认端口 7890 和 9090 未被占用
5. 检查防火墙是否拦截
</details>

<details>
<summary><b>Q: 如何更新配置？</b></summary>

直接编辑 `config.yaml` 文件，然后运行 `重启.bat` 即可。
</details>

<details>
<summary><b>Q: 启动后没反应？</b></summary>

1. 检查任务管理器是否有 `mihomo.exe` 进程
2. 访问 http://127.0.0.1:9090/ui/zashboard 检查面板
3. 尝试以管理员权限重新运行
4. 查看防火墙是否拦截程序
</details>

<details>
<summary><b>Q: 运行路径是 C:\Windows\System32\cmd.exe 导致无法启动？</b></summary>

这是 Windows 批处理的常见问题。当工作目录不正确时，脚本无法找到 mihomo.exe 和 config.yaml 文件。

**解决方法**：使用**路径配置版脚本**

1. 使用 `启动脚本-路径模板.bat`（带窗口）或 `start-mihomo-路径配置版.vbs`（静默后台）
2. 用记事本或 VS Code 打开脚本文件
3. 在文件开头的【路径配置区域】填写实际路径
4. 保存后双击运行

详细说明请查看 **[路径配置说明.md](路径配置说明.md)**

**配置示例**：
```batch
set "MIHOMO_DIR=D:\Tools\mihomo-lazy"
set "MIHOMO_EXE=D:\Tools\mihomo-lazy\mihomo.exe"
set "CONFIG_FILE=D:\Tools\mihomo-lazy\config.yaml"
```

</details>

<details>
<summary><b>Q: 本地面板和在线面板有什么区别？</b></summary>

- **本地面板**：无需联网，速度快，数据不经过第三方服务器，隐私性更好
- **在线面板**：方便记忆，可以在任何设备上访问，但需要联网
</details>

<details>
<summary><b>Q: 如何确认服务已启动？</b></summary>

三种方式任选其一：
1. 访问 http://127.0.0.1:9090/ui/zashboard，能打开则服务正常
2. 查看任务管理器是否有 `mihomo.exe` 进程
3. 检查系统代理设置是否为 `127.0.0.1:7890`
</details>

<details>
<summary><b>Q: 如何更新 mihomo 内核？</b></summary>

从 [mihomo 官方仓库](https://github.com/MetaCubeX/mihomo/releases) 下载最新版 `mihomo.exe`，替换原文件即可。
</details>

<details>
<summary><b>Q: 更新配置.bat 下载失败怎么办？</b></summary>

可能原因及解决方法：
1. **Gist 地址未配置或错误**：检查脚本中的 `GIST_URL` 是否正确
2. **网络问题**：确认能正常访问 GitHub，必要时先启动代理
3. **Gist 不存在**：在浏览器中测试能否打开该 Gist 的 Raw 地址
4. **下载失败自动恢复**：脚本会自动恢复备份的旧配置，不用担心配置丢失
</details>

<details>
<summary><b>Q: 批处理文件出现中文乱码怎么办？</b></summary>

所有 .bat 文件已使用 **UTF-8 with BOM** 编码保存，配合文件开头的 `chcp 65001` 命令，可在中文 Windows 系统中正确显示。

如果编辑批处理文件后出现乱码：
1. **使用正确的编辑器**：建议使用 Notepad++、VS Code 等支持编码选择的编辑器
2. **保存时选择编码**：确保保存为 **UTF-8 with BOM** 格式
3. **VS Code 设置**：右下角点击编码 → 选择 "通过编码保存" → 选择 "UTF-8 with BOM"
4. **Notepad++ 设置**：编码菜单 → 选择 "以UTF-8-BOM格式编码"

⚠️ **不要使用 Windows 记事本编辑**，可能导致编码问题。
</details>

---

## ⚠️ 注意事项

> ⚡ **首次运行必须以管理员权限运行** `首次安装.bat`
> 
> 🔥 请确保防火墙允许程序运行
> 
> 📡 首次安装后会自动设置系统代理
> 
> 🔄 `start-mihomo.vbs` 会自动清理旧进程，确保只运行一个实例
> 
> 📁 支持安装到任意路径，不再限制 C 盘
> 
> 📝 **所有 .bat 文件已使用 UTF-8 with BOM 编码**，确保在中文 Windows 系统中正确显示

---

## 🔗 相关链接

| 项目 | 链接 |
|------|------|
| 📦 **本项目** | https://github.com/hubentuan/mihomo-lazy |
| 🔧 **Mihomo 内核** | https://github.com/MetaCubeX/mihomo |
| 🎨 **Zashboard 面板** | https://github.com/Zephyruso/zashboard |
| 🌐 **本地面板** | http://127.0.0.1:9090/ui/zashboard |
| 🌍 **在线面板** | https://zash.xiaoyaogpt.com |

---

## 📊 版本历史

查看 [Releases](https://github.com/hubentuan/mihomo-lazy/releases) 获取完整更新日志

---

## ⭐ Star 历史

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=hubentuan/mihomo-lazy&type=Date)](https://star-history.com/#hubentuan/mihomo-lazy&Date)

</div>

---

## 💬 反馈与支持

遇到问题或有建议？欢迎在 [Issues](https://github.com/hubentuan/mihomo-lazy/issues) 反馈！

---

<div align="center">

**⭐ 如果觉得项目不错，请给个 Star 支持一下！**

Made with ❤️ by [hubentuan](https://github.com/hubentuan)

</div>
