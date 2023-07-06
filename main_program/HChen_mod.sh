#Author by @焕晨HChen
sdk=$(getprop ro.system.build.version.sdk)
a=10 && b=5 && c=4 && d=3 && e=1 && f=1000000 && g=1024 && onmk="mkswap"
ksu_check=false && record=0 && power="chmod" && open="swapon"
cpu="11110000" && cpus="00001111" && sys="/sys/block/zram0"
proc="/proc/sys/vm" && dev="/dev/memcg" && fs="/sys/fs/cgroup"
camera_file="/system/system_ext/etc/camerabooster.json"
lowmemorykiller="/sys/module/lowmemorykiller/parameters" && vbin="/vendor/bin"
qcom_file="/vendor/etc/perf/perfconfigstore.xml" && bin="/system/bin"
[[ -f "/data/adb/ksud" ]] && ksu_check=true
zram=$(grep 'MemTotal' </proc/meminfo | tr -cd "0-9")
swap_conf="$HChen/swap/swap.ini"
cat_mod() { cat "$1"; }
chmod_mod() { eval $power "$1" "$2"; }
set_value_log() { { echo "- [i]:设置$2" && { now=$(cat_mod "$2") || true; } && { [[ $1 == "$now" ]] && echo "- [i]:目标设置为:$1,实际设置为:$now"; }; } || { echo "- [!]:目标设置为:$1,实际设置为:$now"; }; }
set_value() { { [[ -f $2 ]] && { { chmod_mod 666 "$2" &>/dev/null || true; } && { { echo "$1" >"$2" && { chmod_mod 664 "$2" &>/dev/null || true; } && set_value_log "$1" "$2"; } || { echo "- [!]:无法写入$2文件"; }; }; }; } || { echo "- [!]:不存在$2文件"; }; }
update_overlay() { { sed -i "s/\(Name=\"$1\"[[:blank:]]*Value=\"\)[^\"]*\(\"\)/\1$2\2/g" "$qcom_now_file" && { grep -q "Name=\"$1\"[[:blank:]]*Value=\"$2\"" "$qcom_now_file"; }; } && { echo "$1=$2" >>"$HChen"/Qualcomm; }; }
send_notifications() { { { [[ $(pm list package | grep -w 'com.google.android.ext.services') != "" ]] && cmd notification allow_assistant "com.google.android.ext.services/android.ext.services.notification.Assistant"; } || true; } && { su -lp 2000 -c "cmd notification post -S messaging --conversation '$2' --message '$2':'$1' Tag '$RANDOM'" &>/dev/null; }; }
volume_keys() {
  timeout=0
  while :; do
    sleep 0.5 && let timeout++
    [[ $timeout -gt 20 ]] && { send_notifications "$1" "保后台模块" && break; }
    volume="$(getevent -qlc 1 | awk '{ print $3 }')"
    case "$volume" in KEY_VOLUMEUP) send_notifications "$2" "保后台模块" && sleep 10 && reboot ;; KEY_VOLUMEDOWN) send_notifications "$3" "保后台模块" ;; *) continue ;; esac
    break
  done
}
camera_mod() { sed -i "s/\"$1\": true/\"$1\": $2/g" "$camera_now_file"; }
mask() { echo "obase=16;$((2#$1))" | xargs echo $(bc); }
for_mod() { for i in $1; do $2 $3 $4 $5 $i$6 $7; done; }
