@echo off
chcp 65001 >nul
echo 正在关闭 Mihomo 开机自启动...
echo.

:: 开机启动文件夹
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "shortcut=%startup%\Mihomo.lnk"

:: 删除快捷方式
if exist "%shortcut%" (
    del "%shortcut%"
    echo ✓ Mihomo 开机自启动已关闭！
) else (
    echo × Mihomo 未设置开机自启动
)

echo.
pause
