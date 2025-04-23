#!/usr/bin/env bash

set -e

location="Tsinghua"
update_interval=300
curl_timeout=10

fetch_weather_info() {
  set -e
  weather_information=$(curl -sL --max-time "$curl_timeout" "wttr.in/$location?format=%t%40%w%40%c")

  temperature=$(cut -d '@' -f 1 <<<"$weather_information")
  wind=$(cut -d '@' -f 2 <<<"$weather_information")
  emoji="$(cut -d '@' -f 3 <<<"$weather_information" | xargs | grep -oP '^.') "

  echo "$emoji ${temperature} $wind"
}

if ! last_update=$(tmux show-environment TMUX_WEATHER_LAST_UPDATE 2>/dev/null); then
  last_update=0
fi
now=$(date +%s)
if ((now - last_update > update_interval)); then
  tmux set-environment TMUX_WEATHER_LAST_UPDATE "$now"
  weather_info=$(fetch_weather_info)
  tmux set-environment TMUX_WEATHER_INFO "$weather_info"
else
  set -o pipefail
  weather_info=$(tmux show-environment TMUX_WEATHER_INFO | cut -d '=' -f 2)
fi
echo "$weather_info"
