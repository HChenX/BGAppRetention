#主进程的pid

#自动处理冲突
#删除指定文件
Deletes() {
  rm -rf /data/adb/ksu/modules/scene_swap_controller/
  rm -rf /data/adb/ksu/modules/swap_controller/
  rm -rf /data/adb/modules/scene_swap_controller/
  rm -rf /data/adb/modules/swap_controller/
  rm -rf /data/adb/swap_controller/
  rm -rf /data/swap_recreate
  rm -rf /data/swapfile*
}

#kill主sh
Pids() {
  pid=$(sed -n '2p' "$0")
  kill -9 "$pid"
}

#输出log
Log() {
  echo "- [!]: 已经处理冲突，请重启以彻底解决冲突！"
}

#进行判断
if [[ -d "/data/adb/modules/scene_swap_controller/" ]] ||
  [[ -d "/data/adb/ksu/modules/scene_swap_controller/" ]]; then
  Deletes
  Log
  Pids
elif [[ -d "/data/adb/modules/swap_controller/" ]] ||
  [[ -d "/data/adb/ksu/modules/swap_controller/" ]]; then
  Deletes
  Log
  Pids
fi
