@echo off
chcp 65001 >nul
echo 正在重启 Mihomo...
echo.

:: 获取当前脚本所在目录
set "current_dir=%~dp0"
set "current_dir=%current_dir:~0,-1%"

:: VBS 启动脚本路径
set "vbs_file=%current_dir%\start-mihomo.vbs"

:: 检查进程并显示 PID
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq mihomo.exe" ^| find "mihomo.exe"') do (
    echo 发现运行中的 mihomo.exe，PID: %%i
)

:: 停止 mihomo 进程
echo 正在停止服务...
taskkill /F /IM mihomo.exe >nul 2>nul
timeout /t 2 /nobreak >nul

:: 检查 VBS 文件是否存在
if not exist "%vbs_file%" (
    echo.
    echo [错误] 找不到 start-mihomo.vbs 文件！
    pause
    exit /b 1
)

:: 启动 mihomo
echo 正在启动服务...
start "" "%vbs_file%"

echo.
echo ✓ Mihomo 已重启！
echo.
timeout /t 2 /nobreak >nul
