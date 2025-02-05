#!/bin/bash

# 设置源目录和目标目录路径
source_dir="$(pwd)/data/updater/test"
target_dir=$(pwd)
exe_file="vvibe"  # 要执行的可执行文件
echo $script_dir
# 输出正在复制文件的信息
echo "Copying files from $source_dir to $target_dir..."


# 复制源目录的文件到目标目录，-r 表示递归复制目录
cp -r "$source_dir"/* "$target_dir"

# 检查复制操作是否成功
if [ $? -ne 0 ]; then
  echo "Error occurred during file copy!"
  exit 1
else
  echo "Files copied successfully."
fi

# 运行目标目录中的可执行文件
exe_path="$target_dir/$exe_file"

# 检查文件是否存在
if [ ! -f "$exe_path" ]; then
  echo "Executable file not found: $exe_path"
  exit 1
fi

# 执行可执行文件
echo "Starting executable: $exe_path"
"$exe_path"

# 检查执行是否成功
if [ $? -ne 0 ]; then
  echo "Error occurred during execution!"
  exit 1
else
  echo "Executable ran successfully."
fi

exit 0