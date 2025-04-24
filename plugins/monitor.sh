#!/usr/bin/env bash

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/common.sh"

last_update_ms=$(get_tmux_var "@shadowline-monitor-last-update-ms" "")
cpu1=$(get_tmux_var "@shadowline-monitor-cpu1" "")
net1=$(get_tmux_var "@shadowline-monitor-net1" "")
current_ms=$(date +%s%3N)
cpu2=$(grep 'cpu ' /proc/stat)
net2=$(ip -s link show eth0)
set_tmux_var "@shadowline-monitor-last-update-ms" "$current_ms"
set_tmux_var "@shadowline-monitor-cpu1" "$cpu2"
set_tmux_var "@shadowline-monitor-net1" "$net2"
if [[ -z $last_update_ms ]]; then
  exit 1
fi
interval_ms=$((current_ms - last_update_ms))

cpu_percentage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.1f%%", ($2+$4-u1) * 100 / (t-t1) "%"; }' <(printf "%s\n%s\n" "$cpu1" "$cpu2"))

ram_percentage=$(LC_ALL=C free -m | awk '/^Mem/ {printf "%.0f%%", $3/$2*100}')

vram_percentage=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F',' '{u+=$1;t+=$2} END {printf("%.0f%%",u/t*100)}')

human_readable() {
  awk -v val="$1" 'BEGIN {
    val = val / 1024
    unit = "KiB"
    if (val > 1000) {
      val = val / 1024
      unit = "MiB"
    }
    if (val < 10)        printf("%1.1f", val)
    else                 printf("%3.0f", val)
    printf("%s\n", unit)
  }'
}
rx1=$(awk '/RX: / { if($1 == "RX:") {getline; print $1} }' <<<"$net1")
tx1=$(awk '/TX: / { if($1 == "TX:") {getline; print $1} }' <<<"$net1")
rx2=$(awk '/RX: / { if($1 == "RX:") {getline; print $1} }' <<<"$net2")
tx2=$(awk '/TX: / { if($1 == "TX:") {getline; print $1} }' <<<"$net2")
rx_traffic=$(awk '{print ($2 - $1) / $3 * 1000}' <<<"$rx1 $rx2 $interval_ms")
tx_traffic=$(awk '{print ($2 - $1) / $3 * 1000}' <<<"$tx1 $tx2 $interval_ms")
net_traffic=$(printf "󰇚 %s 󰕒 %s" "$(human_readable "$rx_traffic")" "$(human_readable "$tx_traffic")")

printf " %5s   %3s" "$cpu_percentage" "$ram_percentage"
if [[ -n $vram_percentage ]]; then
  printf "   %3s" "$vram_percentage"
fi
if [[ -n $net1 && -n $net2 ]]; then
  printf "  %s" "$net_traffic"
fi
