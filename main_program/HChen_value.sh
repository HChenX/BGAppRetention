#Author by @焕晨HChen
zram_value() {
  { { [[ $num == $((a - d + e)) ]] && ber=$(echo "$zram" | cut -c1-2) && zram_in=$((ber + c + e)); }; } || { [[ $num == $((a - d)) ]] && ber=$(echo "$zram" | cut -c1) && zram_in=$((ber + b)); }
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
mem_value1() { echo "/memory.limit_in_bytes /memory.memsw.limit_in_bytes /memory.soft_limit_in_bytes"; }
mem_value2() { echo "/cgroup.clone_children /memory.oom_control"; }
qcom_value() { value=(false false 2147483647 2147483647 2147483647 false 1001 1001 false false 0 500 100 0 100 600 900 1000 false 0 false false false false 0 1001 100 0 false 100 false) && echo "${value[@]}"; }
prop_value() { value=(false false 0 false false 2147483647 false false 0 false false false false false false false false true 2147483647 false true true false false 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 false false false 100 0 true 600 900 0 1001 1001 1001 false 100 100 false 500 500 false 100 false false false false false 1001 0 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024,1025,1026,1027,1028,1029 1024:1001,1025:1001,1026:1001,1027:1001,1028:1001,1029:1001 false 0 false false false false false 0 false false 0 0 0 0 0 false false false 1001 1001 false false 100 100 0 600 900 1000 500 0 false false 100 false 0 1001 100 0 false false false false 100 false 0 0 0 0 0) && echo "${value[@]}"; }
