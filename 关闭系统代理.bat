@echo off
chcp 65001 >nul

echo 正在取消系统代理...

REM 禁用系统代理
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1

if %errorlevel% equ 0 (
    echo ✓ 系统代理已关闭
) else (
    echo ✗ 操作失败，请以管理员权限运行
)

echo 完成！
timeout /t 2 /nobreak >nul