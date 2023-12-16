#Author by @焕晨HChen
swaps="$MODPATH/swap.ini"
old="zram_huanchen" && old2="HChen_Zram"
findOld() {
    {
        { [[ $KSU != "true" ]] && {
            #            { [[ $KSU != "true" ]] && {
            #                echo "/data/adb/modules/$1"
            #            }; } || {
            #                echo "/data/adb/ksu/modules/$1"
            #            }
            echo $(find /data/adb/modules/ -maxdepth 1 -name $1)
        }; } || {
            echo $(find /data/adb/ksu/modules/ -maxdepth 1 -name $1)
        }
    }
}

Output() {
    echo "$@"
    sleep "$(echo "scale=3; $RANDOM/32768*0.2" | bc -l)"
}
Get_props() {
    grep -v '^#' <"$swaps" | grep "^$1=" | cut -f2 -d '='
}
comp_algorithms=$(Get_props comp_algorithm)
reserve=$(Get_props reserve)
#监听音量键
Volume_key_monitoring() {
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
Delete_cheat() {
    Output "- [i]:欢迎使用本模块 (///ω///)"
    Output "- [i]:正在安装本模块！< (ˉ^ˉ)> "
    Output "--------------------------------------------"
    Output "--------------------------------------------"
    Output "- [i]:正在删除冲突文件！"
    rm_rf() { { [[ -d $1 ]] && touch "$1"/remove && touch "$1"/disable && Output "- [i]:已卸载:$1"; }; }
    findfile=$(findOld $old)
    findfile2=$(findOld $old2)
    [[ $findfile != "" ]] && { touch $findfile/disable && touch $findfile/remove && Output "- [i]:已卸载:$findfile"; }
    [[ $findfile2 != "" ]] && { touch $findfile2/disable && touch $findfile2/remove && Output "- [i]:已卸载:$findfile2"; }
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
AppRetention() {
    Output "- [i]:AppRetention模块，版本4.1"
    Output "- [i]:模块作用：通过Hook系统kill逻辑实现后台保活"
    Output "- [i]:模块作者：焕晨HChen"
    version=$(dumpsys package Com.HChen.Hook | grep versionName | cut -f2 -d '=')
    { [[ "$(echo "$version >= 4.1" | bc -l)" -eq 1 ]] && {
        Output "- [i]:AppRetention模块已经安装且最新"
        rm -rf /data/local/tmp/AppRetention.apk
        rm -rf "$MODPATH"/AppRetention.apk
    }; } || {
        Output "- [i]:音量上安装，音量下取消"
        { [[ $(Volume_key_monitoring) == 0 ]] && {
            unzip -o "$ZIPFILE" 'AppRetention.apk' -d /data/local/tmp/ &>/dev/null
            [[ ! -f /data/local/tmp/AppRetention.apk ]] && Output "- [!]:解压附加模块失败！无法进行安装！" && exit 1
            pm install -r /data/local/tmp/AppRetention.apk &>/dev/null
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
            Output "- [i]:AppRetention模块安装成功"
        }; } || {
            Output "- [!]:AppRetention模块取消安装"
            rm -rf /data/local/tmp/AppRetention.apk
            rm -rf "$MODPATH"/AppRetention.apk
        }
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
        sed -i '3a '"comp_algorithm=$comp_algorithm"'' "$swaps" && Output "- [i]:设置zram压缩模式为：$comp_algorithm"
    }
}

Other_settings() { set_perm_recursive "$MODPATH" 0 0 0777 0777; }
{
    Delete_cheat
    AppRetention
    Other_mode
    Other_settings
}
Output "- [i]:群：517788148"
Output "- [i]:作者：@焕晨HChen"
Output "- [i]:安装完成！All Down!"
