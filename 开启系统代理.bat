@echo off
chcp 65001 >nul

echo 正在设置系统代理...

REM 获取当前批处理文件所在目录
cd /d "%~dp0"

REM 检查配置文件是否存在
if not exist "config.yaml" (
    echo 错误：未找到 config.yaml 文件
    echo 请确保批处理文件与 config.yaml 在同一目录
    pause
    exit /b
)

REM 读取配置文件中的端口（处理多种格式）
set PORT=
for /f "tokens=1,* delims=:" %%a in ('findstr /i "mixed-port" config.yaml') do (
    for /f "tokens=* delims= " %%c in ("%%b") do set PORT=%%c
)

REM 检查是否成功读取端口
if "%PORT%"=="" (
    echo 错误：无法从 config.yaml 读取 mixed-port
    echo 请检查配置文件格式
    pause
    exit /b
)

echo 检测到端口: %PORT%

REM 设置系统代理
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "127.0.0.1:%PORT%" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo ✓ 系统代理已设置为: 127.0.0.1:%PORT%
) else (
    echo ✗ 设置失败，请以管理员权限运行
)

echo 完成！
timeout /t 2 /nobreak >nul