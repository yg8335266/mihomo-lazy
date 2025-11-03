@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

chcp 65001 >nul
echo 正在停止 Clash...

tasklist | find /i "mihomo.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM mihomo.exe >nul 2>nul
    echo Clash 已停止！
) else (
    echo Clash 未运行！
)

timeout /t 2 /nobreak >nul