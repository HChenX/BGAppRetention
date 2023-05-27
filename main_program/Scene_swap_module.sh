#全局变量
huanchen=${0%/*}
huanchen=${huanchen//\/main_program/}
sdk=$(getprop ro.system.build.version.sdk)
origin_file="/system/vendor/etc/perf/perfconfigstore.xml"
origin_folder="$huanchen/system/vendor/etc/perf/"
overlay_file="$huanchen$origin_file"

#设置变量
{
  [[ -f /system/bin/swapon ]] && {
    alias swapon="/system/bin/swapon"
    alias swapoff="/system/bin/swapoff"
    alias mkswap="/system/bin/mkswap"
    alias settings="/system/bin/settings"
    alias device_config="/system/bin/device_config"
  }
} || {
  [[ -f /vendor/bin/swapon ]] && {
    alias swapon="/vendor/bin/swapon"
    alias swapoff="/vendor/bin/swapoff"
    alias mkswap="/vendor/bin/mkswap"
    alias settings="/vendor/bin/settings"
    alias device_config="/vendor/bin/device_config"
  }
}

#获取物理运存大小
zram_size_out=$(grep 'MemTotal' </proc/meminfo | tr -cd "0-9")

#读取配置文件内容
swap_conf="$huanchen/swap/swap.ini"
{
  [[ -f $swap_conf ]] && {
    . "$swap_conf" && {
      echo "- [i]: 配置文件读取成功"
    }
  } || {
    echo "- [!]: 配置文件读取异常" && exit 1
  }
} || {
  echo "- [!]: 缺少$swap_conf" && exit 2
}

#显示log
set_value_log() {
  echo "- [i]:设置$2"
  now=$(cat "$2")
  {
    [[ $1 == "$now" ]] && {
      echo "- [i]:目标设置为:$1,实际设置为:$now"
    }
  } || {
    echo "- [!]:目标设置为:$1,实际设置为:$now"
  }
}

#设置参数
set_value() {
  {
    [[ -f "$2" ]] && {
      chmod 666 "$2" &>/dev/null
      echo "$1" >"$2"
      chmod 664 "$2" &>/dev/null
      set_value_log "$1" "$2"
    }
  } || {
    echo "- [!]: 不存在$2文件"
  }
}

#修改高通文件
Update_overlay() {
  {
    sed -i "s/Name=\"$1\" Value=\".*\"/Name=\"$1\" Value=\"$2\"/" "$overlay_file" && {
      grep -q "<Prop Name=\"$1\" Value=\"$2\" />" "$overlay_file"
    }
  } && {
    echo "$1=$2" >>"$huanchen"/Qualcomm
  }
}

# 解析配置
echo "---------------------------------------------------------------------------"

#设置zram
set_zram() {
  [[ ! -e /dev/block/zram0 ]] && {
    {
      [[ -e /sys/class/zram-control ]] && {
        echo "- [i]:内核支持ZRAM"
      }
    } || {
      echo "- [!]:内核不支持ZRAM"
      return
    }
  }

  #请根据你手机物理内存大小更改
  #直接更改前面的”15“”11“等就行
  {
    [[ $zram_size_out -gt 15000000 ]] && {
      zram_size_in=19
    }
  } || {
    [[ $zram_size_out -gt 11000000 ]] && {
      zram_size_in=15
    }
  } || {
    [[ $zram_size_out -gt 7000000 ]] && {
      zram_size_in=11
    }
  } || {
    [[ $zram_size_out -gt 5000000 ]] && {
      zram_size_in=9
    }
  } || {
    [[ $zram_size_out -gt 3000000 ]] && {
      zram_size_in=7
    }
  } || {
    zram_size_in=5
  }

  #换算大小
  zram_size=$(awk 'BEGIN{print '$zram_size_in'*(1024^3)}')

  echo "- [i]:重置ZRAM所有设置"
  #关闭所有zram
  for z in /dev/block/zram*; do
    swapoff "$z" &>/dev/null
  done

  [[ $zram_size == "0" ]] && return

  # 禁用系统回写
  set_value none /sys/block/zram0/backing_dev
  set_value 1 /sys/block/zram0/writeback_limit_enable
  set_value 0 /sys/block/zram0/writeback_limit

  #重置zram
  set_value 1 /sys/block/zram0/reset

  #zram限制
  set_value 0 /sys/block/zram0/mem_limit

  #设置压缩线程
  set_value 8 /sys/block/zram0/max_comp_streams

  echo "- [i]:正在设置压缩模式"
  echo "$comp_algorithm" >/sys/class/block/zram0/comp_algorithm
  tt=$(cat /sys/class/block/zram0/comp_algorithm)
  ttt=$(echo "$tt" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g' | grep "$comp_algorithm")
  [[ $comp_algorithm == "$ttt" ]] && echo "- [i]:目标设置为:$comp_algorithm,实际设置为:$ttt"
  [[ $comp_algorithm != "$ttt" ]] && echo "- [!]:目标设置为:$comp_algorithm,实际设置为:$ttt"

  echo "- [i]:正在设置ZRAM大小"
  echo "$zram_size" >/sys/block/zram0/disksize
  pk=$(cat /sys/block/zram0/disksize)
  [[ $pk == "$zram_size" ]] && echo "- [i]:目标设置为:$zram_size,实际设置为:$pk"
  [[ $pk != "$zram_size" ]] && echo "- [!]:目标设置为:$zram_size,实际设置为:$pk"

  echo "- [i]:初始化ZRAM"
  mkswap /dev/block/zram0 &>/dev/null

  echo "- [i]:启动ZRAM"
  swapon /dev/block/zram0 &>/dev/null
}

#设置vm参数
set_vm_params() {
  echo "---------------------------------------------------------------------------"

  #设置swappiness
  swappinessd="/proc/sys/vm/swappiness"
  echo "160" >$swappinessd
  {
    [[ $? -eq 1 ]] && {
      swappiness=95
    }
  } || {
    swappiness=160
  }

  echo "- [i]:正在设置swappiness"
  echo "$swappiness" >$swappinessd
  tk=$(cat $swappinessd)
  [[ $tk == "$swappiness" ]] && echo "- [i]:目标设置为:$swappiness,实际设置为:$tk"
  [[ $tk != "$swappiness" ]] && echo "- [!]:目标设置为:$swappiness,实际设置为:$tk"

  set_value "$swappiness" /dev/memcg/memory.swappiness
  set_value "$swappiness" /dev/memcg/apps/memory.swappiness
  set_value "$swappiness" /sys/fs/cgroup/memory/apps/memory.swappiness
  set_value "$swappiness" /sys/fs/cgroup/memory/memory.swappiness

  #设置watermark_scale_factor
  {
    [[ $zram_size_out -gt 15000000 ]] && {
      watermark_scale_factor=500
    }
  } || {
    [[ $zram_size_out -gt 11000000 ]] && {
      watermark_scale_factor=450
    }
  } || {
    [[ $zram_size_out -gt 7000000 ]] && {
      watermark_scale_factor=400
    }
  } || {
    [[ $zram_size_out -gt 5000000 ]] && {
      watermark_scale_factor=350
    }
  } || {
    [[ $zram_size_out -gt 3000000 ]] && {
      watermark_scale_factor=300
    }
  } || {
    watermark_scale_factor=250
  }

  echo "- [i]:正在设置watermark_scale_factor"
  echo "$watermark_scale_factor" >/proc/sys/vm/watermark_scale_factor
  lt=$(cat /proc/sys/vm/watermark_scale_factor)
  [[ $lt == "$watermark_scale_factor" ]] && echo "- [i]:目标设置为:$watermark_scale_factor,实际设置为:$lt"
  [[ $lt != "$watermark_scale_factor" ]] && echo "- [!]:目标设置为:$watermark_scale_factor,实际设置为:$lt"

  #设置cache参数
  {
    echo "- [i]:设置cache参数"
    set_value 10 /proc/sys/vm/dirty_background_ratio
    set_value 80 /proc/sys/vm/dirty_ratio
    set_value 2000 /proc/sys/vm/dirty_expire_centisecs
    set_value 300 /proc/sys/vm/dirty_writeback_centisecs
    set_value 150 /proc/sys/vm/vfs_cache_pressure

    #设置其它vm参数
    echo "- [i]:设置其它vm参数"
    # 杀死触发oom的那个进程
    set_value 1 /proc/sys/vm/oom_kill_allocating_task
    # 是否打印 oom日志
    set_value 0 /proc/sys/vm/oom_dump_tasks
    # 是否要允许压缩匿名页
    set_value 1 /proc/sys/vm/compact_unevictable_allowed
    # io调试开关
    set_value 0 /proc/sys/vm/block_dump
    # vm 状态更新频率
    set_value 20 /proc/sys/vm/stat_interval
    # 是否允许过量使用运存
    #  set_value 200 /proc/sys/vm/overcommit_ratio
    set_value 1 /proc/sys/vm/overcommit_memory
    # 触发oom后怎么抛异常
    set_value 0 /proc/sys/vm/panic_on_oom
    #压缩内存节省空间（会导致kswap0异常）
    #  set_value 1 /proc/sys/vm/compact_memory
    #watermark_boost_factor用于优化内存外碎片化
    #  set_value 100 /proc/sys/vm/watermark_boost_factor
    #参数越小越倾向于进行内存规整，越大越不容易进行内存规整。
    #  set_value 400 /proc/sys/vm/extfrag_threshold
    # 禁用高通内存回收机制（ppr）
    set_value 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
    # 禁用 mi_reclaim
    set_value 0 /sys/kernel/mi_reclaim/enable
    # 每次换入的内存页
    {
      [[ $comp_algorithm == "zstd" ]] && {
        set_value 0 /proc/sys/vm/page-cluster
      }
    } || {
      set_value 1 /proc/sys/vm/page-cluster
    }
  }
}

#其他设置
other_setting() {
  lowmemorykiller="/sys/module/lowmemorykiller/parameters"
  # Linux Kernel 4.9 前的内核
  [[ -d $lowmemorykiller ]] && {
    set_value 1024,1025,1026,1027,1028,1029 $lowmemorykiller/minfree
    set_value 0 $lowmemorykiller/vmpressure_file_min
    set_value 0 $lowmemorykiller/enable_adaptive_lmk
    set_value 0 $lowmemorykiller/oom_reaper
    echo "- [i]:设置lmk优化(旧内核)"
  }

  #io调度优化
  for io in /sys/block/sd*; do
    #    io2=$(echo "$io" | sed 's/\/sys\/block\///g')
    set_value deadline "$io"/queue/scheduler
    set_value 256 "$io"/queue/read_ahead_kb
    set_value 64 "$io"/queue/nr_requests
    set_value 2 "$io"/queue/rq_affinity
  done
  echo "- [i]:设置io调度完成"

  #开启multi-gen LRU
  [[ -f /sys/kernel/mm/lru_gen/enabled ]] && {
    set_value y /sys/kernel/mm/lru_gen/enabled
    echo "- [i]:设置开启multi-gen LRU"
  }

  #检查是否存在指定文件
  [[ -f /system/system_ext/etc/camerabooster.json ]] && {
    {
      [[ ! -f "$huanchen/system/system_ext/etc/camerabooster.json" ]] && {
        echo "- [i]:成功优化相机杀后台问题"
        echo "- [!]:为了完全生效请再重启一次"
        mkdir -p "$huanchen/system/system_ext/etc/"
        cp -f "/system/system_ext/etc/camerabooster.json" "$huanchen/system/system_ext/etc/"
        sed -i 's/"cam_boost_enable": true/"cam_boost_enable": false/g' "$huanchen/system/system_ext/etc/camerabooster.json"
      }
    } || {
      echo "- [i]:成功优化相机杀后台问题"
    }
  }

  #高通专用修改
  {
    [[ ! -f $overlay_file ]] && {
      [[ "$(getprop ro.hardware)" == "qcom" ]] && {
        [[ -f $origin_file ]] && mkdir -p "$origin_folder" && cp -f "$origin_file" "$origin_folder"
        [[ -f $overlay_file ]] && {
          touch "$huanchen"/Qualcomm
          Update_overlay vendor.iop.enable_uxe 1
          Update_overlay vendor.debug.enable.lm false
          Update_overlay vendor.perf.iop_v3.enable true
          Update_overlay vendor.enable.prefetch true
          Update_overlay vendor.iop.enable_prefetch_ofr true
          Update_overlay vendor.iop.enable_speed true
          Update_overlay ro.vendor.qti.sys.fw.bservice_age 900000
          Update_overlay ro.vendor.qti.sys.fw.bservice_limit 114514
          Update_overlay ro.vendor.perf.enable.prekill false
          Update_overlay vendor.prekill_MIN_ADJ_to_Kill 1001
          Update_overlay vendor.prekill_MAX_ADJ_to_Kill 1001
          Update_overlay vendor.debug.enable.memperfd false
          Update_overlay ro.lmk.thrashing_limit_pct_dup 100
          Update_overlay ro.lmk.kill_heaviest_task_dup false
          Update_overlay ro.lmk.kill_timeout_ms_dup 500
          Update_overlay ro.lmk.thrashing_threshold 100
          Update_overlay ro.lmk.thrashing_decay 10
          Update_overlay ro.lmk.nstrat_low_swap 0
          Update_overlay ro.lmk.nstrat_psi_partial_ms 600
          Update_overlay ro.lmk.nstrat_psi_complete_ms 900
          Update_overlay ro.lmk.nstrat_psi_scrit_complete_stall_ms 1000
          Update_overlay ro.lmk.nstrat_wmark_boost_factor 0
          Update_overlay ro.lmk.enhance_batch_kill false
          Update_overlay ro.lmk.enable_watermark_check false
          Update_overlay ro.lmk.enable_preferred_apps false
          Update_overlay vendor.appcompact.enable_app_compact false
          Update_overlay ro.vendor.qti.sys.fw.bg_apps_limit 114514
          Update_overlay ro.vendor.qti.sys.fw.empty_app_percent 0
          Update_overlay ro.lmk.enable_userspace_lmk false
          Update_overlay vendor.perf.phr.enable 0
          Update_overlay ro.vendor.iocgrp.config 1
          Update_overlay ro.lmk.super_critical 1001
          Update_overlay ro.lmk.direct_reclaim_pressure 100
          Update_overlay ro.lmk.reclaim_scan_threshold 1024
          Update_overlay ro.vendor.qti.am.reschedule_service false
          #Update_overlay ro.vendor.qti.sys.fw.bservice_enable false
          #Update_overlay ro.vendor.qti.config.zram false
          #Update_overlay ro.vendor.qti.config.swap false
          echo "- [i]:成功执行高通专改"
          echo "- [!]:为了完全生效请再重启一次"
        }
      }
    }
  } || {
    [[ $(du -k "$overlay_file" | cut -f1) -ne 0 ]] && {
      echo "- [i]:成功执行高通专改"
    }
  }
}

#prop设置
on_prop_pool() {
  #根据系统存在的prop进行修改
  prop_pool="
  ro.config.low_ram=false
  persist.sys.mms.bg_apps_limit=114514
  persist.sys.mms.write_lmkd=false
  persist.sys.mms.camcpt_enable=false
  persist.sys.mms.compact_enable=false
  persist.sys.mms.single_compact_enable=false
  persist.sys.mms.min_zramfree_kb=2147483647
  persist.miui.miperf.enable=false
  ro.vendor.qti.sys.fw.bservice_limit=114514
  persist.device_config.activity_manager.max_cached_processes=114514
  persist.sys.spc.enabled=false
  persist.sys.spc.extra_free_enable=false
  persist.sys.spc.screenoff_kill_enable=false
  ro.config.per_app_memcg=false
  persist.sys.fuse.passthrough.enable=true
  persist.sys.usap_pool_enabled=true
  ro.lmk.use_minfree_levels=false
  ro.lmk.debug=false
  ro.lmk.thrashing_limit=100
  ro.lmk.thrashing_limit_decay=10
  ro.lmk.psi_partial_stall_ms=600
  ro.lmk.psi_complete_stall_ms=900
  ro.lmk.swap_free_low_percentage=0
  ro.lmk.low=1001
  ro.lmk.medium=1001
  ro.lmk.critical=1001
  ro.lmk.critical_upgrade=false
  ro.lmk.upgrade_pressure=100
  ro.lmk.downgrade_pressure=100
  ro.lmk.kill_heaviest_task=false
  ro.lmk.kill_timeout_ms=500
  ro.lmk.enhance_batch_kill=false
  ro.lmk.enable_adaptive_lmk=false
  persist.sys.oom_crash_on_watchdog=false
  persist.sys.lmk.camera.mem_reclaim=false
  persist.sys.lmk.reportkills=false
  sys.lmk.reportkills=0
  vendor.sys.vm.swaplow=5
  ro.lmk.swap_util_max=100
  persist.sys.spc.kill.proc.enable=false
  persist.sys.miui.camera.boost.enable=false
  persist.sys.miui.camera.boost.killAdj_threshold=1001
  persist.sys.miui.camera.boost.kill701_threshold=0
  persist.sys.minfree_6g=1024,1025,1026,1027,1028,1029
  persist.sys.minfree_8g=1024,1025,1026,1027,1028,1029
  persist.sys.minfree_12g=1024,1025,1026,1027,1028,1029
  persist.sys.minfree_def=1024,1025,1026,1027,1028,1029
  persist.sys.lmk.camera_minfree_levels=1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001
  persist.sys.lmk.camera_minfree_6g_levels=1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001
  persist.sys.oplus.hybridswap_app_uid_memcg=false
  persist.sys.oplus.hybridswap_app_memcg=false
  sys.lmk.minfree_levels=1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001
  persist.sys.debug.enable_scout_memory_monitor=false
  persist.sys.debug.enable_scout_memory_resume=false
  persist.sys.miui.adj_swap_free_percentage.enable=false
  vendor.sys.vm.killtimeout=500
  ro.sys.fw.bg_apps_limit=114514
  ro.vendor.qti.sys.fw.bg_apps_limit=114514
  persist.sys.oplus.lmkd_super_critical_threshold_12g=0
  persist.sys.oplus.lmkd_super_critical_threshold_16g=0
  persist.sys.oplus.lmkd_super_critical_threshold_8g=0
  ro.sys.fw.empty_app_percent=0
  persist.vendor.qti.memory.enable=false
  persist.vendor.sys.memplus.enable=false
  persist.vendor.qti.memory.fooI=false
  vendor.iop.enable_uxe=1
  vendor.debug.enable.lm=false
  vendor.perf.iop_v3.enable=true
  vendor.enable.prefetch=true
  vendor.iop.enable_prefetch_ofr=true
  vendor.iop.enable_speed=true
  ro.vendor.qti.sys.fw.bservice_age=900000
  ro.vendor.perf.enable.prekill=false
  vendor.prekill_MIN_ADJ_to_Kill=1001
  vendor.prekill_MAX_ADJ_to_Kill=1001
  vendor.debug.enable.memperfd=false
  ro.lmk.thrashing_limit_pct_dup=100
  ro.lmk.kill_heaviest_task_dup=false
  ro.lmk.kill_timeout_ms_dup=500
  ro.lmk.thrashing_threshold=100
  ro.lmk.thrashing_decay=10
  ro.lmk.nstrat_low_swap=0
  ro.lmk.nstrat_psi_partial_ms=600
  ro.lmk.nstrat_psi_complete_ms=900
  ro.lmk.nstrat_psi_scrit_complete_stall_ms=1000
  ro.lmk.nstrat_wmark_boost_factor=0
  ro.lmk.enable_watermark_check=false
  ro.lmk.enable_preferred_apps=false
  vendor.appcompact.enable_app_compact=false
  ro.vendor.qti.sys.fw.empty_app_percent=0
  ro.lmk.enable_userspace_lmk=false
  vendor.perf.phr.enable=0
  ro.vendor.iocgrp.config=1
  ro.lmk.super_critical=1001
  ro.lmk.direct_reclaim_pressure=100
  ro.lmk.reclaim_scan_threshold=1024
  ro.vendor.qti.am.reschedule_service=false"
  #  old_prop
  #  ro.sys.fw.use_trim_settings=false
  #  用于控制 OnePlus 手机中 UFS 存储器的 SWAP（交换分区）设置。
  #  persist.sys.oplus.nandswap=false
  #  用于控制后台服务（Background Service）的启用和禁用。
  #  ro.vendor.qti.sys.fw.bservice_enable=false
  echo "- [i]:开始进行prop修改"
  [[ -f "$huanchen"/Prop_on ]] && prop_on=$(cat "$huanchen"/Prop_on)
  {
    [[ $prop_on == 0 ]] && {
      echo "- [!]:为了完全生效请再重启一次"
      echo "vtools.swap.controller=module" >"$huanchen"/system.prop
      for p in $prop_pool; do
        check_prop=$(echo "$p" | cut -d '=' -f1)
        [[ $(getprop "$check_prop") != "" ]] && {
          resetprop "$check_prop" "$(echo "$p" | cut -d '=' -f2)"
          echo "$check_prop" "$(getprop "$check_prop")"
          echo "$p" >>"$huanchen"/system.prop
        }
      done
      [[ $sdk != "33" ]] && {
        [[ $(getprop ro.lmk.use_psi) != "" ]] && {
          resetprop ro.lmk.use_psi true
          echo "ro.lmk.use_psi $(getprop ro.lmk.use_psi)"
          echo "ro.lmk.use_psi=true" >>"$huanchen"/system.prop
        }
      }
      echo -n "1" >"$huanchen"/Prop_on
    }
  } || {
    prop_kk=$(cat "$huanchen"/system.prop)
    echo "- [i]:已经加载的prop列表"
    echo "$prop_kk"
    for k in $prop_kk; do
      one=$(getprop "$(echo "$k" | cut -d '=' -f1)")
      two=$(echo "$k" | cut -d '=' -f2 | tr -d '[:cntrl:]')
      kk=$(echo "$k" | cut -d '=' -f1 | tr -d '[:cntrl:]')
      [[ $one != "$two" ]] && {
        echo "- [!]:$kk设置失败,设置为:$two,实际为:$one"
        resetprop "$kk" "$two"
        pp=$(getprop "$kk")
        echo "- [i]:尝试重新设置$kk,设置为:$pp"
      }
    done
    let prop_on++
    echo -n "$prop_on" >"$huanchen"/Prop_on
  }
  echo "- [i]:修改prop设置完毕"

  #显示对高通的修改
  [[ $(du -k "$overlay_file" | cut -f1) -ne 0 ]] && {
    [[ "$(getprop ro.hardware)" == "qcom" ]] && [[ -f "$huanchen"/Qualcomm ]] && {
      echo "- [i]:读取高通专改内容"
      cat "$huanchen"/Qualcomm
    }
  }
}

#进程绑定
set_kswap_task() {
  #绑定进程
  kswapd_cpus=11110000
  mask=$(echo "obase=16;$((2#$kswapd_cpus))" | bc)
  for i in $(pgrep kswapd); do
    taskset -p "$mask" "$i" &>/dev/null
    renice "-10" -p "$i" &>/dev/null
  done
  echo "- [i]:设置kswapd线程成功"

  kswapd_cpusd=00001111
  maskd=$(echo "obase=16;$((2#$kswapd_cpusd))" | bc)
  for a in $(pgrep oom_reaper); do
    taskset -p "$maskd" "$a" &>/dev/null
    renice "-6" -p "$a" &>/dev/null
  done
  echo "- [i]:设置oom_reaper线程成功"

  for b in $(pgrep lmkd); do
    taskset -p "$maskd" "$b" &>/dev/null
    renice "-6" -p "$b" &>/dev/null
  done
  echo "- [i]:设置lmkd线程成功"
}

#处理MTK快霸
close_miui() {
  packages=$(pm list packages -s | sed 's/package://g' | grep 'com.mediatek.duraspeed')
  [[ $(getprop Build.BRAND) == "MTK" ]] && {
    {
      [[ $close_kuaiba == "on" ]] && [[ $packages == "com.mediatek.duraspeed" ]] && {
        pm disable com.mediatek.duraspeed &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedAppReceiver &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.RestrictHistoryActivity &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedMainActivity &>/dev/null
        pm clear com.mediatek.duraspeed &>/dev/null
        echo "- [i]:成功处理MTK快霸"
      }
    } || {
      [[ $close_kuaiba == "on" ]] && echo "- [i]:成功处理MTK快霸"
    }
  }
}

#热补丁自动删除服务
hot_patch() {
  {
    [[ -d "/data/adb/modules/Hot_patch/" ]] || [[ -d "/data/adb/ksu/modules/Hot_patch/" ]]
  } && {
    rm -rf /data/adb/modules/Hot_patch/
    rm -rf /data/adb/ksu/modules/Hot_patch/
    echo "- [i]:成功删除补丁模块"
  }
}

echo "---------------------------------------------------------------------------"

#赋权
{
  chmod 666 /sys/class/block/zram0/comp_algorithm
  chmod 666 /sys/block/zram0/disksize
  chmod 666 /proc/sys/vm/swappiness
  chmod 666 /proc/sys/vm/watermark_scale_factor
}

#开始执行方法
{
  set_zram
  set_vm_params
  other_setting
  on_prop_pool
  set_kswap_task
  close_miui
  hot_patch
}
