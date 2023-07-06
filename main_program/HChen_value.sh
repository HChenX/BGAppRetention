#Author by @焕晨HChen
zram_value() {
  { [[ $zram -gt $((f * 15)) ]] && zram_in=$((a + b + c)); } || { [[ $zram -gt $((f * 11)) ]] && zram_in=$((a + b)); } || { [[ $zram -gt $((f * 7)) ]] && zram_in=$((a + e)); } || { [[ $zram -gt $((f * 5)) ]] && zram_in=$((a - e)); } || { [[ $zram -gt $((f * 3)) ]] && zram_in=$((a - d)); } || { zram_in=$b; }
  { [[ $zram -gt $((f * 15)) ]] && watermark=500; } || { [[ $zram -gt $((f * 11)) ]] && watermark=450; } || { [[ $zram -gt $((f * 7)) ]] && watermark=400; } || { [[ $zram -gt $((f * 5)) ]] && watermark=350; } || { [[ $zram -gt $((f * 3)) ]] && watermark=300; } || { watermark=250; }
}
close() {
  echo "- [i]:重置ZRAM所有设置"
  for_mod "/dev/block/zram*" "swapoff" "" "" "" "" "" &>/dev/null
}
opens() {
  echo "- [i]:初始化ZRAM" && eval $onmk /dev/block/zram0 &>/dev/null
  echo "- [i]:启动ZRAM" && eval $open /dev/block/zram0 &>/dev/null
}
other_vm() {
  for_mod "/sys/block/sd*" "set_value" "deadline" "" "" "/queue/scheduler" ""
  for_mod "/sys/block/sd*" "set_value" "256" "" "" "/queue/read_ahead_kb" ""
  for_mod "/sys/block/sd*" "set_value" "64" "" "" "/queue/nr_requests" ""
  for_mod "/sys/block/sd*" "set_value" "2" "" "" "/queue/rq_affinity" ""
}
other_bin() {
  for_mod "$(pgrep "$1")" "taskset" "-p" "$2" "" "" "" &>/dev/null
  for_mod "$(pgrep "$1")" "renice" "-n" "$3" "-p" "" "" &>/dev/null
}
vm_value() {
  echo "160" >$swappinessd
  { [[ $? -eq 1 ]] && swappiness=95; } || { swappiness=160; }
}
camera_value() { echo "false"; }
value_first() { value=(none 1 0 1 0 8) && echo "${value[@]}"; }
value_second() { value=(10 80 2000 300 150 1 0 1 0 20 1 0 0 0) && echo "${value[@]}"; }
value_third() { value=("1024,1025,1026,1027,1028,1029" 0 0 0) && echo "${value[@]}"; }
qcom_value() { value=(false 2147483647 2147483647 false 1001 1001 false 100 false 500 100 10 600 900 1000 0 false false false 2147483647 100 false 0 1001 100 0 false 0 false) && echo "${value[@]}"; }
prop_value() { value=(false 2147483647 false false false false 0 false false 2147483647 2147483647 false false false false false false false false false 100 10 600 900 0 1001 1001 1001 false 100 100 false 500 false false false false false 0 100 false 1001 0 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 false false 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 false false false false 500 2147483647 2147483647 false 0 0 0 0 0 100 false false false false 2147483647 false 1001 1001 false 100 false 500 100 10 600 900 1000 0 false false 100 false 0 1001 100 0 false false) && echo "${value[@]}"; }
