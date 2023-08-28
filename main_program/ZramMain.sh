#Author by @焕晨HChen
# 更改selinux规则
magiskpolicy --live "allow system_server * * *"
# 配置路径和变量
{ HChen=$(echo ${0%/*} | sed 's/\/main_program//g') || { echo "- [!]:路径获取失败" && exit 1; }; }
path="/main_program" && chmod -R 0777 "$HChen"$path/
swapIni="$HChen/swap/swap.ini"
compFile="/sys/class/block/zram0/comp_algorithm"
a="15000000" && b="11000000" && c="7000000" && d="5000000" && e="3000000"
f="19" && g="16" && h="12" && i="10" && j="8" && k="6"
isKsu=false && record=0
[[ -f "/data/adb/ksud" ]] && isKsu=true
# 检查并导入文件
{
  [[ -f $swapIni ]] && { . "$swapIni" && echo "- [i]:配置文件读取成功"; } || {
    echo "- [!]:配置文件读取异常" && exit 1
  }
} || { echo "- [!]: 缺少$swapIni" && exit 3; }
# 配置可执行文件路径
{
  [[ -f "$bin"/swapon ]] && alias swapon="\$bin/swapon" && alias swapoff="\$bin/swapoff" && alias mkswap="\$bin/mkswap"
} || { [[ -f $vbin/swapon ]] && alias swapon="\$vbin/swapon" && alias swapoff="\$vbin/swapoff" && alias mkswap="\$vbin/mkswap"; }
# 输出日志
setValueLog() { {
  echo "- [i]:设置$2" && {
    now=$(cat "$2" | head -n 1) || true
  } && {
    [[ $1 == "$now" ]] && echo "- [i]:目标设置为:$1,实际设置为:$now"
  }
} || { echo "- [!]:目标设置为:$1,实际设置为:$now"; }; }
# 设置参数
setValue() { {
  [[ -f $2 ]] && { {
    chmod 666 "$2" &>/dev/null || true
  } && { { echo "$1" >"$2" && {
    chmod 664 "$2" &>/dev/null || true
  } && setValueLog "$1" "$2"; } || { echo "- [!]:无法写入$2文件"; }; }; }
} || { echo "- [!]:不存在$2文件"; }; }
updateOverlay() { {
  sed -i "s/\(Name=\"$1\"[[:blank:]]*Value=\"\)[^\"]*\(\"\)/\1$2\2/g" "$qcomNFile" && { grep -q "Name=\"$1\"[[:blank:]]*Value=\"$2\"" "$qcomNFile"; }
} && { echo "$1=$2" >>"$HChen"/Qualcomm; }; }
# 发送通知
sendTz() {
  {
    { [[ $(pm list package | grep -w 'com.google.android.ext.services') != "" ]] && cmd notification allow_assistant "com.google.android.ext.services/android.ext.services.notification.Assistant"; } || true
  } && {
    su -lp 2000 -c "cmd notification post -S messaging --conversation '$2' --message '$2':'$1' Tag '$RANDOM'" &>/dev/null
  }
}
# 监听音量键
volumeKeys() {
  timeout=0
  while :; do
    sleep 0.5 && let timeout++
    [[ $timeout -gt 30 ]] && { sendTz "$1" "保后台模块" && break; }
    volume="$(getevent -qlc 1 | awk '{ print $3 }')"
    case "$volume" in
    KEY_VOLUMEUP) sendTz "$2" "保后台模块" && sleep 10 && reboot ;;
    KEY_VOLUMEDOWN) sendTz "$3" "保后台模块" ;;
    *) continue ;; esac
    break
  done
}
forMod() { for i in $1; do $2 $3 $4 $5 $i$6 $7; done; }
echo "---------------------------------------------------------------------------"
# 设置Zram参数
setZram() {
  # 检查是否支持
  [[ ! -e /dev/block/zram0 ]] && { {
    [[ -e /sys/class/zram-control ]] && echo "- [i]:内核支持ZRAM"
  } || { echo "- [!]:内核不支持ZRAM" && return; }; }
  zramAll=$(grep 'MemTotal' </proc/meminfo | tr -cd "0-9")
  { [[ $zramAll -gt $a ]] && zramSize=$f; } || {
    [[ $zramAll -gt $b ]] && zramSize=$g
  } || {
    [[ $zramAll -gt $c ]] && zramSize=$h
  } || {
    [[ $zramAll -gt $d ]] && zramSize=$i
  } || {
    [[ $zramAll -gt $e ]] && zramSize=$j
  } || { zramSize=$k; }
  [[ $zramSize == 0 ]] && echo "- [!]:ZRAM大小错误" && return
  zramSize=$(awk 'BEGIN{print '$zramSize'*(1024^3)}')
  # 关闭zram
  echo "- [i]:重置ZRAM"
  for z in /dev/block/zram*; do
    swapoff "$z" &>/dev/null
  done
  # 禁用系统回写
  setValue none /sys/block/zram0/backing_dev
  setValue 1 /sys/block/zram0/writeback_limit_enable
  setValue 0 /sys/block/zram0/writeback_limit
  #重置zram
  setValue 1 /sys/block/zram0/reset
  #zram限制
  setValue 0 /sys/block/zram0/mem_limit
  #设置压缩线程
  setValue 8 /sys/block/zram0/max_comp_streams
  echo "- [i]:设置压缩模式"
  echo "$comp_algorithm" >$compFile
  cp=$(cat $compFile | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g' | grep -w "$comp_algorithm")
  {
    [[ $comp_algorithm == "$cp" ]] && echo "- [i]:目标设置为:$comp_algorithm,实际设置为:$cp"
  } || { echo "- [!]:目标设置为:$comp_algorithm,实际设置为:$cp"; }
  echo "- [i]:设置ZRAM"
  setValue "$zramSize" /sys/block/zram0/disksize
  echo "- [i]:初始化ZRAM"
  mkswap /dev/block/zram0 &>/dev/null
  echo "- [i]:启动ZRAM"
  swapon /dev/block/zram0 &>/dev/null
}
# 设置Vm参数
setVm() {
  echo "---------------------------------------------------------------------------"
  swapN="/proc/sys/vm/swappiness"
  echo "160" >$swapN
  {
    [[ $? -eq 1 ]] && {
      swappiness=95
    }
  } || {
    swappiness=160
  }
  echo "- [i]:设置swappiness"
  setValue "$swappiness" $swappinessd
  setValue "$swappiness" /dev/memcg/memory.swappiness
  setValue "$swappiness" /dev/memcg/apps/memory.swappiness
  setValue "$swappiness" /sys/fs/cgroup/memory/apps/memory.swappiness
  setValue "$swappiness" /sys/fs/cgroup/memory/memory.swappiness
  { [[ $zramAll -gt $a ]] && waterM=500; } || {
    [[ $zramAll -gt $b ]] && waterM=450
  } || {
    [[ $zramAll -gt $c ]] && waterM=400
  } || {
    [[ $zramAll -gt $d ]] && waterM=350
  } || {
    [[ $zramAll -gt $e ]] && waterM=300
  } || { waterM=250; }
  echo "- [i]:设置watermark_scale_factor"
  setValue "$waterM" /proc/sys/vm/watermark_scale_factor
  #设置cache参数
  {
    echo "- [i]:设置cache参数"
    setValue 10 /proc/sys/vm/dirty_background_ratio
    setValue 80 /proc/sys/vm/dirty_ratio
    setValue 2000 /proc/sys/vm/dirty_expire_centisecs
    setValue 300 /proc/sys/vm/dirty_writeback_centisecs
    setValue 150 /proc/sys/vm/vfs_cache_pressure
    #设置其它vm参数
    echo "- [i]:设置其它vm参数"
    # 杀死触发oom的那个进程
    setValue 1 /proc/sys/vm/oom_kill_allocating_task
    # 是否打印 oom日志
    setValue 0 /proc/sys/vm/oom_dump_tasks
    # 是否要允许压缩匿名页
    setValue 1 /proc/sys/vm/compact_unevictable_allowed
    # io调试开关
    setValue 0 /proc/sys/vm/block_dump
    # vm 状态更新频率
    setValue 20 /proc/sys/vm/stat_interval
    # 是否允许过量使用运存
    #  setValue 200 /proc/sys/vm/overcommit_ratio
    setValue 1 /proc/sys/vm/overcommit_memory
    # 触发oom后怎么抛异常
    setValue 0 /proc/sys/vm/panic_on_oom
    #  压缩内存节省空间（会导致kswap0异常）
    #  setValue 1 /proc/sys/vm/compact_memory
    #  watermark_boost_factor用于优化内存外碎片化
    #  setValue 100 /proc/sys/vm/watermark_boost_factor
    #  参数越小越倾向于进行内存规整，越大越不容易进行内存规整。
    #  setValue 400 /proc/sys/vm/extfrag_threshold
    # 禁用高通内存回收机制（ppr）
    setValue 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
    # 禁用 mi_reclaim
    setValue 0 /sys/kernel/mi_reclaim/enable
    # 每次换入的内存页
    {
      [[ $comp_algorithm == "zstd" ]] && {
        setValue 0 /proc/sys/vm/page-cluster
      }
    } || {
      setValue 1 /proc/sys/vm/page-cluster
    }
  }
}
# 设置其他参数
otherSetting() {
  lowMem="/sys/module/lowmemorykiller/parameters"
  # Linux Kernel 4.9 前的内核
  [[ -d $lowMem ]] && {
    setValue 1,2,3,4,5,6 $lowMem/minfree
    setValue 0 $lowMem/vmpressure_file_min
    setValue 0 $lowMem/enable_adaptive_lmk
    setValue 0 $lowMem/oom_reaper
    echo "- [i]:设置lmk参数(旧内核)"
  }
  #io调度优化
  for io in /sys/block/sd*; do
    #    io2=$(echo "$io" | sed 's/\/sys\/block\///g')
    setValue deadline "$io"/queue/scheduler
    setValue 256 "$io"/queue/read_ahead_kb
    setValue 64 "$io"/queue/nr_requests
    setValue 2 "$io"/queue/rq_affinity
  done
  echo "- [i]:设置io调度参数"
  # 禁止Miui相机杀后台
  camFile="/system/system_ext/etc/camerabooster.json"
  {
    [[ $isKsu != "true" ]] && {
      camFol="$HChen/system/system_ext/etc/" && camNFile="$HChen/system/system_ext/etc/camerabooster.json"
    }
  } || { camFol="$HChen/system_ext/etc/" && camNFile="$HChen/system_ext/etc/camerabooster.json"; }
  [[ -f $camFile ]] && { { [[ ! -f $camNFile ]] && {
    let record++
    mkdir -p "$camFol"
    cp -f "$camFile" "$camFol" && {
      sed -i "s/\"cam_boost_enable\": true/\"cam_boost_enable\": false/g" "$camNFile"
      echo "- [i]:已优化相机杀后台"
    } || { echo "- [!]:复制相机配置文件失败"; }
  }; } || { {
    [[ $(du -k "$camNFile" | cut -f1) -ne 0 ]] && {
      echo "- [i]:已优化相机杀后台"
    }
  } || { echo "- [!]:修改后cam配置文件为空"; }; }; }
  # 设置高通参数
  qcomFile="/vendor/etc/perf/perfconfigstore.xml"
  qcomPeop="$HChen$path/QcomProp.HChen"
  {
    [[ $isKsu != "true" ]] && { qcomFol="$HChen/system/vendor/etc/perf/" && qcomNFile="$HChen/system$qcomFile"; }
  } || { qcomFol="$HChen/vendor/etc/perf/" && qcomNFile="$HChen$qcomFile"; }
  [[ "$(getprop ro.hardware)" == "qcom" ]] && { {
    [[ -f $qcomFile ]] && [[ $(du -k "$qcomFile" | cut -f1) -ne 0 ]] && {
      { [[ ! -f $qcomNFile ]] && {
        mkdir -p "$qcomFol"
        cp -f "$qcomFile" "$qcomFol"
        touch "$HChen"/Qualcomm
        for a in $(cat $qcomPeop); do
          n=$(echo $a | cut -f1 -d '=')
          v=$(echi $a | cut -f2 -d '=')
          updateOverlay $n $v
        done
        let record++
        echo "- [i]:执行高通参数修改"
      }; } || { echo "- [i]:执行高通参数修改"; }
    }
  } || { echo "- [!]:源文件为空，无法进行高通参数修改"; }; }
}
# 设置系统Prop
propOn() {
  echo "- [i]:进行prop参数修改"
  systemProp="$HChen$path/SystemProp.HChen"
  [[ -f "$HChen"/prop ]] && prop=$(cat "$HChen"/prop)
  { [[ $prop == 0 ]] && {
    let record++
    echo "vtools.swap.controller=module" >"$HChen"/system.prop
    for a in $(cat $systemProp); do
      n=$(echo $a | cut -f1 -d '=')
      v=$(echo $a | cut -f2 -d '=')
      [[ $(getprop $n) != "" ]] && {
        resetprop -n $n $v
        echo "$n=$v"
        echo "$n=$v" >>"$HChen"/system.prop
      }
    done
    echo -n "1" >"$HChen"/prop
  }; } || {
    pck=$(cat "$HChen"/system.prop)
    echo "- [i]:加载prop参数列表"
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
    let propNum++
    echo -n "$propNum" >"$HChen"/prop
  }
  echo "- [i]:修改prop参数完毕"
  [[ -f $qcomNFile ]] && [[ $(du -k "$HChen/Qualcomm" | cut -f1) -eq 0 ]] && { echo "- [!]:修改后高通配置文件为空"; }
  [[ -f "$HChen"/Qualcomm ]] && { {
    [[ $(du -k "$HChen/Qualcomm" | cut -f1) -ne 0 ]] && { echo "- [i]:读取修改的高通参数内容" && cat "$HChen"/Qualcomm; }
  } || { echo "- [!]:高通参数修改内容为空"; }; }

}
# 打印其他日志
otherMod() {
  [[ $dont_kill == "on" ]] && { echo "- [i]:已安装附加模块"; }
  [[ $close_kuaiba == "on" ]] && { echo "- [i]:已处理MTK快霸"; }
  {
    [[ $close_athena == "on" ]] && { echo "- [i]:已处理OPPO系雅典娜"; }
  } || { [[ $close_athena == "off" ]] && echo "- [!]:未处理OPPO系雅典娜"; }
}
# 设置部分线程优先级
binDing() {
  Mask() { echo "obase=16;$((2#$1))" | xargs echo $(bc); }
  OtherBin() {
    forMod "$(pgrep "$1")" "taskset" "-p" "$2" "" "" "" &>/dev/null
    forMod "$(pgrep "$1")" "renice" "-n" "$3" "-p" "" "" &>/dev/null
  }
  OtherBin kswapd "$(Mask 11110000)" -10
  echo "- [i]:设置kswapd线程"
  OtherBin oom_reaper "$(Mask 00001111)" -6
  echo "- [i]:设置oom_reaper线程"
  OtherBin lmkd "$(Mask 00001111)" -6
  echo "- [i]:设置lmkd线程"
}
# 删除冲突
sceneDelete() {
  ksu="/data/adb/ksu/modules"
  magisk="/data/adb/modules"
  check="
  $ksu/scene_swap_controller
  $ksu/swap_controller
  $magisk/scene_swap_controller
  $magisk/swap_controller"
  for s in $check; do [[ -d $s ]] && touch "$s"/disable && touch "$s"/remove && delete=yes; done
}
# 发送通知
lastMod() {
  { [[ $record != "0" ]] && {
    echo "- [!]:为完全生效请再重启一次"
    sendTz "提示:为了所有修改完全生效请再重启一次!$(echo -en "\n正在进行音量键监听!")$(echo -en "\n按音量上键自动重启")$(echo -en "\n按音量下键手动重启")" "保后台模块"
    volumeKeys "注意:超时未检测到音量键，请手动重启!" "注意:即将在10秒后重启!" "注意:已经取消重启，请手动重启!"
  }; } || { [[ $delete == "yes" ]] && {
    echo "- [!]:发现冲突请再重启一次"
    sendTz "警告:发现冲突！模块已经自动处理，请再重启一次!$(echo -en "\n正在进行音量键监听!")$(echo -en "\n按音量上键自动重启")$(echo -en "\n按音量上键手动重启")" "保后台模块"
    volumeKeys "注意:超时未检测到音量键，请手动重启!" "注意:即将在10秒后重启!" "注意:已经取消重启，请手动重启!"
  }; } || {
    time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
    sendTz "$(echo -en "保后台模块成功启动!")$(echo -en "\n启动时间:$time")$(echo -en "\n设置ZRAM大小:$(cat /sys/block/zram0/disksize)")$(echo -en "\n设置压缩模式:$cp")" "保后台模块"
  }
}
# 赋权
{
  chmod 666 /sys/class/block/zram0/comp_algorithm
  chmod 666 /sys/block/zram0/disksize
  chmod 666 /proc/sys/vm/swappiness
  chmod 666 /proc/sys/vm/watermark_scale_factor
}
{
  sceneDelete
  setZram
  setVm
  otherSetting
  propOn
  otherMod
  binDing
  sleep 10 && {
    lastMod
  }
}
