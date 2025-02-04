@echo off
:: 获取当前脚本所在目录
set current_dir=%~dp0

:: 设置源目录和目标目录路径（相对当前脚本目录）
set source_dir=%current_dir%..\updater\Release
set target_dir=%current_dir%..\..\

:: 设置需要启动的 exe 文件路径（相对当前脚本目录）
set exe_path=%current_dir%..\..\vvibe.exe

:: 输出正在执行操作的信息
echo Copying files from %source_dir% to %target_dir%

:: 复制文件并覆盖已存在的文件
xcopy "%source_dir%\*" "%target_dir%\" /E /H /Y

:: 检查是否复制成功
if %errorlevel% neq 0 (
    echo Error occurred during file copy!
    exit /b 1
)

:: 输出文件复制成功信息
echo Files copied successfully.

:: 启动指定的 exe 文件
echo Starting %exe_path%...
start "" "%exe_path%"

:: 退出脚本
::exit /b 0
