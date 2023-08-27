#Author by @焕晨HChen
swaps="$MODPATH/swap/swap.ini"
sdk=$(getprop ro.system.build.version.sdk)
old="zram_huanchen" && new="HChen_Zram"
[[ $KSU == "true" ]] && touch "$MODPATH"/Ksu_ver && echo -n "$KSU_VER" >"$MODPATH"/Ksu_ver
{
  [[ $(find /data/adb/modules/ -maxdepth 1 -name $old) != "" ]] && {
    confs="/data/adb/modules/$old" && confs2="/data/adb/ksu/modules/$old" && rmv=1
  }
} || {
  confs="/data/adb/modules/$new" && confs2="/data/adb/ksu/modules/$new"
}
Output() {
  echo "$@"
  sleep "$(echo "scale=3; $RANDOM/32768*0.2" | bc -l)"
}
{
  [[ -d $confs ]] && iconf="$confs"
} || {
  [[ -d $confs2 ]] && iconf="$confs2"
}
{
  [[ -f "$iconf"/swap/swap.ini ]] && swap_ini="$iconf/swap/swap.ini"
} || {
  swap_ini="$iconf/swap/swap.conf"
}
Get_props() {
  grep -v '^#' <"$swap_ini" | grep "^$1=" | cut -f2 -d '='
}
comp_algorithms=$(Get_props comp_algorithm)
close_kuaiba=$(Get_props close_kuaiba)
reserve=$(Get_props reserve)
Delete_cheat() {
  Output "- [i]:欢迎使用本模块(///ω///)"
  Output "- [i]:正在安装改版模块！< (ˉ^ˉ)> "
  Output "--------------------------------------------"
  Output "--------------------------------------------"
  Output "- [i]:正在删除冲突文件！"
  rm_rf() { { [[ -d $1 ]] && touch "$1"/remove && touch "$1"/disable && Output "- [i]:已卸载:$1"; }; }
  [[ $rmv == 1 ]] && { touch $iconf/disable && touch $iconf/remove; }
  ksu="/data/adb/ksu/modules"
  magisk="/data/adb/modules"
  check="
  $ksu/scene_swap_controller
  $ksu/swap_controller
  $magisk/scene_swap_controller
  $magisk/swap_controller"
  for i in $check; do rm_rf "$i"; done
  Output "- [i]:处理冲突文件完成！"
}
Dont_kill() {
  { [[ "$sdk" -ge 31 ]] && {
    Output "- [i]:(安卓12/13专属)AppRetention模块已安装。"
    Output "- [i]:模块作用：通过Hook系统kill逻辑实现后台保活。"
    Output "- [i]:使用方法：lsp里面激活,勾选作用域Android重启即可。"
    Output "- [i]:模块作者：焕晨HChen"
    unzip -o "$ZIPFILE" 'AppRetention.apk' -d /data/local/tmp/ &>/dev/null
    [[ ! -f /data/local/tmp/AppRetention.apk ]] && Output "- [!]:解压附加模块失败！无法进行安装！" && exit 1
    pm install -r /data/local/tmp/AppRetention.apk &>/dev/null
    rm -rf /data/local/tmp/AppRetention.apk
    rm -rf "$MODPATH"/AppRetention.apk
    echo "
#用于标记是否安装附加模块
app_retention=on" >>"$swaps"
  }; } || {
    Output "- [!]:非安卓12/13跳过附加模块安装。"
    rm -rf /data/local/tmp/AppRetention.apk
    rm -rf "$MODPATH"/AppRetention.apk
  }
}
Close_kuaiba() {
  packages=$(pm list packages -s | sed 's/package://g' | grep 'com.mediatek.duraspeed')
  { [[ $close_kuaiba == "on" ]] && {
    kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
    kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
    [[ ! -f $kuaibaapp ]] && Output "- [!]:不存在快霸文件！请联系开发者！"
    mkdir -p "$MODPATH""$kuaibaapp2"
    touch "$MODPATH""$kuaibaapp"
    Output "- [i]:成功处理MTK快霸。"
    echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
  }; } || { {
    [[ $packages == "com.mediatek.duraspeed" ]] && {
      Output "- [i]:(联发科专属)下面决定是否关闭联发科的快霸。"
      Output "- [i]:作用：防止这玩意杀后台，似乎是残留的东西。"
      pm disable com.mediatek.duraspeed &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedAppReceiver &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.RestrictHistoryActivity &>/dev/null
      pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedMainActivity &>/dev/null
      pm clear com.mediatek.duraspeed &>/dev/null
      kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
      kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
      { ! { [[ ! -f $kuaibaapp ]] && Output "- [!]:不存在快霸文件！请联系开发者！"; }; } && {
        mkdir -p "$MODPATH""$kuaibaapp2"
        touch "$MODPATH""$kuaibaapp"
        Output "- [i]:成功处理MTK快霸。"
        echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
      }
    }
  } || { Output "- [!]:不存在快霸软件跳过此步。"; }; }
}
Athena_close() {
  ui1=$(getprop ro.product.brand.ui | tr '[:upper:]' '[:lower:]')
  ui2=$(getprop ro.product.vendor.manufacturer | tr '[:upper:]' '[:lower:]')
  { { [[ "$ui1" == "realmeui" ]] || [[ "$ui1" == "coloros" ]] || [[ "$ui2" == "oneplus" ]] || [[ "$ui2" == "realme" ]] || [[ "$ui2" == "oppo" ]] || [[ "$ui2" == "coloros" ]]; } && {
    Output "- [i]:(oppo系专属)正在关闭雅典娜。"
    Output "- [i]:作用：防止这玩意杀后台。"
    Output "- [i]:如果音量键无法使用；"
    Output "- [i]:请随意滑动屏幕即可自动跳过。"
    Output "- [i]:无事请勿随意滑动屏幕，可能误触！"
    echo -en "\n"
    Output "- [i]:按音量上➕键确认关闭雅典娜。"
    Output " "
    Output "- [i]:按音量下➖键取消关闭雅典娜。"
    echo -en "\n"
    timeout=0
    while :; do
      sleep 0.5
      let timeout++
      [[ $timeout -gt 2 ]] && {
        Output "- [!]:超时未检测到音量键，请重试！"
        echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#用于标记是否关闭雅典娜
close_athena=off
#---------------------------------------------------------------------------" >>"$swaps"
        break
      }
      volume="$(getevent -qlc 1 | awk '{ print $3 }')"
      case "$volume" in
      KEY_VOLUMEUP)
        pm disable com.oplus.athena &>/dev/null
        pm disable com.coloros.athena &>/dev/null
        pm clear com.oplus.athena &>/dev/null
        pm clear com.coloros.athena &>/dev/null
        Athena_such_12="$(find /system/product/ -name Athena.apk 2>/dev/null)"
        Athena_such_13="$(find /system/system_ext/ -name Athena.apk 2>/dev/null)"
        { ! {
          [[ $Athena_such_12 == "" ]] && [[ $Athena_such_13 == "" ]] && Output "- [!]:获取雅典娜路径失败！请联系作者！" && {
            echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
          }
        }; } && {
          { [[ $Athena_such_12 != "" ]] && {
            Athena_12="${Athena_such_12//Athena.apk/}"
            mkdir -p "$MODPATH""$Athena_12"
            touch "$MODPATH""$Athena_such_12"
          }; } || { [[ $Athena_such_13 != "" ]] && {
            Athena_13="${Athena_such_13//Athena.apk/}"
            mkdir -p "$MODPATH""$Athena_13"
            touch "$MODPATH""$Athena_such_13"
          }; }
          Output "- [i]:成功关闭雅典娜。"
          echo "
#用于标记是否关闭雅典娜
close_athena=on
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
        }
        ;;
      KEY_VOLUMEDOWN)
        Output "- [!]:取消关闭雅典娜。"
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
  }; } || {
    Output "- [!]:不是oppo系跳过此步。"
    echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
  }
}
Other_mode() {
  Output "- [i]:正在检测可用压缩模式！"
  { [[ $reserve == "true" ]] && { comp_algorithm=$comp_algorithms; }; } || {
    check_result=$(cat /sys/block/zram0/comp_algorithm)
    zram=$(echo "$check_result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
    check_result1=$(echo "$zram" | grep lz4)
    check_result2=$(echo "$zram" | grep zstd)
    check_result3=$(echo "$zram" | grep lzo-rle)
    {
      [[ "$check_result1" != "" ]] && comp_algorithm=lz4
    } || {
      [[ "$check_result2" != "" ]] && comp_algorithm=zstd
    } || {
      [[ "$check_result3" != "" ]] && comp_algorithm=lzo-rle
    } || { comp_algorithm=lzo; }
  }
  {
    [[ $comp_algorithm == "" ]] && Output "- [!]:获取zram压缩模式失败！" && exit 4
  } || {
    sed -i '12a '"comp_algorithm=$comp_algorithm"'' "$swaps" && Output "- [i]:设置zram压缩模式为：$comp_algorithm"
  }
  [[ -f $iconf/Prop_on ]] && {
    [[ $(cat "$iconf"/Prop_on) != 0 ]] && {
      cp -f "$iconf"/system.prop "$MODPATH" && echo -n "0" >"$MODPATH"/Prop_on && Output "- [i]:成功获取历史文件。"
    }
  }
  [[ -f $iconf/module.prop ]] && version=$(grep "versionCode" <$iconf/module.prop | cut -f2 -d '=')
  [[ $version -gt 2023070900 ]] && [[ -f /data/property/persistent_properties ]] && {
    cp -f /data/property/persistent_properties "$MODPATH"/
    echo -n "" >/data/property/persistent_properties
  }
}

Other_settings() { set_perm_recursive "$MODPATH" 0 0 0777 0777; }
{
  Delete_cheat
  Dont_kill
  Close_kuaiba
  Athena_close
  Other_mode
  Other_settings
}
Output "- [i]:即将完成，更新内容请看群公告！"
Output "- [i]:特别感谢帮我debug的群友！ "
Output "- [i]:交流群：517788148"
Output "- [i]:作者：@焕晨HChen"
Output "- [i]:安装完成！"
