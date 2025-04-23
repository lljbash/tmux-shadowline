#!/usr/bin/env bash

set -euo pipefail

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/common.sh"

location="Tsinghua"
update_interval=300
curl_timeout=10

fetch_weather_info() {
  set -euo pipefail
  weather_information=$(curl -sL --max-time "$curl_timeout" "wttr.in/$location?format=%t%40%w%40%c")

  temperature=$(cut -d '@' -f 1 <<<"$weather_information")
  wind=$(cut -d '@' -f 2 <<<"$weather_information")
  emoji="$(cut -d '@' -f 3 <<<"$weather_information" | xargs | grep -oP '^.') "

  echo "$emoji ${temperature} $wind"
}

last_update=$(get_tmux_option "@shadowline-weather-last-update" 0)
now=$(date +%s)
if ((now - last_update > update_interval)); then
  set_tmux_option "@shadowline-weather-last-update" "$now"
  weather_info=$(fetch_weather_info)
  set_tmux_option "@shadowline-weather-info" "$weather_info"
else
  set -o pipefail
  weather_info=$(get_tmux_option "@shadowline-weather-info" "")
fi
echo "$weather_info"
