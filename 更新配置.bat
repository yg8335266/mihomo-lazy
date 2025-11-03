@echo off
chcp 65001 >nul
color 0B
title 从 Gist 更新配置文件

echo.
echo ╔════════════════════════════════════════╗
echo ║     从 Gist 下载最新配置文件          ║
echo ╚════════════════════════════════════════╝
echo.

REM ========================================
REM  获取当前目录
REM ========================================
cd /d "%~dp0"
set "current_dir=%cd%"
set "config_file=%current_dir%\config.yaml"
set "backup_file=%current_dir%\config.yaml.backup"

REM ========================================
REM  配置 Gist 下载地址
REM ========================================
REM 请将下面的 URL 替换为你的 Gist 原始文件地址
REM 格式示例: https://gist.githubusercontent.com/用户名/gist编号/raw/config.yaml
set "GIST_URL=https://gist.githubusercontent.com/YOUR_USERNAME/YOUR_GIST_ID/raw/config.yaml"

echo [步骤 1/4] 检查 Gist 地址配置
if "%GIST_URL%"=="https://gist.githubusercontent.com/YOUR_USERNAME/YOUR_GIST_ID/raw/config.yaml" (
    color 0C
    echo └─ ✗ 错误：未配置 Gist 下载地址
    echo.
    echo 请按以下步骤配置：
    echo.
    echo 1. 右键编辑本脚本（更新配置.bat）
    echo 2. 找到 GIST_URL 这一行
    echo 3. 替换为你的 Gist 原始文件地址
    echo.
    echo 如何获取 Gist 原始地址：
    echo   • 打开你的 Gist 页面
    echo   • 点击右上角 "Raw" 按钮
    echo   • 复制浏览器地址栏的 URL
    echo.
    echo 格式示例：
    echo   https://gist.githubusercontent.com/username/abc123.../raw/config.yaml
    echo.
    goto :end_error
)
echo └─ ✓ Gist 地址: %GIST_URL%
echo.

REM ========================================
REM  备份当前配置文件
REM ========================================
echo [步骤 2/4] 备份当前配置文件
if exist "%config_file%" (
    copy /y "%config_file%" "%backup_file%" >nul 2>&1
    if %errorlevel% equ 0 (
        echo └─ ✓ 已备份到: config.yaml.backup
    ) else (
        echo └─ ⚠ 警告：备份失败，但继续下载
    )
) else (
    echo └─ ⚠ 当前配置文件不存在，将直接下载
)
echo.

REM ========================================
REM  下载最新配置文件
REM ========================================
echo [步骤 3/4] 从 Gist 下载最新配置
echo └─ 正在下载...

REM 使用 PowerShell 下载文件（支持 https）
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%GIST_URL%' -OutFile '%config_file%' -UseBasicParsing; exit 0 } catch { Write-Host $_.Exception.Message; exit 1 } }" 2>nul

if %errorlevel% neq 0 (
    color 0C
    echo └─ ✗ 下载失败！
    echo.
    echo 【可能的原因】
    echo   • Gist 地址不正确
    echo   • 网络连接问题
    echo   • Gist 文件不存在或已删除
    echo   • 需要代理才能访问 GitHub
    echo.
    echo 【解决方法】
    echo   1. 检查 Gist 地址是否正确
    echo   2. 确认网络连接正常
    echo   3. 尝试在浏览器中打开 Gist 地址
    echo   4. 如果无法访问 GitHub，请先启动代理
    echo.
    
    REM 如果有备份，尝试恢复
    if exist "%backup_file%" (
        echo 正在恢复备份文件...
        copy /y "%backup_file%" "%config_file%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo └─ ✓ 已恢复原配置文件
            del /f /q "%backup_file%" >nul 2>&1
        )
    )
    
    goto :end_error
)

echo └─ ✓ 下载成功！
echo.

REM ========================================
REM  验证配置文件
REM ========================================
echo [步骤 4/4] 验证配置文件
if not exist "%config_file%" (
    color 0C
    echo └─ ✗ 错误：配置文件不存在
    goto :end_error
)

REM 检查文件大小（至少应该有一些内容）
for %%A in ("%config_file%") do set size=%%~zA
if %size% lss 50 (
    color 0C
    echo └─ ✗ 错误：配置文件太小，可能下载不完整
    echo.
    
    REM 恢复备份
    if exist "%backup_file%" (
        echo 正在恢复备份文件...
        copy /y "%backup_file%" "%config_file%" >nul 2>&1
        if %errorlevel% equ 0 (
            echo └─ ✓ 已恢复原配置文件
            del /f /q "%backup_file%" >nul 2>&1
        )
    )
    
    goto :end_error
)

echo └─ ✓ 配置文件有效（大小: %size% 字节）
echo.

REM 删除备份文件
if exist "%backup_file%" (
    del /f /q "%backup_file%" >nul 2>&1
)

REM ========================================
REM  完成提示
REM ========================================
color 0A
echo.
echo ╔════════════════════════════════════════╗
echo ║   ✓ 配置更新成功！                    ║
echo ╚════════════════════════════════════════╝
echo.
echo ┌─ 更新信息 ─────────────────────────────┐
echo │  配置文件: config.yaml
echo │  文件大小: %size% 字节
echo │  下载来源: Gist
echo └─────────────────────────────────────────┘
echo.
echo ┌─ 下一步操作 ───────────────────────────┐
echo │  配置文件已更新，建议重启服务使配置生效
echo │  
echo │  【重启服务】
echo │  └─ 双击 "重启.bat" 重启 Mihomo 服务
echo │  
echo │  【查看配置】
echo │  └─ 打开 config.yaml 查看新配置内容
echo └─────────────────────────────────────────┘
echo.
echo ════════════════════════════════════════
echo 按任意键关闭窗口...
pause >nul
exit /b 0

:end_error
echo.
echo ════════════════════════════════════════
echo 按任意键退出...
pause >nul
exit /b 1
