# Author: 焕晨HChen
PATH=${0%/*}

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

    echo "" >"$PATH"/log.txt # 重置日志
    if [[ -f /system/bin/sh ]]; then
        /system/bin/sh "$PATH/memory.sh"
    elif [[ -f /vendor/bin/sh ]]; then
        /vendor/bin/sh "$PATH/memory.sh"
    else
        echo "- [!]: 不存在 sh 文件，无法正常执行" >"$PATH"/log.txt
        exit 1
    fi
}

main