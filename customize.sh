#全局变量
sdk=$(getprop ro.system.build.version.sdk)
confs="/data/adb/modules/zram_huanchen"
confs2="/data/adb/ksu/modules/zram_huanchen"
swaps="$MODPATH/swap/swap.ini"
origin_file="/system/vendor/etc/perf/perfconfigstore.xml"
origin_folder="$MODPATH/system/vendor/etc/perf/"
overlay_file="$MODPATH$origin_file"

#延迟输出
Output() {
  echo "$@"
  sleep 0.07
}

#获取路径
if [[ -d $confs ]]; then
  iconf=$confs
elif [[ -d $confs2 ]]; then
  iconf=$confs2
fi

#获取具体文件
if [[ -f "$iconf"/swap/swap.ini ]]; then
  swap_ini=$iconf/swap/swap.ini
else
  swap_ini=$iconf/swap/swap.conf
fi

#读取已安装配置
Get_props() {
  grep -v '^#' <"$swap_ini" | grep "^$1=" | cut -f2 -d '='
}

comp_algorithms=$(Get_props comp_algorithm)
close_kuaiba=$(Get_props close_kuaiba)
reserve=$(Get_props reserve)

#修改高通文件
Update_overlay() {
  if sed -i "s/Name=\"$1\" Value=\".*\"/Name=\"$1\" Value=\"$2\"/" "$overlay_file" &&
    grep -q "<Prop Name=\"$1\" Value=\"$2\" />" "$overlay_file"; then
    echo "$1=$2" >>"$MODPATH"/Qualcomm
  fi
}

#删除已经安装的模块
Delete_cheat() {
  #此代码用于让scene显示已激活
  #先删再创建
  rm -rf /data/swap_config.conf
  echo "请忽略此文件，也请不要删除。" >/data/swap_config.conf
  #删除附加模块2防止冲突
  rm -rf /data/adb/modules/scene_swap_controller/
  rm -rf /data/adb/ksu/modules/scene_swap_controller/
  rm -rf /data/swapfile*
  rm -f /data/swap_recreate
  #删除小阳光模块防止冲突
  rm -rf /data/adb/ksu/modules/swap_controller/
  rm -rf /data/adb/modules/swap_controller/
  rm -rf /data/adb/swap_controller/
  Output "欢迎使用本模块(///ω///)"
  Output "正在安装改版模块！< (ˉ^ˉ)> "
  Output "--------------------------------------------"
  Output "--------------------------------------------"
  echo -en "\n"
}

#安装附加模块
Dont_kill() {
  if [[ "$sdk" -ge 31 ]]; then
    Output "(安卓12/13专属)Don.t.kill模块已安装。"
    Output "模块作用：进一步增强保后台能力。"
    Output "使用方法：lsp里面激活重启即可。"
    Output "模块作者：海浪逃向岛屿"
    unzip -o "$ZIPFILE" 'Don.t.Kill.apk' -d /data/local/tmp/ &>/dev/null
    pm install -r /data/local/tmp/Don.t.Kill.apk &>/dev/null
    rm -rf /data/local/tmp/Don.t.Kill.apk
    rm -rf "$MODPATH"/Don.t.Kill.apk
    echo "
#用于标记是否安装附加模块
dont_kill=on" >>"$swaps"
  else
    echo -en "\n"
    Output "非安卓12/13跳过附加模块安装。"
    rm -rf /data/local/tmp/Don.t.Kill.apk
    rm -rf "$MODPATH"/Don.t.Kill.apk
  fi
}

#下面决定要不要关闭MTK的快霸
Close_kuaiba() {
  packages=$(pm list packages -s | sed 's/package://g' | grep 'com.mediatek.duraspeed')
  if [[ $close_kuaiba == "on" ]]; then
    kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
    kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
    mkdir -p "$MODPATH""$kuaibaapp2"
    touch "$MODPATH""$kuaibaapp"
    echo -en "\n"
    Output "成功处理MTK快霸。"
    echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
  else
    if [[ $(getprop Build.BRAND) == "MTK" ]] && [[ $packages == "com.mediatek.duraspeed" ]]; then
      echo -en "\n"
      Output "(联发科专属)下面决定是否关闭联发科的快霸。"
      Output "作用：防止这玩意杀后台，似乎是残留的东西。"
      #第一层保险
      pm disable com.mediatek.duraspeed &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedAppReceiver &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.RestrictHistoryActivity &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedMainActivity &>/dev/null
      pm clear com.mediatek.duraspeed &>/dev/null
      #第二层保险
      kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
      kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
      mkdir -p "$MODPATH""$kuaibaapp2"
      touch "$MODPATH""$kuaibaapp"
      Output "成功处理MTK快霸。"
      echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
    else
      echo -en "\n"
      echo "不是联发科或不存在快霸软件跳过此步。"
    fi
  fi
}

#决定要不要关闭oppo系手机雅典娜
Athena_close() {
  ui1=$(getprop ro.product.brand.ui | tr '[:upper:]' '[:lower:]')
  ui2=$(getprop ro.product.vendor.manufacturer | tr '[:upper:]' '[:lower:]')
  if [[ "$ui1" == "realmeui" ]] || [[ "$ui1" == "coloros" ]] || [[ "$ui2" == "oneplus" ]] ||
    [[ "$ui2" == "realme" ]] || [[ "$ui2" == "oppo" ]] || [[ "$ui2" == "coloros" ]]; then
    echo -en "\n"
    Output "(oppo系专属)正在关闭雅典娜。"
    Output "作用：防止这玩意杀后台。"
    Output "音量键无法使用的话"
    Output "请随意滑动屏幕即可自动跳过。"
    Output "无事请勿随意滑动屏幕，可能误触。"
    echo -en "\n"
    Output "按音量上➕键确认关闭雅典娜。"
    Output " "
    Output "按音量下➖键取消关闭雅典娜。"
    echo -en "\n"
    timeout=0
    while :; do
      sleep 0.5
      #超时自动退出
      timeout=$((timeout + 1))
      if [[ $timeout -gt 2 ]]; then
        Output "超时未检测到音量键，请重试。"
        echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
        break
      fi
      #监听音量键
      volume="$(getevent -qlc 1 | awk '{ print $3 }')"
      case "$volume" in
      KEY_VOLUMEUP)
        #第一层保险
        pm disable com.oplus.athena &>/dev/null
        pm disable com.coloros.athena &>/dev/null
        pm clear com.oplus.athena &>/dev/null
        pm clear com.coloros.athena &>/dev/null
        #第二层保险
        Athena_such_12="$(find /system/product/ -name Athena.apk 2>/dev/null)"
        Athena_such_13="$(find /system/system_ext/ -name Athena.apk 2>/dev/null)"
        if [[ $Athena_such_12 != "" ]]; then
          Athena_12="${Athena_such_12//Athena.apk/}"
          mkdir -p "$MODPATH""$Athena_12"
          touch "$MODPATH""$Athena_such_12"
        elif [[ $Athena_such_13 != "" ]]; then
          Athena_13="${Athena_such_13//Athena.apk/}"
          mkdir -p "$MODPATH""$Athena_13"
          touch "$MODPATH""$Athena_such_13"
        fi
        Output "成功关闭雅典娜。"
        echo "
#用于标记是否关闭雅典娜
close_athena=on
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
        ;;
      KEY_VOLUMEDOWN)
        Output "取消关闭雅典娜。"
        echo "
#用于标记是否关闭雅典娜
close_athena=off
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
        ;;
      *) continue ;;
      esac
      break
    done
  else
    echo -en "\n"
    Output "不是oppo系跳过此步。"
    echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
  fi
}

#高通专用修改
Qualcomms() {
  [[ -f $origin_file ]] && mkdir -p "$origin_folder" && cp -f "$origin_file" "$origin_folder"
  if [[ "$(getprop ro.hardware)" == "qcom" ]]; then
    if [[ -f $overlay_file ]]; then
      echo -en "\n"
      Output "正在执行高通专改！"
      touch "$MODPATH"/Qualcomm
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
    else
      echo -en "\n"
      Output "不存在文件无法执行！"
      Output "反馈码：qcom"
    fi
  else
    echo -en "\n"
    Output "不是高通跳过修改！"
  fi
}

#检测支持的压缩模式
#自动配置watermark_scale_factor
Other_mode() {
  echo -en "\n"
  Output "正在检测可用压缩模式！"
  if [[ $reserve == "true" ]]; then
    comp_algorithm=$comp_algorithms
  else
    check_result=$(cat /sys/block/zram0/comp_algorithm)
    zram=$(echo "$check_result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
    check_result1=$(echo "$zram" | grep lz4)
    check_result2=$(echo "$zram" | grep zstd)
    check_result3=$(echo "$zram" | grep lzo-rle)
    if [[ "$check_result1" != "" ]]; then
      comp_algorithm=lz4
    elif [[ "$check_result2" != "" ]]; then
      comp_algorithm=zstd
    elif [[ "$check_result3" != "" ]]; then
      comp_algorithm=lzo-rle
    else
      comp_algorithm=lzo
    fi
  fi
  sed -i '12a '"comp_algorithm=$comp_algorithm"'' "$swaps"
  Output "设置zram压缩模式为：$comp_algorithm"

  [[ -f $iconf/Prop_on ]] && {
    [[ $(cat $iconf/Prop_on) != 0 ]] && {
      cp -f $iconf/system.prop "$MODPATH"
      # 填写0触发prop更新
      echo -n "0" >"$MODPATH"/Prop_on
      echo -en "\n"
      Output "成功获取历史文件。"
    }
  }
  #删除已有文件
  rm -rf $iconf/system.prop
}

#默认权限
Other_settings() {
  set_perm_recursive "$MODPATH" 0 0 0777 0777
}

#定位（勿删）
Delete_cheat
Dont_kill
Close_kuaiba
Athena_close
Qualcomms
Other_mode
Other_settings

echo -en "\n"
Output "即将完成，更新内容请看群公告！"
Output "特别感谢帮我debug的群友！ "
Output "交流群：517788148"
Output "作者：@焕晨"
Output "安装完成。"
