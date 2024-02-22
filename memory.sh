#Author by @焕晨HChen
HChen=${0%/*}
swapIni="$HChen/swap.ini"
compFile="/sys/class/block/zram0/comp_algorithm"
# 检查并导入文件
{
    [[ -f $swapIni ]] && { . "$swapIni" && echo "- [i]:配置文件读取成功"; } || {
        echo "- [!]:配置文件读取异常" && exit 1
    }
} || { echo "- [!]: 缺少$swapIni" && exit 3; }
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
# 自动计算
getResults() {
    digit_count=$(echo "$1" | awk '{print length}')
    echo $(lengthMod $1 $2 $3 $4)
}
# 计算模组
lengthMod() {
    { [[ $digit_count -gt $2 ]] && {
        { [[ $3 == "\*" ]] && {
            echo $(expr $(expr $(echo $1 | cut -c 1-2) + 1) \* $4)
            # echo $(($(($(echo $1 | cut -c 1-2) + 1)) * $4))
        }; } || {
            echo $(expr $(echo $1 | cut -c 1-2) $3 $4)
            # echo $(($(echo $1 | cut -c 1-2) $3 $4))
        }
    }; } || {
        { [[ $3 == "\*" ]] && {
            echo $(expr $(expr $(echo $1 | cut -c 1) + 1) \* $4)
        }; } || {
            echo $(expr $(echo $1 | cut -c 1) $3 $4)
        }
    }
}
# 设置Zram参数
setZram() {
    # 检查是否支持
    [[ ! -e /dev/block/zram0 ]] && {
        {
            [[ -e /sys/class/zram-control ]] && echo "- [i]:内核支持ZRAM"
        } || { echo "- [!]:内核不支持ZRAM" && return; }
    }
    # 设置大小
    zramAll=$(grep 'MemTotal' </proc/meminfo | tr -cd "0-9")
    zramSize=$(getResults $zramAll 7 + 4)
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
    comp_algorithm="$comp_algorithm"
    echo $comp_algorithm >$compFile
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
setVm() {
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
    setValue "$swappiness" $swapN
    waterM=$(getResults $zramAll 7 \\* 5)
    setValue "$waterM" /proc/sys/vm/watermark_scale_factor
    #设置cache参数
    {
        echo "- [i]:设置cache参数"
        setValue 2 /proc/sys/vm/dirty_background_ratio
        setValue 80 /proc/sys/vm/dirty_ratio
        setValue 2000 /proc/sys/vm/dirty_expire_centisecs
        setValue 250 /proc/sys/vm/dirty_writeback_centisecs
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
        setValue 5 /proc/sys/vm/stat_interval
        # 是否允许过量使用运存
        #  setValue 200 /proc/sys/vm/overcommit_ratio
        setValue 1 /proc/sys/vm/overcommit_memory
        # 触发oom后怎么抛异常
        setValue 0 /proc/sys/vm/panic_on_oom
        # 此参数决定了内核在后台应该压缩内存的力度。参数取 [0, 100] 范围内的值
        # 默认20，待测试
        setValue 35 /proc/sys/vm/compaction_proactiveness
        #  压缩内存节省空间（会导致kswap0异常）
        #  setValue 1 /proc/sys/vm/compact_memory
        #  watermark_boost_factor用于优化内存外碎片化
        #  setValue 100 /proc/sys/vm/watermark_boost_factor
        #  参数越小越倾向于进行内存规整，越大越不容易进行内存规整。
        #  setValue 400 /proc/sys/vm/extfrag_threshold
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
time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
echo "手机品牌:$(getprop ro.product.brand)" >"$HChen"/log.txt
{
    echo "手机型号:$(getprop ro.product.vendor.device)"
    echo "安卓版本:$(getprop ro.build.version.release)"
    echo "内核版本:$(uname -r)"
    test "$(getprop ro.miui.ui.version.name)" != "" &&
        echo "MIUI版本:MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental) "
    echo "系统开机时间:$time"
    version=$(dumpsys package com.hchen.appretention | grep versionName | cut -f2 -d '=')
    { [[ $version != "" ]] && {
        echo "AppRetention已经安装:$version"
    }; } || {
        echo "AppRetention未安装"
        echo "AppRetention下载地址:https://github.com/HChenX/AppRetentionHook"
    }
    echo "---------------------------------------------------------------------------"
    # 更改selinux规则
    magiskpolicy --live "allow system_server * * *"
    device_config set_sync_disabled_for_tests persistent
    settings put global settings_enable_monitor_phantom_procs false
    device_config put activity_manager max_cached_processes 2147483647
    device_config put activity_manager max_phantom_processes 2147483647
    resetprop sys.lmk.minfree_levels 1:1001,2:1001,3:1001,4:1001,5:1001,6:1001
    setZram
    setVm
    echo "---------------------------------------------------------------------------"
} >>"$HChen"/log.txt
