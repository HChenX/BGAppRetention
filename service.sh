#Author by @焕晨HChen
HChen=${0%/*}
Log="$HChen/swap/swap.log"
sdk=$(getprop ro.system.build.version.sdk)
alias settings="/system/bin/settings"
alias device_config="/system/bin/device_config"
Wait_until_login() {
  while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 1; done
  while [ ! -d "/sdcard/Android" ]; do sleep 1; done
}
Wait_until_login
magiskpolicy --live "allow system_server * * *"
{ [[ -f /system/bin/sh ]] && alias sh="/system/bin/sh"; } || { [[ -f /vendor/bin/sh ]] && alias sh="/vendor/bin/sh"; }
{ [[ -f "$HChen/Ksu_ver" ]] && Ver=$(cat "$HChen/Ksu_ver") && mod=Ksu; } || { Ver=$(sed -n "s/^.*MAGISK_VER='\([^']*\)'.*$/\1/p" /data/adb/magisk/util_functions.sh) && mod=Magisk; }
{ [[ -f /sys/devices/soc0/soc_id ]] && cpu="$(cat /sys/devices/soc0/soc_id)"; } || { cpu="$(cat /sys/devices/system/soc/soc0/id)"; }
time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
open=$(cat "$HChen"/Prop_on)
let open++
echo "手机品牌:$(getprop ro.product.brand)" >"$Log"
{
  echo "手机型号:$(getprop ro.product.vendor.device)"
  echo "安卓版本:$(getprop ro.build.version.release)"
  echo "内核版本:$(uname -r)"
  echo "CPU型号:$cpu"
  echo "ROOT管理器名:$mod"
  echo "ROOT管理器版本:$Ver"
  test "$(getprop ro.miui.ui.version.name)" != "" &&
    echo "MIUI版本:MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental) "
  echo "累计正常开机次数:$open次"
  echo "系统开机时间:$time"
  echo "---------------------------------------------------------------------------"
} >>"$Log"
{ [[ "$sdk" -ge 29 ]] && {
  device_config set_sync_disabled_for_tests persistent
  settings put global settings_enable_monitor_phantom_procs false
  device_config put activity_manager max_cached_processes 2147483647
  device_config put activity_manager max_phantom_processes 2147483647
  settings put global activity_manager_constants max_cached_processes 2147483647
  settings put global activity_manager_constants max_phantom_processes 2147483647
  echo "- [i]:解除进程限制成功:for A>29" >>"$Log"
}; } || { [[ "$sdk" -ge 26 ]] && {
  android_9=$(settings get global activity_manager_constants | sed 's/$/,max_cached_processes=2147483647/')
  settings put global activity_manager_constants "$android_9"
  echo "- [i]:解除进程限制成功:for A8/9" >>"$Log"
}; }
{
  chmod 777 "$HChen"/main_program/HChenMain.sh
  sh "$HChen"/main_program/HChenMain.sh 2>/dev/null
  echo "---------------------------------------------------------------------------"
} >>"$Log"
