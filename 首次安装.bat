@echo off
chcp 65001 >nul
color 0A
title Mihomo 首次安装与诊断工具

REM ========================================
REM  检查管理员权限
REM ========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║   ⚠ 需要管理员权限                    ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ╔════════════════════════════════════════╗
echo ║     Mihomo 首次安装与诊断工具         ║
echo ╚════════════════════════════════════════╝
echo.

REM ========================================
REM  获取当前目录
REM ========================================
cd /d "%~dp0"
echo [步骤 1/7] 当前工作目录
echo └─ %cd%
echo.

REM ========================================
REM  检查必要文件
REM ========================================
echo [步骤 2/7] 检查必要文件
set FILES_OK=1

if not exist "mihomo.exe" (
    echo └─ ✗ 错误：未找到 mihomo.exe
    set FILES_OK=0
) else (
    echo └─ ✓ mihomo.exe 存在
)

if not exist "config.yaml" (
    echo └─ ✗ 错误：未找到 config.yaml
    set FILES_OK=0
) else (
    echo └─ ✓ config.yaml 存在
)

if %FILES_OK%==0 (
    goto :error_files
)
echo.

REM ========================================
REM  读取配置端口
REM ========================================
echo [步骤 3/7] 读取配置文件端口
set PORT=
for /f "tokens=1,* delims=:" %%a in ('findstr /i "mixed-port" config.yaml') do (
    for /f "tokens=* delims= " %%c in ("%%b") do set PORT=%%c
)

if "%PORT%"=="" (
    echo └─ ✗ 错误：无法从 config.yaml 读取 mixed-port
    echo └─ 提示：请检查配置文件中是否有 "mixed-port: 端口号"
    goto :error_config
)
echo └─ ✓ 检测到端口: %PORT%
echo.

REM ========================================
REM  检查端口占用（自动清理）
REM ========================================
echo [步骤 4/7] 检查端口占用情况
netstat -ano | findstr ":%PORT%" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo └─ ⚠ 发现端口 %PORT% 已被占用
    echo └─ 正在查找占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT%" ^| findstr "LISTENING"') do (
        set PID=%%a
        for /f "tokens=1" %%b in ('tasklist /FI "PID eq %%a" /NH') do (
            echo └─ 占用进程: %%b (PID: %%a^)
        )
    )
    echo └─ 正在自动清理端口占用...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT%" ^| findstr "LISTENING"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
    echo └─ ✓ 端口已清理完成
) else (
    echo └─ ✓ 端口 %PORT% 可用
)
echo.

REM ========================================
REM  清理旧进程
REM ========================================
echo [步骤 5/7] 清理旧的 Mihomo 进程
tasklist /FI "IMAGENAME eq mihomo.exe" 2>NUL | find /I "mihomo.exe" >NUL
if %errorlevel% equ 0 (
    echo └─ 发现运行中的 Mihomo，正在停止...
    taskkill /F /IM mihomo.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo └─ ✓ 已停止旧进程
) else (
    echo └─ ✓ 无需清理
)
echo.

REM ========================================
REM  启动 Mihomo 服务（持续显示日志）
REM ========================================
echo [步骤 6/7] 启动 Mihomo 服务
echo └─ 启动命令: mihomo.exe -d . -f config.yaml
echo └─ 正在启动...
echo.

REM 创建临时日志文件
set LOGFILE=%TEMP%\mihomo_startup.log
del /f /q "%LOGFILE%" >nul 2>&1

REM 在后台启动 mihomo 并持续输出日志
start /b cmd /c "mihomo.exe -d . -f config.yaml > "%LOGFILE%" 2>&1"

echo ┌─────────────────────────────────────────┐
echo │  持续显示启动日志（最长60秒）          │
echo │  提示：按 Enter 键可随时停止日志输出   │
echo └─────────────────────────────────────────┘
echo.

REM 创建标记文件用于控制循环
set STOPFLAG=%TEMP%\mihomo_stop_flag.txt
del /f /q "%STOPFLAG%" >nul 2>&1

REM 在后台等待用户按回车键
start /b cmd /c "pause >nul && echo stop > "%STOPFLAG%""

REM 持续监控并显示日志（最长60秒或用户按回车）
set /a COUNTER=0
:log_loop
if %COUNTER% geq 60 goto :log_end
if exist "%STOPFLAG%" goto :log_end

timeout /t 1 /nobreak >nul
set /a COUNTER+=1

if exist "%LOGFILE%" (
    cls
    echo ╔════════════════════════════════════════╗
    echo ║  Mihomo 实时启动日志 [%COUNTER%秒]
    echo ╚════════════════════════════════════════╝
    echo.
    type "%LOGFILE%"
    echo.
    echo ════════════════════════════════════════
    echo 日志持续监控中... (按 Enter 停止)
)

goto :log_loop

:log_end
REM 清理标记文件
del /f /q "%STOPFLAG%" >nul 2>&1

REM 结束等待按键的后台进程
taskkill /FI "WindowTitle eq *pause*" /F >nul 2>&1

echo.
echo ════════════════════════════════════════
echo 日志监控已停止
echo.

REM 检查进程是否运行
tasklist /FI "IMAGENAME eq mihomo.exe" 2>NUL | find /I "mihomo.exe" >NUL
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║   ✗ Mihomo 启动失败！                 ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 【错误诊断】
    
    if exist "%LOGFILE%" (
        echo.
        echo 完整启动日志：
        echo ─────────────────────────────────────
        type "%LOGFILE%"
        echo ─────────────────────────────────────
        echo.
        
        REM 分析常见错误
        findstr /i "can't find config" "%LOGFILE%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo 【问题】配置文件未找到
            echo 【解决】请确保 config.yaml 在当前目录
            echo.
        )
        
        findstr /i "bind" "%LOGFILE%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo 【问题】端口绑定失败（端口被占用）
            echo 【解决】请更换 config.yaml 中的端口号
            echo.
        )
        
        findstr /i "permission denied" "%LOGFILE%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo 【问题】权限不足
            echo 【解决】请以管理员身份运行
            echo.
        )
        
        findstr /i "invalid" "%LOGFILE%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo 【问题】配置文件格式错误
            echo 【解决】请检查 config.yaml 语法
            echo.
        )
    )
    
    goto :error_startup
)

color 0A
echo └─ ✓ Mihomo 进程启动成功
echo.

REM ========================================
REM  设置系统代理
REM ========================================
echo [步骤 7/7] 设置系统代理
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:%PORT%" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo └─ ✓ 系统代理已设置为: 127.0.0.1:%PORT%
) else (
    echo └─ ✗ 代理设置失败
    goto :error_proxy
)
echo.

REM ========================================
REM  验证服务状态
REM ========================================
echo [验证] 测试服务连接性
timeout /t 2 /nobreak >nul

REM 尝试访问代理端口
powershell -Command "$response = try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('127.0.0.1', %PORT%); $tcp.Close(); $true } catch { $false }; if ($response) { exit 0 } else { exit 1 }" >nul 2>&1

if %errorlevel% equ 0 (
    echo └─ ✓ 服务运行正常，端口可访问
) else (
    echo └─ ⚠ 警告：端口连接测试失败
    echo └─ 进程已启动，但可能需要更长时间初始化
)
echo.

REM ========================================
REM  成功完成
REM ========================================
color 0B
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✓ 安装成功！                        ║
echo ╚════════════════════════════════════════╝
echo.
echo ┌─ 服务信息 ─────────────────────────────┐
echo │  代理地址: 127.0.0.1:%PORT%
echo │  配置文件: config.yaml
echo │  工作目录: %cd%
echo │  进程状态: 运行中
echo └─────────────────────────────────────────┘
echo.
echo ┌─ 使用说明 ─────────────────────────────┐
echo │  ✓ 本次服务已启动，现在可以关闭本窗口
echo │  
echo │  【下次启动】
echo │  └─ 双击 start-mihomo.vbs（静默后台启动）
echo │  
echo │  【快捷键功能说明】
echo │  ├─ 开启系统代理.bat    启用系统代理
echo │  ├─ 关闭系统代理.bat    禁用系统代理
echo │  ├─ 停止运行.bat        停止 Mihomo 服务
echo │  ├─ 重启.bat            重启 Mihomo 服务
echo │  ├─ 开启开机自动.bat    设置开机自动启动
echo │  └─ 关闭开机自动.bat    取消开机自动启动
echo └─────────────────────────────────────────┘
echo.
echo ┌─ 完整日志位置 ─────────────────────────┐
echo │  %LOGFILE%
echo └─────────────────────────────────────────┘
echo.
echo ════════════════════════════════════════
echo 按任意键关闭本窗口...
pause >nul
exit /b 0

:error_files
color 0C
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✗ 文件检查失败                      ║
echo ╚════════════════════════════════════════╝
echo.
echo 请确保以下文件在同一目录：
echo   • mihomo.exe
echo   • config.yaml
echo   • %~nx0
echo.
echo 当前目录: %cd%
echo.
goto :end_error

:error_config
color 0C
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✗ 配置文件错误                      ║
echo ╚════════════════════════════════════════╝
echo.
echo config.yaml 中未找到 mixed-port 配置
echo.
echo 请确保配置文件包含类似以下内容：
echo   mixed-port: 7890
echo.
goto :end_error

:error_startup
goto :end_error

:error_proxy
color 0C
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✗ 代理设置失败                      ║
echo ╚════════════════════════════════════════╝
echo.
echo 服务已启动，但系统代理设置失败
echo 请手动在系统设置中配置代理
echo.
goto :end_error

:end_error
echo.
echo ════════════════════════════════════════
echo 按任意键退出...
pause >nul
exit /b 1

:end_normal
echo.
echo ════════════════════════════════════════
echo 按任意键退出...
pause >nul
exit /b 0