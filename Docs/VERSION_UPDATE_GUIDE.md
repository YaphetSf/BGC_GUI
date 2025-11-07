# 如何为新版本创建启动脚本

当你获得新版本的 SimpleBGC GUI 时，按照以下步骤创建新的启动脚本：

## 📝 需要修改的地方

### 1. **脚本文件名**
- 将 `run_frw_2_73_8.sh` 改为新版本名称，例如：`run_frw_X_X_X.sh`（X是版本号）

### 2. **脚本中的版本号显示**（3处）

**位置 1：脚本开头的注释**
```bash
# Run SimpleBGC GUI 2.73.8 on macOS
```
改为：`# Run SimpleBGC GUI X.X.X on macOS`

**位置 2：echo 输出的版本信息**
```bash
echo "SimpleBGC GUI 2.73.8 Launcher for macOS"
```
改为：`echo "SimpleBGC GUI X.X.X Launcher for macOS"`

**位置 3：启动信息**
```bash
echo -e "${GREEN}Starting SimpleBGC GUI 2.73.8...${NC}"
```
改为：`echo -e "${GREEN}Starting SimpleBGC GUI X.X.X...${NC}"`

### 3. **目录名称检查**（可选，但推荐）

如果新版本的目录名称不同，修改错误提示：
```bash
echo "Please run this script from the SimpleBGC_GUI_2_73_8 directory"
```
改为对应的新目录名。

## 🔧 完整步骤示例

假设你获得新版本 `SimpleBGC_GUI_2_80_0`：

1. **复制旧脚本**
   ```bash
   cp run_frw_2_73_8.sh SimpleBGC_GUI_2_80_0/run_frw_2_80_0.sh
   ```

2. **修改脚本中的版本号**（3处）
   - 将 `2.73.8` 替换为 `2.80.0`
   - 将 `2_73_8` 替换为 `2_80_0`（在目录名检查中）

3. **添加执行权限**
   ```bash
   chmod +x SimpleBGC_GUI_2_80_0/run_frw_2_80_0.sh
   ```

## ✅ 不需要修改的地方

这些部分对所有版本都一样，**不需要修改**：

- ✅ Java 路径检测逻辑
- ✅ 架构检测（ARM64 vs x86_64）
- ✅ Rosetta 2 使用逻辑
- ✅ Java 启动参数（-D参数）
- ✅ 错误处理逻辑
- ✅ 颜色输出设置

## 🎯 快速修改命令

如果你想快速修改版本号，可以使用 sed：

```bash
# 假设旧版本是 2.73.8，新版本是 2.80.0
sed -i '' 's/2\.73\.8/2.80.0/g' run_frw_2_80_0.sh
sed -i '' 's/2_73_8/2_80_0/g' run_frw_2_80_0.sh
```

## 📋 检查清单

创建新脚本后，确认：
- [ ] 脚本文件名包含版本号
- [ ] 3处版本号显示已更新
- [ ] 目录名检查已更新（如果有变化）
- [ ] 脚本有执行权限（`chmod +x`）
- [ ] 在新版本目录中运行脚本测试

## 💡 提示

如果新版本的目录结构发生变化（比如 JAR 文件位置不同），可能还需要检查：
- JAR 文件名是否还是 `SimpleBGC_GUI.jar`
- lib 目录位置是否改变
- log4j.properties 文件位置

但通常情况下，这些都不会改变，只需要修改版本号即可！
