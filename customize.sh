#全局变量
sdk=$(getprop ro.system.build.version.sdk)
confs="/data/adb/modules/zram_huanchen"
confs2="/data/adb/ksu/modules/zram_huanchen"
swaps="$MODPATH/swap/swap.ini"

#延迟输出
Output() {
  echo "$@"
  #输出随机时间
  sleep "$(echo "scale=3; $RANDOM/32768*0.15" | bc -l)"
}

#获取路径
{
  [[ -d $confs ]] && iconf="$confs"
} || {
  [[ -d $confs2 ]] && iconf="$confs2"
}

#获取具体文件
{
  [[ -f "$iconf"/swap/swap.ini ]] && swap_ini="$iconf/swap/swap.ini"
} || {
  swap_ini="$iconf/swap/swap.conf"
}

#读取已安装配置
Get_props() {
  grep -v '^#' <"$swap_ini" | grep "^$1=" | cut -f2 -d '='
}
comp_algorithms=$(Get_props comp_algorithm)
close_kuaiba=$(Get_props close_kuaiba)
reserve=$(Get_props reserve)

#删除已经安装的模块
Delete_cheat() {
  Output "- [i]:欢迎使用本模块(///ω///)"
  Output "- [i]:正在安装改版模块！< (ˉ^ˉ)> "
  Output "--------------------------------------------"
  Output "--------------------------------------------"
  Output "- [i]:正在删除冲突文件！"
  rm_rf() {
    {
      [[ -d $1 ]] && rm -rf "$1" && Output "- [i]:已删除:$1"
    } || {
      [[ -f $1 ]] && rm -rf "$1" && Output "- [i]:已删除:$1"
    }
  }
  #此代码用于让scene显示已激活
  #先删再创建
  rm_rf /data/swap_config.conf
  echo "请忽略此文件，也请不要删除。" >/data/swap_config.conf
  #删除附加模块2防止冲突
  rm_rf /data/adb/modules/scene_swap_controller/
  rm_rf /data/adb/ksu/modules/scene_swap_controller/
  rm_rf /data/swapfile*
  rm_rf /data/swap_recreate
  #删除小阳光模块防止冲突
  rm_rf /data/adb/ksu/modules/swap_controller/
  rm_rf /data/adb/modules/swap_controller/
  rm_rf /data/adb/swap_controller/
  Output "- [i]:处理冲突文件完成！"
}

#安装附加模块
Dont_kill() {
  {
    [[ "$sdk" -ge 31 ]] && {
      Output "- [i]:(安卓12/13专属)Don.t.kill模块已安装。"
      Output "- [i]:模块作用：进一步增强保后台能力。"
      Output "- [i]:使用方法：lsp里面激活重启即可。"
      Output "- [i]:模块作者：海浪逃向岛屿"
      unzip -o "$ZIPFILE" 'Don.t.Kill.apk' -d /data/local/tmp/ &>/dev/null
      [[ ! -f /data/local/tmp/Don.t.Kill.apk ]] && Output "- [!]:解压附加模块失败！无法进行安装！" && exit 1
      pm install -r /data/local/tmp/Don.t.Kill.apk &>/dev/null
      rm -rf /data/local/tmp/Don.t.Kill.apk
      rm -rf "$MODPATH"/Don.t.Kill.apk
      echo "
#用于标记是否安装附加模块
dont_kill=on" >>"$swaps"
    }
  } || {
    Output "- [!]:非安卓12/13跳过附加模块安装。"
    rm -rf /data/local/tmp/Don.t.Kill.apk
    rm -rf "$MODPATH"/Don.t.Kill.apk
  }
}

#下面决定要不要关闭MTK的快霸
Close_kuaiba() {
  packages=$(pm list packages -s | sed 's/package://g' | grep 'com.mediatek.duraspeed')
  {
    [[ $close_kuaiba == "on" ]] && {
      kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
      kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
      [[ ! -f $kuaibaapp ]] && Output "- [!]:不存在快霸文件！请联系开发者！" && exit 2
      mkdir -p "$MODPATH""$kuaibaapp2"
      touch "$MODPATH""$kuaibaapp"
      Output "- [i]:成功处理MTK快霸。"
      echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
    }
  } || {
    {
      [[ $(getprop Build.BRAND) == "MTK" ]] && [[ $packages == "com.mediatek.duraspeed" ]] && {
        Output "- [i]:(联发科专属)下面决定是否关闭联发科的快霸。"
        Output "- [i]:作用：防止这玩意杀后台，似乎是残留的东西。"
        #第一层保险
        pm disable com.mediatek.duraspeed &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedAppReceiver &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.RestrictHistoryActivity &>/dev/null
        pm disable com.mediatek.duraspeed/com.mediatek.duraspeed.DuraSpeedMainActivity &>/dev/null
        pm clear com.mediatek.duraspeed &>/dev/null
        #第二层保险
        kuaibaapp="/system/system_ext/priv-app/DuraSpeed/DuraSpeed.apk"
        kuaibaapp2="${kuaibaapp//DuraSpeed.apk/}"
        [[ ! -f $kuaibaapp ]] && Output "- [!]:不存在快霸文件！请联系开发者！" && exit 2
        mkdir -p "$MODPATH""$kuaibaapp2"
        touch "$MODPATH""$kuaibaapp"
        Output "- [i]:成功处理MTK快霸。"
        echo "
#用于标记是否关闭快霸
close_kuaiba=on" >>"$swaps"
      }
    } || {
      Output "- [!]:不是联发科或不存在快霸软件跳过此步。"
    }
  }
}

#决定要不要关闭oppo系手机雅典娜
Athena_close() {
  ui1=$(getprop ro.product.brand.ui | tr '[:upper:]' '[:lower:]')
  ui2=$(getprop ro.product.vendor.manufacturer | tr '[:upper:]' '[:lower:]')
  {
    {
      [[ "$ui1" == "realmeui" ]] || [[ "$ui1" == "coloros" ]] || [[ "$ui2" == "oneplus" ]] ||
        [[ "$ui2" == "realme" ]] || [[ "$ui2" == "oppo" ]] || [[ "$ui2" == "coloros" ]]
    } && {
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
        #超时自动退出
        timeout=$((timeout + 1))
        [[ $timeout -gt 2 ]] && {
          Output "- [!]:超时未检测到音量键，请重试！"
          echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
          break
        }
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
          [[ $Athena_such_12 == "" ]] && [[ $Athena_such_13 == "" ]] && Output "- [!]:获取雅典娜路径失败！请联系作者！" && exit 3
          {
            [[ $Athena_such_12 != "" ]] && {
              Athena_12="${Athena_such_12//Athena.apk/}"
              mkdir -p "$MODPATH""$Athena_12"
              touch "$MODPATH""$Athena_such_12"
            }
          } || {
            [[ $Athena_such_13 != "" ]] && {
              Athena_13="${Athena_such_13//Athena.apk/}"
              mkdir -p "$MODPATH""$Athena_13"
              touch "$MODPATH""$Athena_such_13"
            }
          }
          Output "- [i]:成功关闭雅典娜。"
          echo "
#用于标记是否关闭雅典娜
close_athena=on
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
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
    }
  } || {
    Output "- [!]:不是oppo系跳过此步。"
    echo "
#这些标记仅用于为开发者提供信息，自行修改没有效果
#---------------------------------------------------------------------------" >>"$swaps"
  }
}

#检测支持的压缩模式
#自动配置watermark_scale_factor
Other_mode() {
  Output "- [i]:正在检测可用压缩模式！"
  {
    [[ $reserve == "true" ]] && {
      comp_algorithm=$comp_algorithms
    }
  } || {
    check_result=$(cat /sys/block/zram0/comp_algorithm)
    zram=$(echo "$check_result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
    check_result1=$(echo "$zram" | grep lz4)
    check_result2=$(echo "$zram" | grep zstd)
    check_result3=$(echo "$zram" | grep lzo-rle)
    {
      [[ "$check_result1" != "" ]] && {
        comp_algorithm=lz4
      }
    } || {
      [[ "$check_result2" != "" ]] && {
        comp_algorithm=zstd
      }
    } || {
      [[ "$check_result3" != "" ]] && {
        comp_algorithm=lzo-rle
      }
    } || {
      comp_algorithm=lzo
    }
  }
  {
    [[ $comp_algorithm == "" ]] && Output "- [!]:获取zram压缩模式失败！" && exit 4
  } || {
    sed -i '12a '"comp_algorithm=$comp_algorithm"'' "$swaps"
    Output "- [i]:设置zram压缩模式为：$comp_algorithm"
  }

  [[ -f $iconf/Prop_on ]] && {
    [[ $(cat "$iconf"/Prop_on) != 0 ]] && {
      cp -f "$iconf"/system.prop "$MODPATH"
      # 填写0触发prop更新
      echo -n "0" >"$MODPATH"/Prop_on
      Output "- [i]:成功获取历史文件。"
    }
  }
  #删除已有文件
  #  rm -rf "$iconf"/system.prop
}

#默认权限
Other_settings() {
  set_perm_recursive "$MODPATH" 0 0 0777 0777
}

#定位（勿删）
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
Output "- [i]:作者：@焕晨"
Output "- [i]:安装完成！"
