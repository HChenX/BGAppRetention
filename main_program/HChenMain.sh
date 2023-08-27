#Author by @焕晨HChen
magiskpolicy --live "allow system_server * * *"
{ HChen=$(echo "${0%/*}" | xargs echo "$(sed 's/\/main_program//g')") || {
  echo "- [!]:获取路径失败" && exit 55
}; }
mod="$HChen$file/HChenMod.sh" && value="$HChen$file/HChenValue.sh" && name="$HChen$file/HChenName.sh"
file="/main_program" && chmod -R 0777 "$HChen"$file/
{ { [[ -f $mod ]] && [[ -f $value ]] && [[ -f $name ]]; } && {
  . $mod && . $value && . $name
}; } || { echo "- [!]:缺少关键文件" && exit 99; }
{
  [[ -f $swap_conf ]] && { . "$swap_conf" && echo "- [i]:配置文件读取成功"; } || { echo "- [!]:配置文件读取异常" && exit 1; }
} || { echo "- [!]: 缺少$swap_conf" && exit 2; }
{
  [[ -f "$bin"/swapon ]] && alias swapon="\$bin/swapon" && alias swapoff="\$bin/swapoff" && alias mkswap="\$bin/mkswap"
} || { [[ -f $vbin/swapon ]] && alias swapon="\$vbin/swapon" && alias swapoff="\$vbin/swapoff" && alias mkswap="\$vbin/mkswap"; }
echo "---------------------------------------------------------------------------"
set_zram() {
  [[ ! -e /dev/block/zram0 ]] && { {
    [[ -e /sys/class/zram-control ]] && echo "- [i]:内核支持ZRAM"
  } || { echo "- [!]:内核不支持ZRAM" && return; }; }
  ZramValue
  zram_size=$(awk 'BEGIN{print '$zram_in'*('$g'^'$d')}') && { [[ $zram_size == "0" ]] && return; }
  CloseZram
  name=($(NameZram)) && value=($(ValueZram))
  for i in "${!name[@]}"; do SetValue "${value[i]}" "${name[i]}"; done
  echo "- [i]:正在设置压缩模式"
  echo "$comp_algorithm" >$comp_file
  cp=$(CatMod $comp_file | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g' | grep -w "$comp_algorithm")
  { [[ $comp_algorithm == "$cp" ]] && echo "- [i]:目标设置为:$comp_algorithm,实际设置为:$cp"; } || { echo "- [!]:目标设置为:$comp_algorithm,实际设置为:$cp"; }
  echo "- [i]:正在设置ZRAM大小"
  SetValue "$zram_size" $disksize
  Opens
}
set_vm_params() {
  echo "---------------------------------------------------------------------------"
  echo "- [i]:正在设置swappiness"
  VmValue
  SetValue "$swappiness" $swappinessd
  ForMod "$(NameSwap)" "SetValue" "$swappiness" "" "" "" ""
  echo "- [i]:正在设置watermark"
  SetValue "$watermark" $watermark_file
  echo "- [i]:设置cache/vm参数"
  name=($(NameVm)) && value=($(ValueVm))
  for i in "${!name[@]}"; do SetValue "${value[i]}" "${name[i]}"; done
  { [[ $comp_algorithm == "zstd" ]] && SetValue 0 "$proc"/page-cluster; } || { SetValue 1 "$proc"/page-cluster; }
}
other_setting() {
  [[ -d $lowmemorykiller ]] && {
    name=($(NameLow)) && value=($(ValueLow))
    for i in "${!name[@]}"; do SetValue "${value[i]}" "${name[i]}"; done
    echo "- [i]:设置lmk优化(旧内核)"
  }
  OtherVm
  echo "- [i]:设置io调度参数完成"
  [[ -d $dev ]] && { mem=$(find "$dev" -maxdepth 1 -type d | sed "1d") && [[ $mem != "" ]] && {
    for i in $mem; do
      for m in $(MemValue1); do SetValue "-1" "$i""$m"; done
      for v in $(MemValue2); do SetValue "1" "$i""$v"; done
    done
    echo "- [i]:设置memcg参数完成"
  }; }
  [[ -f /sys/kernel/mm/lru_gen/enabled ]] && { SetValue y /sys/kernel/mm/lru_gen/enabled && echo "- [i]:设置开启multi-gen LRU"; }
  {
    [[ $ksu_check != "true" ]] && { camera_folder="$HChen/system/system_ext/etc/" && camera_now_file="$HChen/system/system_ext/etc/camerabooster.json"; }
  } || { camera_folder="$HChen/system_ext/etc/" && camera_now_file="$HChen/system_ext/etc/camerabooster.json"; }
  [[ -f $camera_file ]] && { { [[ ! -f $camera_now_file ]] && {
    let record++
    mkdir -p "$camera_folder"
    cp -f "$camera_file" "$camera_folder" && {
      ForMod "$(NameCam)" "CameraMod" "" "" "" "" "false"
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
        name=($(NameQcom)) && value=($(ValueQcom))
        for i in "${!name[@]}"; do UpdateOverlay "${name[i]}" "${value[i]}"; done
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
    name=($(NameProp)) && value=($(ValueProp))
    for i in "${!name[@]}"; do
      [[ $(getprop "${name[i]}") != "" ]] && {
        resetprop -n "${name[i]}" "${value[i]}"
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
        resetprop -n "$val" "$two"
        new=$(getprop "$val")
        echo "- [i]:尝试重新设置$val,设置为:$new"
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
  OtherBin kswapd "$(Mask 11110000)" -10
  echo "- [i]:设置kswapd线程成功"
  OtherBin oom_reaper "$(Mask 00001111)" -6
  echo "- [i]:设置oom_reaper线程成功"
  OtherBin lmkd "$(Mask 00001111)" -6
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
    send_notifications "$(echo -en "保后台模块成功启动!")$(echo -en "\n启动时间:$time")$(echo -en "\n设置ZRAM大小:$(cat $disksize)")$(echo -en "\n设置压缩模式:$cp")" "保后台模块"
  }
}
{
  ChmodMod 666 /sys/class/block/zram0/comp_algorithm
  ChmodMod 666 /sys/block/zram0/disksize
  ChmodMod 666 /proc/sys/vm/swappiness
  ChmodMod 666 /proc/sys/vm/watermark_scale_factor
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
