Set ws = CreateObject("Wscript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' ════════════════════════════════════════════════════════════════
'  【路径配置区域 - 请根据实际情况填写】
' ════════════════════════════════════════════════════════════════
' 
' 说明：请将下面的占位符替换为实际路径
' 
' 示例：
'   mihomoDir = "D:\Tools\mihomo-lazy"
'   mihomoExe = "D:\Tools\mihomo-lazy\mihomo.exe"
'   configFile = "D:\Tools\mihomo-lazy\config.yaml"
' 
' ════════════════════════════════════════════════════════════════

' Mihomo 安装目录（存放所有文件的文件夹）
mihomoDir = "【请填写：如 D:\Tools\mihomo-lazy】"

' mihomo.exe 可执行文件完整路径
mihomoExe = "【请填写：如 D:\Tools\mihomo-lazy\mihomo.exe】"

' config.yaml 配置文件完整路径（相对于 mihomoDir）
configFile = "config.yaml"

' ════════════════════════════════════════════════════════════════
'  以下为自动执行部分，无需修改
' ════════════════════════════════════════════════════════════════

' 检查路径是否已配置
If mihomoDir = "【请填写：如 D:\Tools\mihomo-lazy】" Then
    MsgBox "错误：路径尚未配置" & vbCrLf & vbCrLf & _
           "请打开本脚本文件，在顶部【路径配置区域】填写实际路径" & vbCrLf & vbCrLf & _
           "需要配置的变量：" & vbCrLf & _
           "  1. mihomoDir - Mihomo 安装目录" & vbCrLf & _
           "  2. mihomoExe - mihomo.exe 完整路径" & vbCrLf & vbCrLf & _
           "配置示例：" & vbCrLf & _
           "  mihomoDir = ""D:\Tools\mihomo-lazy""" & vbCrLf & _
           "  mihomoExe = ""D:\Tools\mihomo-lazy\mihomo.exe""", _
           vbCritical, "Mihomo 路径配置"
    WScript.Quit
End If

' 检查目录是否存在
If Not fso.FolderExists(mihomoDir) Then
    MsgBox "错误：Mihomo 目录不存在" & vbCrLf & vbCrLf & _
           "配置的目录：" & mihomoDir & vbCrLf & vbCrLf & _
           "请检查：" & vbCrLf & _
           "  1. 目录路径是否正确" & vbCrLf & _
           "  2. 目录是否存在", _
           vbCritical, "Mihomo 启动错误"
    WScript.Quit
End If

' 检查 mihomo.exe 是否存在
If Not fso.FileExists(mihomoExe) Then
    MsgBox "错误：未找到 mihomo.exe" & vbCrLf & vbCrLf & _
           "配置的路径：" & mihomoExe & vbCrLf & vbCrLf & _
           "请检查：" & vbCrLf & _
           "  1. 文件路径是否正确" & vbCrLf & _
           "  2. 文件是否存在", _
           vbCritical, "Mihomo 启动错误"
    WScript.Quit
End If

' 检查配置文件是否存在
configPath = mihomoDir & "\" & configFile
If Not fso.FileExists(configPath) Then
    MsgBox "错误：未找到 config.yaml" & vbCrLf & vbCrLf & _
           "配置的路径：" & configPath & vbCrLf & vbCrLf & _
           "请检查：" & vbCrLf & _
           "  1. 文件路径是否正确" & vbCrLf & _
           "  2. 文件是否存在", _
           vbCritical, "Mihomo 启动错误"
    WScript.Quit
End If

' ========================================
' 杀死所有正在运行的 mihomo.exe 进程
' ========================================
Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
Set colProcesses = objWMI.ExecQuery("Select * from Win32_Process Where Name = 'mihomo.exe'")

If colProcesses.Count > 0 Then
    ' 发现运行中的 mihomo 进程，逐个终止
    For Each objProcess in colProcesses
        objProcess.Terminate()
    Next
    
    ' 等待进程完全结束
    WScript.Sleep 1000
End If

' ========================================
' 以管理员权限启动新的 mihomo 进程
' ========================================
Set objShell = CreateObject("Shell.Application")

' 构建启动参数：-d "安装目录" -f "配置文件"
startArgs = "-d """ & mihomoDir & """ -f """ & configPath & """"

' 启动 mihomo（静默后台运行，请求管理员权限）
objShell.ShellExecute mihomoExe, startArgs, "", "runas", 0

' 等待一下确保启动成功
WScript.Sleep 500

' 可选：验证进程是否启动成功
Set colNewProcesses = objWMI.ExecQuery("Select * from Win32_Process Where Name = 'mihomo.exe'")
If colNewProcesses.Count > 0 Then
    ' 启动成功，静默退出
    WScript.Quit
Else
    ' 启动失败，显示提示
    MsgBox "警告：Mihomo 可能未成功启动" & vbCrLf & vbCrLf & _
           "可能的原因：" & vbCrLf & _
           "  1. 用户取消了 UAC 提权请求" & vbCrLf & _
           "  2. 配置文件格式错误" & vbCrLf & _
           "  3. 端口已被占用", _
           vbExclamation, "Mihomo 启动"
    WScript.Quit
End If
