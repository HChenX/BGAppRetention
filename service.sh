# Author by @焕晨HChen
HChen=${0%/*}

Wait_until_login() {
    while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
        sleep 1
    done
    while [[ ! -d "/sdcard/Android" ]]; do
        sleep 1
    done
}

Main() {
    Wait_until_login

    if [[ -f /system/bin/sh ]]; then
        /system/bin/sh "$HChen/memory.sh"
    elif [[ -f /vendor/bin/sh ]]; then
        /vendor/bin/sh "$HChen/memory.sh"
    else
        echo "不存在 sh 文件，无法正常执行" >"$HChen"/log.txt
        exit 1
    fi
}

Main
