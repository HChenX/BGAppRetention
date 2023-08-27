#Author by @焕晨HChen
ZramValue() {
  { { [[ $num == $((a - d + e)) ]] && ber=$(echo "$zram" | cut -c1-2) && zram_in=$((ber + c + e)); }; } || { [[ $num == $((a - d)) ]] && ber=$(echo "$zram" | cut -c1) && zram_in=$((ber + b)); }
  { [[ $zram -gt $((f * 15)) ]] && watermark=500; } || { [[ $zram -gt $((f * 11)) ]] && watermark=450; } || { [[ $zram -gt $((f * 7)) ]] && watermark=400; } || { [[ $zram -gt $((f * 5)) ]] && watermark=350; } || { [[ $zram -gt $((f * 3)) ]] && watermark=300; } || { watermark=250; }
}
CloseZram() {
  echo "- [i]:重置ZRAM所有设置"
  ForMod "/dev/block/zram*" "swapoff" "" "" "" "" "" &>/dev/null
}
Opens() {
  echo "- [i]:初始化ZRAM" && eval $onmk /dev/block/zram0 &>/dev/null
  echo "- [i]:启动ZRAM" && eval $open /dev/block/zram0 &>/dev/null
}
OtherVm() {
  ForMod "/sys/block/sd*" "SetValue" "deadline" "" "" "/queue/scheduler" ""
  ForMod "/sys/block/sd*" "SetValue" "256" "" "" "/queue/read_ahead_kb" ""
  ForMod "/sys/block/sd*" "SetValue" "64" "" "" "/queue/nr_requests" ""
  ForMod "/sys/block/sd*" "SetValue" "2" "" "" "/queue/rq_affinity" ""
}
OtherBin() {
  ForMod "$(pgrep "$1")" "taskset" "-p" "$2" "" "" "" &>/dev/null
  ForMod "$(pgrep "$1")" "renice" "-n" "$3" "-p" "" "" &>/dev/null
}
VmValue() {
  echo "160" >$swappinessd
  { [[ $? -eq 1 ]] && swappiness=95; } || { swappiness=160; }
}
ValueZram() { value=(none 1 0 1 0 8) && echo "${value[@]}"; }
ValueVm() { value=(10 80 2000 300 150 1 0 1 0 20 1 0 0 0) && echo "${value[@]}"; }
ValueLow() { value=("1,2,3,4,5,6" 0 0 0) && echo "${value[@]}"; }
MemValue1() { echo "/memory.limit_in_bytes /memory.memsw.limit_in_bytes /memory.soft_limit_in_bytes"; }
MemValue2() { echo "/cgroup.clone_children /memory.oom_control"; }
ValueQcom() {
  value=(false
    false
    2147483647
    2147483647
    false
    1001
    1001
    false
    false
    0
    100
    10
    100
    600
    900
    1000
    false
    0
    false
    false
    false
    false
    0
    1001
    100
    0
    false
    100
    false)
  echo "${value[@]}"
}
ValueProp() {
  value=(false
    false
    false
    false
    2147483647
    2147483647
    false
    false
    false
    false
    false
    false
    false
    false
    false
    false
    false
    true
    2147483647
    false
    false
    false
    false
    false
    false
    false
    2147483647
    2147483647
    2147483647
    2147483647
    false
    false
    100
    10
    true
    600
    900
    0
    1001
    1001
    1001
    false
    100
    100
    false
    false
    100
    false
    false
    false
    false
    false
    false
    false
    1001
    "1:1001,2:1001,3:1001,4:1001,5:1001,6:1001"
    "1:1001,2:1001,3:1001,4:1001,5:1001,6:1001"
    "1:1001,2:1001,3:1001,4:1001,5:1001,6:1001"
    "1,2,3,4,5,6"
    "1,2,3,4,5,6"
    "1,2,3,4,5,6"
    "1,2,3,4,5,6"
    false
    false
    false
    false
    0
    0
    0
    0
    0
    0
    false
    false
    false
    0
    "4,4,4,4"
    false
    false
    false
  )
  echo "${value[@]}"
}
#false
#true
#true
#false
#false
#500
#500
#0
#500
