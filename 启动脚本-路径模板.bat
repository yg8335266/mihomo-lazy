@echo off
chcp 65001 >nul
color 0A
title Mihomo 启动脚本（路径配置版）

REM ════════════════════════════════════════════════════════════════
REM  【路径配置区域 - 请根据实际情况填写】
REM ════════════════════════════════════════════════════════════════
REM 
REM 说明：请将下面的占位符替换为实际路径
REM 
REM 示例：
REM   set "MIHOMO_DIR=D:\Tools\mihomo-lazy"
REM   set "MIHOMO_EXE=D:\Tools\mihomo-lazy\mihomo.exe"
REM   set "CONFIG_FILE=D:\Tools\mihomo-lazy\config.yaml"
REM 
REM ════════════════════════════════════════════════════════════════

REM Mihomo 安装目录（存放所有文件的文件夹）
set "MIHOMO_DIR=【请填写：如 D:\Tools\mihomo-lazy】"

REM mihomo.exe 可执行文件完整路径
set "MIHOMO_EXE=【请填写：如 D:\Tools\mihomo-lazy\mihomo.exe】"

REM config.yaml 配置文件完整路径
set "CONFIG_FILE=【请填写：如 D:\Tools\mihomo-lazy\config.yaml】"

REM ════════════════════════════════════════════════════════════════
REM  以下为自动执行部分，无需修改
REM ════════════════════════════════════════════════════════════════

REM 检查路径是否已配置
echo [检查] 验证路径配置...
if "%MIHOMO_DIR%"=="【请填写：如 D:\Tools\mihomo-lazy】" (
    color 0C
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║   ⚠ 错误：路径尚未配置                ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 请打开本脚本文件，在顶部【路径配置区域】填写实际路径
    echo.
    echo 需要配置的变量：
    echo   1. MIHOMO_DIR   - Mihomo 安装目录
    echo   2. MIHOMO_EXE   - mihomo.exe 完整路径
    echo   3. CONFIG_FILE  - config.yaml 完整路径
    echo.
    echo 配置示例：
    echo   set "MIHOMO_DIR=D:\Tools\mihomo-lazy"
    echo   set "MIHOMO_EXE=D:\Tools\mihomo-lazy\mihomo.exe"
    echo   set "CONFIG_FILE=D:\Tools\mihomo-lazy\config.yaml"
    echo.
    goto :end_error
)

REM 切换到 Mihomo 工作目录
cd /d "%MIHOMO_DIR%"
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║   ✗ 错误：无法切换到工作目录          ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 配置的目录：%MIHOMO_DIR%
    echo.
    echo 请检查：
    echo   1. 目录路径是否正确
    echo   2. 目录是否存在
    echo   3. 是否有访问权限
    echo.
    goto :end_error
)

echo └─ ✓ 工作目录: %cd%
echo.

REM ========================================
REM  检查必要文件
REM ========================================
echo [检查] 验证必要文件
set FILES_OK=1

if not exist "%MIHOMO_EXE%" (
    echo └─ ✗ 错误：未找到 mihomo.exe
    echo    配置路径：%MIHOMO_EXE%
    set FILES_OK=0
) else (
    echo └─ ✓ mihomo.exe 存在
)

if not exist "%CONFIG_FILE%" (
    echo └─ ✗ 错误：未找到 config.yaml
    echo    配置路径：%CONFIG_FILE%
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
echo [检查] 读取配置文件端口
set PORT=
for /f "tokens=1,* delims=:" %%a in ('findstr /i "mixed-port" "%CONFIG_FILE%"') do (
    for /f "tokens=* delims= " %%c in ("%%b") do set PORT=%%c
)

if "%PORT%"=="" (
    echo └─ ✗ 错误：无法从 config.yaml 读取 mixed-port
    goto :error_config
)
echo └─ ✓ 检测到端口: %PORT%
echo.

REM ========================================
REM  清理旧进程
REM ========================================
echo [清理] 检查并停止旧进程
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
REM  启动 Mihomo 服务
REM ========================================
echo [启动] Mihomo 服务
echo └─ 执行命令: "%MIHOMO_EXE%" -d "%MIHOMO_DIR%" -f "%CONFIG_FILE%"
echo └─ 工作目录: %cd%
echo.

start /b "" "%MIHOMO_EXE%" -d "%MIHOMO_DIR%" -f "%CONFIG_FILE%"

timeout /t 3 /nobreak >nul

REM 检查进程是否运行
tasklist /FI "IMAGENAME eq mihomo.exe" 2>NUL | find /I "mihomo.exe" >NUL
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║   ✗ Mihomo 启动失败！                 ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 可能的原因：
    echo   1. 端口 %PORT% 已被占用
    echo   2. 配置文件格式错误
    echo   3. 权限不足（尝试以管理员身份运行）
    echo.
    goto :end_error
)

color 0A
echo └─ ✓ Mihomo 进程启动成功
echo.

REM ========================================
REM  设置系统代理
REM ========================================
echo [配置] 设置系统代理
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:%PORT%" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo └─ ✓ 系统代理已设置为: 127.0.0.1:%PORT%
) else (
    echo └─ ⚠ 代理设置失败（可手动配置）
)
echo.

REM ========================================
REM  完成
REM ========================================
color 0B
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✓ 启动成功！                        ║
echo ╚════════════════════════════════════════╝
echo.
echo ┌─ 服务信息 ─────────────────────────────┐
echo │  代理地址: 127.0.0.1:%PORT%
echo │  配置文件: %CONFIG_FILE%
echo │  工作目录: %MIHOMO_DIR%
echo │  进程状态: 运行中
echo └─────────────────────────────────────────┘
echo.
echo ════════════════════════════════════════
echo 按任意键关闭窗口...
timeout /t 3 /nobreak >nul
exit /b 0

REM ========================================
REM  错误处理
REM ========================================
:error_files
color 0C
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✗ 文件检查失败                      ║
echo ╚════════════════════════════════════════╝
echo.
echo 请检查路径配置是否正确
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
goto :end_error

:end_error
echo.
echo ════════════════════════════════════════
echo 按任意键退出...
pause >nul
exit /b 1
