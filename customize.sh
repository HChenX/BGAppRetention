# Author: 焕晨HChen
mSwapConfig="$MODPATH/swap.ini"
mShouldRemoveModuleNames="
zram_huanchen
HChen_Zram
MiniHChen
swap_controller
scene_swap_controller
"

mCompAlgorithm=$(getConfigValue algorithm)
mPersist=$(getConfigValue persist)

main() {
    print "- [i]: 欢迎使用本模块 (///ω///)"
    print "- [i]: 正在安装本模块！< (ˉ^ˉ)> "
    print "--------------------------------------------"
    print "--------------------------------------------"

    removeModuleIfNeed
    installAppRetentionIfNeed
    initConfig
    initPermissions

    printLog "- [i]:群：517788148"
    printLog "- [i]:作者：@焕晨HChen"
    printLog "- [i]:安装完成！All Down!"
}

# 删除冲突文件
removeModuleIfNeed() {
    printLog "- [i]: 正在删除冲突文件！"

    for name in $mShouldRemoveModuleNames; do
        modulePath=$(findPath "$name")
        if [[ -n $modulePath && -d $modulePath ]]; then
            touch "$modulePath"/remove
            touch "$modulePath"/disable

            printLog "- [i]: 已卸载: #modulePath"
        fi
    done
}

# AppRetention 模块安装
installAppRetentionIfNeed() {
    printLog "- [i]: AppRetention 模块，版本 v.5.2.1"
    printLog "- [i]: 模块作用: 通过 Hook 系统 kill 逻辑实现后台保活"
    printLog "- [i]: 模块作者: 焕晨HChen"
    version=$(dumpsys package com.hchen.appretention | grep versionName | cut -f2 -d '=')
    if [[ $version == "5.2.1" ]]; then
        printLog "- [i]: AppRetention 模块已经安装且最新!"
        rm -rf "$MODPATH"/AppRetention.apk
    else
        printLog "- [i]: 按音量上确认安装，按音量下取消安装!"
        if [[ $(volumeKeyListener) == 0 ]]; then
            unzip -o "$ZIPFILE" 'AppRetention.apk' -d /data/local/tmp/ &>/dev/null
            if [[ ! -f /data/local/tmp/AppRetention.apk ]]; then
                printLog "- [!]: 解压附加模块失败！无法进行安装！"
                printLog "- [!]: 将会跳过安装过程，您可手动解压模块安装！"
                return
            fi
            pm install -r /data/local/tmp/AppRetention.apk &>/dev/null
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
            printLog "- [i]: AppRetention 模块安装成功!"
        else
            printLog "- [!]: AppRetention 模块已取消安装!"
            rm -rf "$MODPATH"/AppRetention.apk
        fi
    fi
}

# 设置压缩模式
initConfig() {
    printLog "- [i]: 正在检测可用压缩模式！"
    if [[ $mPersist == "true" ]]; then
        algorithm=$mCompAlgorithm
    else
        result=$(cat /sys/block/zram0/comp_algorithm)
        zramModes=$(echo "$result" | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g')
        # 优先选择 lz4，如果不可用则选择其他模式
        if echo "$zramModes" | grep -q lz4; then
            algorithm=lz4
        elif echo "$zramModes" | grep -q zstd; then
            algorithm=zstd
        elif echo "$zramModes" | grep -q lzo-rle; then
            algorithm=lzo-rle
        else
            algorithm=lzo
        fi
    fi
    if [[ -z $algorithm ]]; then
        printLog "- [!]: 获取zram压缩模式失败！"
        exit 1
    else
        sed -i '2a '"algorithm=$algorithm"'' "$mSwapConfig"
        printLog "- [i]: 设置 zram 压缩算法为: $algorithm"
    fi

    # Changed: 放弃修改！！
    #    printLog "- [i]: 正在检查手机品牌！"
    #    printLog "- [i]: 你的手机品牌是: $(getprop ro.product.brand)"
    #    if [[ $(getprop ro.product.brand) == "samsung" ]]; then
    #        echo -n "
    #persist.sys.minfree_12g=1,1,1,1,1,1
    #persist.sys.minfree_6g=1,1,1,1,1,1
    #persist.sys.minfree_8g=1,1,1,1,1,1
    #persist.sys.minfree_def=1,1,1,1,1,1
    #ro.slmk.2nd.dha_cached_max=2147483647
    #ro.slmk.dha_cached_max=2147483647
    #ro.slmk.dha_empty_max=2147483647
    #ro.slmk.2nd.dha_lmk_scale=-1
    #ro.slmk.dha_lmk_scale=-1
    #ro.slmk.dha_lmk_scale=-1
    #ro.slmk.2nd.swap_free_low_percentage=0
    #ro.slmk.swap_free_low_percentage=0
    #ro.slmk.cam_dha_ver=0
    #ro.slmk.chimera_quota_enable=false
    #ro.slmk.dha_2ndprop_thMB=1
    #ro.slmk.enable_upgrade_criad=false
    #ro.slmk.genai_reclaim_mode=false
    #ro.sys.kernelmemory.gmr.enabled=false
    #ro.sys.kernelmemory.umr.enabled=false
    #ro.sys.kernelmemory.umr.mem_free_low_threshold_kb=1
    #ro.sys.kernelmemory.umr.proactive_reclaim_battery_threshold=0
    #ro.sys.kernelmemory.umr.reclaimer.damon.enabled=false
    #ro.sys.kernelmemory.umr.reclaimer.onTrim.enabled=false" >>"$MODPATH"/system.prop
    #        printLog "- [i]:已为三星添加专属PROP修改！"
    #    fi
}

initPermissions() {
    set_perm_recursive "$MODPATH" 0 0 0777 0777
}

printLog() {
    echo "$@"
    sleep "$(echo "scale=3; $RANDOM/32768*0.2" | bc -l)"
}

findPath() {
    if [[ -d /data/adb/modules/ ]]; then
        find /data/adb/modules/ -maxdepth 1 -name "$1"
    elif [[ -d /data/adb/ksu/modules/ ]]; then
        find /data/adb/ksu/modules/ -maxdepth 1 -name "$1"
    fi
}

getConfigValue() {
    grep -v '^#' <"$mSwapConfig" | grep "^$1=" | cut -f2 -d '='
}

volumeKeyListener() {
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

main