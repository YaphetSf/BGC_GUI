# SimpleBGC GUI macOS 安装指南

本指南将帮助你在 macOS 上安装并运行 SimpleBGC GUI，特别是 Apple Silicon (M1/M2/M3) Mac。

## ⚠️ 重要提示

如果你使用的是 **Apple Silicon Mac**（M1/M2/M3芯片），你需要安装 **x86_64 架构的 Java**（不是 ARM64），因为该应用使用的串口库只支持 x86_64 架构。

## 📋 系统要求

- macOS 10.13 或更高版本
- x86_64 版本的 Java 8 或更高版本
- 对于 Apple Silicon Mac：需要 Rosetta 2（通常已预装）

## 🚀 快速安装步骤

### 第1步：检测你的 Mac 架构

打开 Terminal，运行：
```bash
uname -m
```

- 如果是 `arm64`，你是 Apple Silicon Mac，需要 x86_64 Java
- 如果是 `x86_64`，你是 Intel Mac，可以安装任意 Java

### 第2步：下载并安装 Java

**推荐的 Java 下载源：**

1. **Azul Zulu JDK**（推荐）
   - 访问：https://www.azul.com/downloads/?package=jdk
   - 选择版本：**Java 8** 或 **Java 17**（LTS 版本推荐）
   - **重要**：下载 **"macOS x64 DMG Installer"**（不是 ARM64）
   - 如果是 Apple Silicon Mac，你会看到两个选项：
     - ✅ **macOS x64 DMG Installer** ← 选这个！
     - ❌ macOS ARM64 DMG Installer ← 不要选这个

2. **Temurin (AdoptOpenJDK)**
   - 访问：https://adoptium.net/
   - 选择：macOS → x64 → JDK 8 或 17
   - 下载 DMG 文件

3. **Oracle JDK**（不推荐，需要账户）
   - 访问：https://www.oracle.com/java/technologies/downloads/
   - 选择 macOS x64 版本

### 第3步：安装 Java

1. 双击下载的 DMG 文件
2. 运行安装程序（.pkg 文件）
3. 按照安装向导完成安装
4. 通常 Java 会安装到：`/Library/Java/JavaVirtualMachines/`

### 第4步：验证安装

打开 Terminal，运行：

```bash
/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/bin/java -version
```

或者（如果是其他版本）：

```bash
/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home/bin/java -version
```

你应该看到类似：
```
openjdk version "1.8.0_xxx"
OpenJDK Runtime Environment ...
OpenJDK 64-Bit Server VM ...
```

然后检查是否是 x86_64：
```bash
file /Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/bin/java
```

应该显示：`Mach-O 64-bit executable x86_64`（不是 ARM64）

### 第5步：下载 SimpleBGC GUI

1. 下载 SimpleBGC GUI 到你的 Mac
2. 解压到任意位置，例如：`~/Downloads/SimpleBGC_GUI_2_70b0`

### 第6步：运行应用

打开 Terminal，进入解压后的目录：

```bash
cd ~/Downloads/SimpleBGC_GUI_2_70b0
```

给脚本添加执行权限：

```bash
chmod +x run_mac.sh
```

运行应用：

```bash
./run_mac.sh
```

如果一切正常，SimpleBGC GUI 应该会启动！

## 🔧 故障排除

### 问题1：找不到 x86_64 Java

**错误信息：**
```
ERROR: Could not find x86_64 Java installation!
```

**解决方法：**
1. 确认你下载的是 x64 版本（不是 ARM64）
2. 检查安装路径是否正确
3. 重新安装 Java

### 问题2：找不到串口

**错误信息：**
```
NoClassDefFoundError: Could not initialize class gnu.io.RXTXCommDriver
```

**解决方法：**
1. 确认你使用的是 x86_64 Java
2. 如果是 Apple Silicon Mac，检查是否安装了 Rosetta 2：
   ```bash
   arch -x86_64 uname -m  # 应该显示: x86_64
   ```
3. 如果还是不行，尝试创建 `/var/lock` 目录：
   ```bash
   sudo mkdir /var/lock
   sudo chmod 777 /var/lock
   ```

### 问题3：串口设备没有显示

**检查设备是否被识别：**

```bash
ls /dev/tty.*
ls /dev/cu.*
```

你应该看到类似 `/dev/tty.usbserial-0001` 或 `/dev/cu.usbserial-0001` 的设备。

如果没有显示：
1. 检查 USB 连接
2. 安装 USB 转串口驱动（如 CP2102、FTDI 等）
3. 检查设备管理器中是否有未识别的设备

### 问题4：权限错误

**错误信息：**
```
Permission denied
```

**解决方法：**
```bash
sudo chmod 777 /var/lock
```

或者添加到 dialout 组（如果存在）：
```bash
sudo dseditgroup -o edit -a $USER -t user dialout
```

### 问题5：我需要使用哪个脚本？

我们有多个脚本：
- **`run_mac.sh`** - 主要启动脚本，自动检测架构和 Java
- **`run.sh`** - 原始脚本，可能需要手动指定 Java
- **`run_x86.sh`** - x86_64 专用脚本

**推荐使用 `run_mac.sh`**，它会自动处理所有情况。

## 📝 高级使用

### 查看详细日志

```bash
./run_mac.sh DEBUG_MODE
```

### 手动指定 Java 路径

如果你有多个 Java 版本：

```bash
/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/bin/java -jar SimpleBGC_GUI.jar
```

### Apple Silicon Mac + Rosetta 2

如果你确定要使用 Rosetta 2：

```bash
arch -x86_64 ./run_mac.sh
```

## 🎯 总结

对于 Apple Silicon Mac 用户：
1. ✅ 安装 x86_64 Java（不是 ARM64）
2. ✅ 使用提供的 `run_mac.sh` 脚本
3. ✅ 脚本会自动使用 Rosetta 2

对于 Intel Mac 用户：
1. ✅ 安装任意架构的 Java
2. ✅ 使用 `run_mac.sh` 或 `run.sh`

## 📞 仍然有问题？

如果以上方法都无法解决问题，请：
1. 检查你的设备驱动是否正确安装
2. 尝试在不同版本的 Java 上运行
3. 查看应用日志输出
4. 联系设备制造商获取技术支持

## 🔗 有用的链接

- Java 下载：https://www.azul.com/downloads/
- USB 转串口驱动：http://www.silabs.com/products/mcu/pages/usbtouartbridgevcpdrivers.aspx
- CP2102 驱动：https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers

---

祝你使用愉快！🎉


	<string>SimpleBGC</string>
	<key>CFBundleIconName</key>
	<string>SimpleBGC</string>
	
