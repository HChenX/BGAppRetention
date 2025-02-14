#Author by @焕晨HChen
swaps="$MODPATH/swap.ini"
old="zram_huanchen" && old2="HChen_Zram"
FindPath() {
    {
        { [[ $KSU != "true" ]] && {
            # { [[ $KSU != "true" ]] && {
            #   echo "/data/adb/modules/$1"
            # }; } || {
            #   echo "/data/adb/ksu/modules/$1"
            # }
            echo $(find /data/adb/modules/ -maxdepth 1 -name $1)
        }; } || {
            echo $(find /data/adb/ksu/modules/ -maxdepth 1 -name $1)
        }
    }
}

OutPut() {
    echo "$@"
    sleep "$(echo "scale=3; $RANDOM/32768*0.2" | bc -l)"
}

GetValue() {
    grep -v '^#' <"$swaps" | grep "^$1=" | cut -f2 -d '='
}

comp_algorithms=$(GetValue comp_algorithm)
reserve=$(GetValue reserve)

#监听音量键
VolumeKey() {
    local choose
    local branch
    while :; do
        choose="$(getevent -qlc 1 | awk '{ print $3 }')"
        case "$choose" in
        KEY_VOLUMEUP) branch="0" ;;
        KEY_VOLUMEDOWN) branch="1" ;;
        *) continue ;;
        esac
        echo "$branch"
        break
    done
}

Delete() {
    OutPut "- [i]:欢迎使用本模块 (///ω///)"
    OutPut "- [i]:正在安装本模块！< (ˉ^ˉ)> "
    OutPut "--------------------------------------------"
    OutPut "--------------------------------------------"
    OutPut "- [i]:正在删除冲突文件！"
    rm_rf() { { [[ -d $1 ]] && touch "$1"/remove && touch "$1"/disable && OutPut "- [i]:已卸载:$1"; }; }
    findfile=$(FindPath $old)
    findfile2=$(FindPath $old2)
    [[ $findfile != "" ]] && { touch $findfile/disable && touch $findfile/remove && OutPut "- [i]:已卸载:$findfile"; }
    [[ $findfile2 != "" ]] && { touch $findfile2/disable && touch $findfile2/remove && OutPut "- [i]:已卸载:$findfile2"; }
    ksu="/data/adb/ksu/modules"
    magisk="/data/adb/modules"
    check="
    $ksu/scene_swap_controller
    $ksu/swap_controller
    $magisk/scene_swap_controller
    $magisk/swap_controller"
    for i in $check; do rm_rf "$i"; done
    OutPut "- [i]:处理冲突文件完成！"
}

AppRetention() {
    OutPut "- [i]:AppRetention模块，版本4.3.0"
    OutPut "- [i]:模块作用：通过Hook系统kill逻辑实现后台保活"
    OutPut "- [i]:模块作者：焕晨HChen"
    version=$(dumpsys package com.hchen.appretention | grep versionName | cut -f2 -d '=')
    { [[ $version == "4.3.0" ]] && {
        OutPut "- [i]:AppRetention模块已经安装且最新"
        rm -rf /data/local/tmp/AppRetention.apk
        rm -rf "$MODPATH"/AppRetention.apk
    }; } || {
        OutPut "- [i]:音量上安装，音量下取消"
        { [[ $(VolumeKey) == 0 ]] && {
            unzip -o "$ZIPFILE" 'AppRetention.apk' -d /data/local/tmp/ &>/dev/null
            [[ ! -f /data/local/tmp/AppRetention.apk ]] && OutPut "- [!]:解压附加模块失败！无法进行安装！" && exit 1
            pm install -r /data/local/tmp/AppRetention.apk &>/dev/null
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
            OutPut "- [i]:AppRetention模块安装成功"
        }; } || {
            OutPut "- [!]:AppRetention模块取消安装"
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
        }
    }
}

Other() {
    OutPut "- [i]:正在检测可用压缩模式！"
    { [[ $reserve == "true" ]] && { comp_algorithm=$comp_algorithms; }; } || {
        check_result=$(cat /sys/block/zram0/comp_algorithm)
        zram=$(echo "$check_result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
# Author by @焕晨HChen
swaps="$MODPATH/swap.ini"
old="zram_huanchen" && old2="HChen_Zram"

FindPath() {
    if [[ $KSU != "true" ]]; then
        find /data/adb/modules/ -maxdepth 1 -name "$1"
    else
        find /data/adb/ksu/modules/ -maxdepth 1 -name "$1"
    fi
}

OutPut() {
    echo "$@"
    sleep "$(echo "scale=3; $RANDOM/32768*0.2" | bc -l)"
}

GetValue() {
    grep -v '^#' <"$swaps" | grep "^$1=" | cut -f2 -d '='
}

comp_algorithms=$(GetValue comp_algorithm)
reserve=$(GetValue reserve)

# 监听音量键
VolumeKey() {
    local choose
    local branch
    while :; do
        choose="$(getevent -qlc 1 | awk '{ print $3 }')"
        case "$choose" in
        KEY_VOLUMEUP) branch="0" ;;
        KEY_VOLUMEDOWN) branch="1" ;;
        *) continue ;;
        esac
        echo "$branch"
        break
    done
}

# 删除冲突文件
Delete() {
    OutPut "- [i]: 欢迎使用本模块 (///ω///)"
    OutPut "- [i]: 正在安装本模块！< (ˉ^ˉ)> "
    OutPut "--------------------------------------------"
    OutPut "--------------------------------------------"
    OutPut "- [i]: 正在删除冲突文件！"
    rm_rf() {
        if [[ -d $1 ]]; then
            touch "$1"/remove && touch "$1"/disable
            OutPut "- [i]: 已卸载: $1"
        fi
    }
    findfile=$(FindPath "$old")
    findfile2=$(FindPath "$old2")
    [[ -n $findfile ]] && { touch "$findfile"/disable && touch "$findfile"/remove && OutPut "- [i]: 已卸载: $findfile"; }
    [[ -n $findfile2 ]] && { touch "$findfile2"/disable && touch "$findfile2"/remove && OutPut "- [i]: 已卸载: $findfile2"; }
    ksu="/data/adb/ksu/modules"
    magisk="/data/adb/modules"
    check="
    $ksu/scene_swap_controller
    $ksu/swap_controller
    $magisk/scene_swap_controller
    $magisk/swap_controller"
    for i in $check; do rm_rf "$i"; done
    OutPut "- [i]: 处理冲突文件完成！"
}

AppRetention() {
    OutPut "- [i]: AppRetention 模块，版本 5.2.1"
    OutPut "- [i]: 模块作用：通过 Hook 系统 kill 逻辑实现后台保活"
    OutPut "- [i]: 模块作者：焕晨 HChen"
    version=$(dumpsys package com.hchen.appretention | grep versionName | cut -f2 -d '=')
    if [[ $version == "5.2.1" ]]; then
        OutPut "- [i]: AppRetention 模块已经安装且最新"
        rm -rf /data/local/tmp/AppRetention.apk
        rm -rf "$MODPATH"/AppRetention.apk
    else
        OutPut "- [i]: 音量上安装，音量下取消"
        if [[ $(VolumeKey) == 0 ]]; then
            unzip -o "$ZIPFILE" 'AppRetention.apk' -d /data/local/tmp/ &>/dev/null
            if [[ ! -f /data/local/tmp/AppRetention.apk ]]; then
                OutPut "- [!]: 解压附加模块失败！无法进行安装！"
                exit 1
            fi
            pm install -r /data/local/tmp/AppRetention.apk &>/dev/null
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
            OutPut "- [i]: AppRetention 模块安装成功"
        else
            OutPut "- [!]: AppRetention 模块取消安装"
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
        fi
    fi
}

# 设置压缩模式
Other() {
    OutPut "- [i]: 正在检测可用压缩模式！"
    if [[ $reserve == "true" ]]; then
        comp_algorithm=$comp_algorithms
    else
        check_result=$(cat /sys/block/zram0/comp_algorithm)
        zram=$(echo "$check_result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
        # 优先选择 zstd，如果不可用则选择其他模式
        if echo "$zram" | grep -q zstd; then
            comp_algorithm=zstd
        elif echo "$zram" | grep -q lz4; then
            comp_algorithm=lz4
        elif echo "$zram" | grep -q lzo-rle; then
            comp_algorithm=lzo-rle
        else
            comp_algorithm=lzo
        fi
    fi
    if [[ -z $comp_algorithm ]]; then
        OutPut "- [!]: 获取 zram 压缩模式失败！"
        exit 4
    else
        sed -i '3a '"comp_algorithm=$comp_algorithm"'' "$swaps"
        OutPut "- [i]: 设置 zram 压缩模式为：$comp_algorithm"
    fi

    OutPut "- [i]: 真正检查手机品牌！"
    OutPut "- [i]: 你的手机品牌是：$(getprop ro.product.brand)"
    if [[ $(getprop ro.product.brand) == "samsung" ]]; then
        echo -n "
persist.sys.minfree_12g=1,1,1,1,1,1
persist.sys.minfree_6g=1,1,1,1,1,1
persist.sys.minfree_8g=1,1,1,1,1,1
persist.sys.minfree_def=1,1,1,1,1,1
ro.slmk.2nd.dha_cached_max=2147483647
ro.slmk.dha_cached_max=2147483647
ro.slmk.dha_empty_max=2147483647
ro.slmk.2nd.dha_lmk_scale=-1
ro.slmk.dha_lmk_scale=-1
ro.slmk.dha_lmk_scale=-1
ro.slmk.2nd.swap_free_low_percentage=0
ro.slmk.swap_free_low_percentage=0
ro.slmk.cam_dha_ver=0
ro.slmk.chimera_quota_enable=false
ro.slmk.dha_2ndprop_thMB=1
ro.slmk.enable_upgrade_criad=false
ro.slmk.genai_reclaim_mode=false
ro.sys.kernelmemory.gmr.enabled=false
ro.sys.kernelmemory.umr.enabled=false
ro.sys.kernelmemory.umr.mem_free_low_threshold_kb=1
ro.sys.kernelmemory.umr.proactive_reclaim_battery_threshold=0
ro.sys.kernelmemory.umr.reclaimer.damon.enabled=false
ro.sys.kernelmemory.umr.reclaimer.onTrim.enabled=false" >>"$MODPATH"/system.prop
        OutPut "- [i]: 已为三星添加专属 PROP 修改！"
    fi
}

Settings() {
    set_perm_recursive "$MODPATH" 0 0 0777 0777
}

{
    Delete
    AppRetention
    Other
    Settings
}

OutPut "- [i]: 群：517788148"
OutPut "- [i]: 作者：@焕晨 HChen"
OutPut "- [i]: 安装完成！All Down!"
