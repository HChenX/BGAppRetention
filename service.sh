# Author: 焕晨HChen
MODDIR=${0%/*}

waitSystemBootCompleted() {
    while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
        sleep 1
    done
    while [[ ! -d "/sdcard/Android" ]]; do
        sleep 1
    done
}

main() {
    waitSystemBootCompleted

    echo -n "" >"$MODDIR"/log.txt # 重置日志
    if [[ -f /system/bin/sh ]]; then
        /system/bin/sh "$MODDIR/memory.sh"
    elif [[ -f /vendor/bin/sh ]]; then
        /vendor/bin/sh "$MODDIR/memory.sh"
    else
        echo "- [!]: 不存在 sh 文件，无法正常执行" >"$MODDIR"/log.txt
        exit 1
    fi
}

main
