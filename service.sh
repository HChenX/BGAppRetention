#Author by @焕晨HChen
HChen=${0%/*}
Wait_until_login() {
    while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 1; done
    while [ ! -d "/sdcard/Android" ]; do sleep 1; done
}
Wait_until_login
{ [[ -f /system/bin/sh ]] && {
    /system/bin/sh $HChen/memory.sh
}; } || {
    { [[ -f /vendor/bin/sh ]] && {
        /vendor/bin/sh $HChen/memory.sh
    }; } || {
        echo "不存在sh文件，无法正常执行" >"$HChen"/log.txt
    }
}
