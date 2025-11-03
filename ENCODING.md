# 批处理文件编码说明

## 问题背景

Windows 中文系统的 `cmd.exe` 默认使用 **GBK/CP936** 编码（代码页936），而本项目的批处理文件包含大量中文字符和 Unicode 框线字符（如 `╔ ═ ╗`）。如果文件编码不正确，会导致严重的乱码问题。

## 解决方案

本项目的所有 `.bat` 文件现已统一使用 **UTF-8 with BOM** 编码，并在文件开头添加 `chcp 65001` 命令：

```batch
@echo off
chcp 65001 >nul
```

### 为什么是 UTF-8 with BOM？

1. **UTF-8 with BOM** - Windows cmd.exe 通过 BOM（Byte Order Mark: `EF BB BF`）自动识别文件为 UTF-8
2. **chcp 65001** - 切换命令提示符到 UTF-8 代码页，确保输出正确显示
3. **CRLF 行结束符** - Windows 批处理文件必须使用 `\r\n` (CR+LF) 行结束符

## 验证文件编码

可以使用以下命令验证文件编码：

### Linux/macOS
```bash
# 检查 BOM 标记
head -c 3 "首次安装.bat" | od -A x -t x1z

# 应显示: ef bb bf (UTF-8 BOM)
```

### Windows PowerShell
```powershell
# 读取文件的前3字节
$bytes = [System.IO.File]::ReadAllBytes("首次安装.bat")
$bytes[0..2] | Format-Hex

# 应显示: EF BB BF
```

## 编辑批处理文件

如果需要编辑 `.bat` 文件，请务必保持 UTF-8 with BOM 编码：

### VS Code
1. 打开文件
2. 右下角点击编码（如果显示 "UTF-8"）
3. 选择 "通过编码保存"
4. 选择 "UTF-8 with BOM"

### Notepad++
1. 打开文件
2. 编码菜单 → "以UTF-8-BOM格式编码"
3. 保存文件

### ⚠️ 不推荐
- **Windows 记事本** - 编码处理不可靠
- **普通 UTF-8（无 BOM）** - cmd.exe 可能无法正确识别

## 技术细节

### 文件结构
```
[EF BB BF]           ← UTF-8 BOM (3字节)
@echo off[0D 0A]     ← 命令 + CRLF
chcp 65001 >nul[0D 0A]
...其他内容...
```

### 为什么需要 BOM？

Windows cmd.exe 不像 Linux shell 那样默认假设 UTF-8，它需要明确的标识：
- **无 BOM** → cmd.exe 使用系统默认代码页（GBK）解析 → 中文乱码
- **有 BOM** → cmd.exe 识别为 UTF-8 → 配合 chcp 65001 → 正确显示

### 为什么需要 CRLF？

Windows 的命令解释器要求批处理文件使用 CRLF (`\r\n`, 即 `0D 0A`)：
- **仅 LF** (`\n`) → 在某些 Windows 版本中可能导致解析错误
- **CRLF** (`\r\n`) → 标准 Windows 文本格式

## 问题排查

如果遇到乱码问题：

1. **检查 BOM**
   ```bash
   hexdump -C "文件.bat" | head -1
   # 应显示: 00000000  ef bb bf ...
   ```

2. **检查行结束符**
   ```bash
   file "文件.bat"
   # 应包含: UTF-8 (with BOM), with CRLF line terminators
   ```

3. **检查 chcp 命令**
   确保文件开头有 `chcp 65001 >nul`

## 批量转换脚本

如需批量转换文件到正确编码：

```python
import glob

for file in glob.glob('*.bat'):
    # 读取内容
    with open(file, 'r', encoding='utf-8-sig', newline='') as f:
        content = f.read()
    
    # 统一行结束符为 CRLF
    content = content.replace('\r\n', '\n').replace('\n', '\r\n')
    
    # 写入 UTF-8 with BOM
    with open(file, 'wb') as f:
        f.write(b'\xef\xbb\xbf')  # BOM
        f.write(content.encode('utf-8'))
```

## 参考资料

- [Microsoft: chcp 命令](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/chcp)
- [UTF-8 BOM 说明](https://en.wikipedia.org/wiki/Byte_order_mark#UTF-8)
- [Windows 批处理编码最佳实践](https://stackoverflow.com/questions/388490/unicode-characters-in-windows-command-line-how)
