@echo off
chcp 65001 >nul
echo 正在设置 Mihomo 开机自启动...
echo.

:: 获取当前脚本所在目录
set "current_dir=%~dp0"
set "current_dir=%current_dir:~0,-1%"

:: 开机启动文件夹
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: VBS 启动脚本路径
set "target=%current_dir%\start-mihomo.vbs"

:: 检查文件是否存在
if not exist "%target%" (
    echo [错误] 找不到 start-mihomo.vbs 文件！
    pause
    exit /b 1
)

:: 创建快捷方式
powershell -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%startup%\Mihomo.lnk'); $s.TargetPath = '%target%'; $s.WorkingDirectory = '%current_dir%'; $s.Save()" >nul 2>nul

:: 验证是否成功
if exist "%startup%\Mihomo.lnk" (
    echo ✓ Mihomo 开机自启动设置成功！
    echo.
    echo 下次开机会自动启动
) else (
    echo × 设置失败，请以管理员身份运行
)

echo.
pause
