# Author by @焕晨HChen
HChen=${0%/*}
swapIni="$HChen/swap.ini"
compFile="/sys/class/block/zram0/comp_algorithm"

# 检查并导入文件
{
    if [[ -f $swapIni ]]; then
        。 "$swapIni" && echo "- [i]: 配置文件读取成功"
    else
        echo "- [!]: 配置文件读取异常" && exit 1
    fi
} || { echo "- [!]: 缺少 $swapIni" && exit 3; }

# 输出日志
setValueLog() {
    echo "- [i]: 设置 $2"
    当前=$(cat "$2" | head -n 1) || true
    if [[ $1 == "$now" ]]; then
        echo "- [i]: 目标设置为: $1, 实际设置为: $now"
    else
        echo "- [!]: 目标设置为: $1, 实际设置为: $now"
    fi
}

# 设置参数
setValue() {
    if [[ -f $2 ]]; then
        chmod 666 "$2" &>/dev/null || true
        if echo "$1" >"$2"; then
            chmod 664 "$2" &>/dev/null || true
            setValueLog "$1" "$2"
        else
            echo "- [!]: 无法写入 $2 文件"
        fi
    else
        echo "- [!]: 不存在 $2 文件"
    fi
}

# 自动计算
getResults() {
    digit_count=$(echo "$1" | awk '{print length}')
    echo $(lengthMod $1 $2 $3 $4)
}

# 计算模组
lengthMod() {
    if [[ $digit_count -gt $2 ]]; then
        if [[ $3 == "\*" ]]; then
            echo $(expr $(expr $(echo $1 | cut -c 1-2) + 1) \* $4)
        else
            echo $(expr $(echo $1 | cut -c 1-2) $3 $4)
        fi
    else
        if [[ $3 == "\*" ]]; then
            echo $(expr $(expr $(echo $1 | cut -c 1) + 1) \* $4)
        else
            echo $(expr $(echo $1 | cut -c 1) $3 $4)
        fi
    fi
}

# 设置Zram参数
setZram() {
    # 检查是否支持
    if [[ ! -e /dev/block/zram0 ]]; then
        if [[ -e /sys/class/zram-control ]]; then
            echo "- [i]: 内核支持 ZRAM"
        else
            echo "- [!]: 内核不支持 ZRAM" && return
        fi
    fi

    # 设置大小
    zramAll=$(grep 'MemTotal' </proc/meminfo | tr -cd "0-9")
    zramSize=$(getResults $zramAll 7 + 4)
    zramSize=$(awk 'BEGIN{print '$zramSize'*(1024^3)}')

    # 设置压缩线程
    setValue 8 /sys/block/zram0/max_comp_streams

    echo "- [i]: 设置压缩模式"
    comp_algorithm="$comp_algorithm"
    echo $comp_algorithm >$compFile
    cp=$(cat $compFile | sed 's/\[//g' | sed 's/]//g' | sed 's/ /\n/g' | grep -w "$comp_algorithm")
    if [[ $comp_algorithm == "$cp" ]]; then
        echo "- [i]: 目标设置为: $comp_algorithm, 实际设置为: $cp"
    else
        echo "- [!]: 目标设置为: $comp_algorithm, 实际设置为: $cp"
    fi

    echo "- [i]: 设置 ZRAM"
    setValue "$zramSize" /sys/block/zram0/disksize

    echo "- [i]: 初始化 ZRAM"
    mkswap /dev/block/zram0 &>/dev/null

    echo "- [i]: 启动 ZRAM"
    swapon /dev/block/zram0 &>/dev/null
}

setVm() {
    swapN="/proc/sys/vm/swappiness"
    echo "160" >$swapN
    if [[ $? -eq 1 ]]; then
        swappiness=95
    else
        swappiness=160
    fi
    echo "- [i]: 设置 swappiness"
    setValue "$swappiness" $swapN

    waterM=$(getResults $zramAll 7 \\* 5)
    setValue "$waterM" /proc/sys/vm/watermark_scale_factor

    # 设置 cache 参数
    {
        echo "- [i]: 设置 cache 参数"
        setValue 2 /proc/sys/vm/dirty_background_ratio
        setValue 80 /proc/sys/vm/dirty_ratio
        setValue 2000 /proc/sys/vm/dirty_expire_centisecs
        setValue 250 /proc/sys/vm/dirty_writeback_centisecs
        setValue 150 /proc/sys/vm/vfs_cache_pressure

        # 设置其它 vm 参数
        echo "- [i]: 设置其它 vm 参数"
        setValue 1 /proc/sys/vm/oom_kill_allocating_task
        setValue 0 /proc/sys/vm/oom_dump_tasks
        setValue 1 /proc/sys/vm/compact_unevictable_allowed
        setValue 0 /proc/sys/vm/block_dump
        setValue 5 /proc/sys/vm/stat_interval
        setValue 1 /proc/sys/vm/overcommit_memory
        setValue 0 /proc/sys/vm/panic_on_oom
        setValue 35 /proc/sys/vm/compaction_proactiveness

        # 每次换入的内存页
        if [[ $comp_algorithm == "zstd" ]]; then
            setValue 0 /proc/sys/vm/page-cluster
        else
            setValue 1 /proc/sys/vm/page-cluster
        fi
    }
}

time=$(date "+%Y年%m月%d日_%H时%M分%S秒")
echo "手机品牌: $(getprop ro.product.brand)" >"$HChen"/log.txt
{
    echo "手机型号: $(getprop ro.product.vendor.device)"
    echo "安卓版本: $(getprop ro.build.version.release)"
    echo "内核版本: $(uname -r)"
    if [[ -n $(getprop ro.miui.ui.version.name) ]]; then
        echo "MIUI版本: MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental)"
    fi
    echo "系统开机时间: $time"
    version=$(dumpsys package Com.HChen.Hook | grep versionName | cut -f2 -d '=')
    if [[ -n $version ]]; then
        echo "AppRetention 已经安装: $version"
    else
        echo "AppRetention 未安装"
        echo "AppRetention 下载地址: https://github.com/HChenX/AppRetentionHook"
    fi
    echo "---------------------------------------------------------------------------"
    resetprop sys.lmk.minfree_levels 1:1001,2:1001,3:1001,4:1001,5:1001,6:1001
    setZram
    setVm
    echo "---------------------------------------------------------------------------"
} >>"$HChen"/log.txt
