#全局变量
huanchen=${0%/*}
Log="$huanchen/swap/swap.log"
sdk=$(getprop ro.system.build.version.sdk)
alias settings="/system/bin/settings"
alias device_config="/system/bin/device_config"

#获取本sh的pid
pid=$$

#pid输出
sed -i '2d' "$huanchen"/main_program/Delete_scene.sh
sed -i '1a '$pid'' "$huanchen"/main_program/Delete_scene.sh

#往log里面写点东西
#很明显用于调试
time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
open=$(cat "$huanchen"/Prop_on)
let open++
echo "手机品牌: $(getprop ro.product.brand)" >"$Log"
{
  echo "手机型号：$(getprop ro.product.vendor.device)"
  echo "安卓版本: $(getprop ro.build.version.release)"
  echo "内核版本: $(uname -r)"
  test "$(getprop ro.miui.ui.version.name)" != "" &&
    echo "MIUI版本: MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental) "
  echo "累计正常开机次数：$open次"
  echo "系统开机时间：$time"
  echo "---------------------------------------------------------------------------"
} >>"$Log"

#赋权，可能没啥用，有一定保障作用
chmod 777 "$huanchen"/main_program/Delete_scene.sh
chmod 777 "$huanchen"/main_program/Scene_swap_module.sh

#下面就是主代码了
Wait_until_login() {
  # in case of /data encryption is disabled
  while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
  done

  # in case of the user unlocked the screen
  while [ ! -d "/sdcard/Android" ]; do
    sleep 1
  done
}

#等待开机解锁
Wait_until_login

#更改selinux规则
magiskpolicy --live "allow system_server * * *"

#主代码开始运行
#解除安卓进程限制
{
  [[ "$sdk" -ge 29 ]] && {
    device_config set_sync_disabled_for_tests persistent
    settings put global settings_enable_monitor_phantom_procs false
    device_config put activity_manager max_cached_processes 2147483647
    device_config put activity_manager max_phantom_processes 2147483647
    settings put global activity_manager_constants max_cached_processes 2147483647
    settings put global activity_manager_constants max_phantom_processes 2147483647
    echo "- [i]: 解除进程限制成功" >>"$Log"
  }
} || {
  [[ "$sdk" -ge 26 ]] && {
    android_9=$(settings get global activity_manager_constants | sed 's/$/,max_cached_processes=2147483647/')
    settings put global activity_manager_constants "$android_9"
    echo "- [i]: 解除进程限制成功" >>"$Log"
  }
}

#开始运行主程序
{
  sh "$huanchen"/main_program/Delete_scene.sh
  sh "$huanchen"/main_program/Scene_swap_module.sh
  echo "---------------------------------------------------------------------------"
} >>"$Log"
#此代码到此结束
