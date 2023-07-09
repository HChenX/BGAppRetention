#Author by @焕晨HChen
magiskpolicy --live "allow system_server * * *"
{ HChen=$(echo "${0%/*}" | xargs echo "$(sed 's/\/main_program//g')") || { echo "- [!]:获取路径失败" && exit 55; }; } && file="/main_program"
mod="$HChen$file/HChen_mod.sh" && value="$HChen$file/HChen_value.sh" && name="$HChen$file/HChen_name.sh" && chmod -R 0777 "$HChen"$file/
{ { [[ -f $mod ]] && [[ -f $value ]] && [[ -f $name ]]; } && { . $mod && . $value && . $name; }; } || { echo "- [!]:缺少关键文件" && exit 99; }
{ [[ -f $swap_conf ]] && { . "$swap_conf" && echo "- [i]:配置文件读取成功"; } || { echo "- [!]:配置文件读取异常" && exit 1; }; } || { echo "- [!]: 缺少$swap_conf" && exit 2; }
{ [[ -f "$bin"/swapon ]] && alias swapon="\$bin/swapon" && alias swapoff="\$bin/swapoff" && alias mkswap="\$bin/mkswap"; } || { [[ -f $vbin/swapon ]] && alias swapon="\$vbin/swapon" && alias swapoff="\$vbin/swapoff" && alias mkswap="\$vbin/mkswap"; }
echo "---------------------------------------------------------------------------"
set_zram() {
  [[ ! -e /dev/block/zram0 ]] && { { [[ -e /sys/class/zram-control ]] && echo "- [i]:内核支持ZRAM"; } || { echo "- [!]:内核不支持ZRAM" && return; }; }
  zram_value && zram_size=$(awk 'BEGIN{print '$zram_in'*('$g'^'$d')}') && [[ $zram_size == "0" ]] && return
  close
  name=($(name_first)) && value=($(value_first))
  for i in "${!name[@]}"; do set_value "${value[i]}" "${name[i]}"; done
  echo "- [i]:正在设置压缩模式"
  echo "$comp_algorithm" >/sys/class/block/zram0/comp_algorithm
  tt=$(cat_mod /sys/class/block/zram0/comp_algorithm | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g' | grep -w "$comp_algorithm")
  { [[ $comp_algorithm == "$tt" ]] && echo "- [i]:目标设置为:$comp_algorithm,实际设置为:$tt"; } || { echo "- [!]:目标设置为:$comp_algorithm,实际设置为:$tt"; }
  echo "- [i]:正在设置ZRAM大小"
  set_value "$zram_size" /sys/block/zram0/disksize
  opens
}
set_vm_params() {
  echo "---------------------------------------------------------------------------"
  swappinessd="/proc/sys/vm/swappiness"
  echo "- [i]:正在设置swappiness"
  vm_value
  set_value "$swappiness" $swappinessd
  for_mod "$(name_swap)" "set_value" "$swappiness" "" "" "" ""
  echo "- [i]:正在设置watermark"
  zram_value && set_value "$watermark" /proc/sys/vm/watermark_scale_factor
  echo "- [i]:设置cache/vm参数"
  name=($(name_vm)) && value=($(value_second))
  for i in "${!name[@]}"; do set_value "${value[i]}" "${name[i]}"; done
  { [[ $comp_algorithm == "zstd" ]] && set_value 0 "$proc"/page-cluster; } || { set_value 1 "$proc"/page-cluster; }
}
other_setting() {
  [[ -d $lowmemorykiller ]] && {
    name=($(name_low)) && value=($(value_third))
    for i in "${!name[@]}"; do set_value "${value[i]}" "${name[i]}"; done
    echo "- [i]:设置lmk优化(旧内核)"
  }
  other_vm
  echo "- [i]:设置io调度参数完成"
  [[ -d $dev ]] && { mem=$(find "$dev" -maxdepth 1 -type d | sed "1d") && [[ $mem != "" ]] && {
    for i in $mem; do
      for m in $(mem_value1); do set_value "-1" "$i""$m"; done
      for v in $(mem_value2); do set_value "1" "$i""$v"; done
    done
    echo "- [i]:设置memcg参数完成"
  }; }
  [[ -f /sys/kernel/mm/lru_gen/enabled ]] && { set_value y /sys/kernel/mm/lru_gen/enabled && echo "- [i]:设置开启multi-gen LRU"; }
  { [[ $ksu_check != "true" ]] && { camera_folder="$HChen/system/system_ext/etc/" && camera_now_file="$HChen/system/system_ext/etc/camerabooster.json"; }; } || { camera_folder="$HChen/system_ext/etc/" && camera_now_file="$HChen/system_ext/etc/camerabooster.json"; }
  [[ -f $camera_file ]] && { { [[ ! -f $camera_now_file ]] && {
    let record++
    mkdir -p "$camera_folder"
    cp -f "$camera_file" "$camera_folder" && {
      for_mod "$(name_cam)" "camera_mod" "" "" "" "" "false"
      echo "- [i]:已优化相机杀后台问题"
      echo "- [!]:为了完全生效请再重启一次"
    } || { echo "- [!]:复制相机配置文件失败"; }
  }; } || { { [[ $(du -k "$camera_now_file" | cut -f1) -ne 0 ]] && { echo "- [i]:已优化相机杀后台问题"; }; } || { echo "- [!]:修改后相机配置文件为空"; }; }; }
  { [[ $ksu_check != "true" ]] && { qcom_folder="$HChen/system/vendor/etc/perf/" && qcom_now_file="$HChen/system$qcom_file"; }; } || { qcom_folder="$HChen/vendor/etc/perf/" && qcom_now_file="$HChen$qcom_file"; }
  [[ "$(getprop ro.hardware)" == "qcom" ]] && { {
    [[ -f $qcom_file ]] && [[ $(du -k "$qcom_file" | cut -f1) -ne 0 ]] && {
      { [[ ! -f $qcom_now_file ]] && {
        mkdir -p "$qcom_folder"
        cp -f "$qcom_file" "$qcom_folder"
        touch "$HChen"/Qualcomm
        name=($(name_qcom)) && value=($(qcom_value))
        for i in "${!name[@]}"; do update_overlay "${name[i]}" "${value[i]}"; done
        echo "- [i]:成功执行高通专改"
        echo "- [!]:为了完全生效请再重启一次"
        let record++
      }; } || { echo "- [i]:成功执行高通专改"; }
    }
  } || { echo "- [!]:源文件为空，无法进行高通专改"; }; }
}
on_prop_pool() {
  echo "- [i]:开始进行prop参数修改"
  [[ -f "$HChen"/Prop_on ]] && prop_on=$(cat "$HChen"/Prop_on)
  { [[ $prop_on == 0 ]] && {
    echo "- [!]:为了完全生效请再重启一次"
    let record++
    echo "vtools.swap.controller=module" >"$HChen"/system.prop
    name=($(name_prop)) && value=($(prop_value))
    for i in "${!name[@]}"; do
      [[ $(getprop "${name[i]}") != "" ]] && {
        resetprop "${name[i]}" "${value[i]}"
        echo "${name[i]}" "${value[i]}"
        echo "${name[i]}=${value[i]}" >>"$HChen"/system.prop
      }
    done
    echo -n "1" >"$HChen"/Prop_on
  }; } || {
    pck=$(cat "$HChen"/system.prop)
    echo "- [i]:正在加载prop参数列表"
    echo "$pck"
    for k in $pck; do
      now=$(getprop "$(echo "$k" | cut -d '=' -f1)")
      two=$(echo "$k" | cut -d '=' -f2 | tr -d '[:cntrl:]')
      val=$(echo "$k" | cut -d '=' -f1 | tr -d '[:cntrl:]')
      [[ $now != "$two" ]] && {
        echo "- [!]:$val设置失败,设置为:$two,实际为:$now"
        resetprop "$val" "$two"
        pp=$(getprop "$val")
        echo "- [i]:尝试重新设置$val,设置为:$pp"
      }
    done
    let prop_on++
    echo -n "$prop_on" >"$HChen"/Prop_on
  }
  echo "- [i]:修改prop参数完毕"
  [[ -f $qcom_now_file ]] && [[ $(du -k "$HChen/Qualcomm" | cut -f1) -eq 0 ]] && { echo "- [!]:修改后高通配置文件为空"; }
  [[ -f "$HChen"/Qualcomm ]] && { { [[ $(du -k "$HChen/Qualcomm" | cut -f1) -ne 0 ]] && { echo "- [i]:读取高通专改内容" && cat "$HChen"/Qualcomm; }; } || { echo "- [!]:高通专改修改内容为空"; }; }
}
other_mod() {
  [[ $dont_kill == "on" ]] && { echo "- [i]:已成功安装附加模块"; }
  [[ $close_kuaiba == "on" ]] && { echo "- [i]:已成功处理MTK快霸"; }
  { [[ $close_athena == "on" ]] && { echo "- [i]:已成功处理OPPO系雅典娜"; }; } || { [[ $close_athena == "off" ]] && echo "- [!]:未处理OPPO系雅典娜"; }
}
thread_binding() {
  other_bin kswapd "$(mask 11110000)" -10
  echo "- [i]:设置kswapd线程成功"
  other_bin oom_reaper "$(mask 00001111)" -6
  echo "- [i]:设置oom_reaper线程成功"
  other_bin lmkd "$(mask 00001111)" -6
  echo "- [i]:设置lmkd线程成功"
}
hot_patch() {
  { [[ -d "/data/adb/modules/Hot_patch/" ]] || [[ -d "/data/adb/ksu/modules/Hot_patch/" ]]; } && {
    rm -rf /data/adb/modules/Hot_patch/
    rm -rf /data/adb/ksu/modules/Hot_patch/
    echo "- [i]:成功删除补丁模块"
  }
}
scene_delete() {
  ksu="/data/adb/ksu/modules"
  magisk="/data/adb/modules"
  check="
  $ksu/scene_swap_controller
  $ksu/swap_controller
  $magisk/scene_swap_controller
  $magisk/swap_controller"
  for s in $check; do [[ -d $s ]] && touch "$s"/disable && touch "$s"/remove && delete=yes; done
}
last_mod() {
  { [[ $record != "0" ]] && {
    send_notifications "提示:为了所有修改完全生效请再重启一次!$(echo -en "\n正在进行音量键监听!")$(echo -en "\n按音量上键自动重启")$(echo -en "\n按音量下键手动重启")" "保后台模块"
    volume_keys "注意:超时未检测到音量键，请手动重启!" "注意:即将在10秒后重启!" "注意:已经取消重启，请手动重启!"
  }; } || { [[ $delete == "yes" ]] && {
    send_notifications "警告:发现冲突！模块已经自动处理，请再重启一次!$(echo -en "\n正在进行音量键监听!")$(echo -en "\n按音量上键自动重启")$(echo -en "\n按音量上键手动重启")" "保后台模块"
    volume_keys "注意:超时未检测到音量键，请手动重启!" "注意:即将在10秒后重启!" "注意:已经取消重启，请手动重启!"
  }; } || {
    time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
    send_notifications "$(echo -en "保后台模块成功启动!")$(echo -en "\n启动时间:$time")$(echo -en "\n设置ZRAM大小:$zram_size")$(echo -en "\n设置压缩模式:$tt")" "保后台模块"
  }
}
{
  chmod_mod 666 /sys/class/block/zram0/comp_algorithm
  chmod_mod 666 /sys/block/zram0/disksize
  chmod_mod 666 /proc/sys/vm/swappiness
  chmod_mod 666 /proc/sys/vm/watermark_scale_factor
}
{
  scene_delete
  set_zram
  set_vm_params
  other_setting
  on_prop_pool
  other_mod
  thread_binding
  hot_patch
  sleep 10 && {
    last_mod
  }
}
