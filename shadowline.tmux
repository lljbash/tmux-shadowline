#!/usr/bin/env bash

set -euo pipefail

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## avoid loading shadowline multiple times
lock="$cwd/shadowline.lock"
# atomic test-and-set
: >>$lock
{
  flock 3
  set +e
  tmux show-environment TMUX_SHADOWLINE_LOADED 1>/dev/null 2>&1
  shadowline_loaded=$(($? == 0))
  set -e
  tmux set-environment TMUX_SHADOWLINE_LOADED 1
} 3<$lock
if [[ $shadowline_loaded -eq 1 ]]; then
  exit
fi

declare -A color_mapping=(
  ["status_fg"]="#e3e1e4"
  ["status_bg"]="#262626"
  ["message_fg"]="#e3e1e4"
  ["message_bg"]="#2f2d2c"
  ["pane_border"]="#262626"
  ["pane_active_border"]="#585858"
  ["window_current_id_fg"]="#eae8ea"
  ["window_current_id_bg"]="#44413f"
  ["window_current_fg"]="#e3e1e4"
  ["window_current_bg"]="#3d3b3a"
  ["window_id_fg"]="#afa8a3"
  ["window_id_bg"]="#343230"
  ["window_fg"]="#918d8a"
  ["window_bg"]="#2e2c2a"
  ["window_current_zoomed"]="#6ca0dc"
  ["window_current_activity"]="#dca96c"
  ["window_current_silence"]="#dc6c6c"
  ["window_zoomed"]="#4f708f"
  ["window_last"]="#4f7d74"
  ["window_activity"]="#8a6b45"
  ["window_silence"]="#8a4d4d"
  ["plugin_session"]="#f1d786"
  ["plugin_session_prefix"]="#3b82f6"
  ["plugin_hostname"]="#e8a08f"
  ["plugin_monitor"]="#79b874"
  ["plugin_time"]="#f7e26b"
  ["plugin_date"]="#e3b38c"
  ["plugin_weather"]="#a2cfe5"
)
colorf() {
  if [[ -z $1 ]]; then
    >&2 echo "Usage: colorf <color>"
    return 1
  fi
  set -eu
  local color=${color_mapping["$1"]}
  echo "fg=$color"
}
colorb() {
  if [[ -z $1 ]]; then
    >&2 echo "Usage: colorb <color>"
    return 1
  fi
  set -eu
  local color=${color_mapping["$1"]}
  echo "bg=$color"
}
color() {
  if [[ -z $1 || -z $2 ]]; then
    >&2 echo "Usage: color <fg> <bg>"
    return 1
  fi
  set -eu
  local fg=${color_mapping["$1"]}
  local bg=${color_mapping["$2"]}
  echo "fg=$fg,bg=$bg"
}
color2() {
  if [[ -z $1 ]]; then
    >&2 echo "Usage: color2 <color>"
    return 1
  fi
  set -eu
  color "${1}_fg" "${1}_bg"
}

# basic settings
tmux set -g status-interval 1
tmux set -g status-justify left
tmux set -g status-left-length 50
tmux set -g status-right-length 150

tmux set -g status-style "$(color2 status)"
tmux set -g message-style "$(color2 message)"
tmux set -g pane-active-border-style "$(colorf pane_active_border)"
tmux set -g pane-border-style "$(colorf pane_border)"
tmux setw -g window-status-activity-style ""
tmux setw -g window-status-bell-style ""
tmux setw -g window-status-current-style ""

# window list
tmux setw -g window-status-current-format "\
#[$(color window_current_id_bg status_bg)]\
\
#[$(color2 window_current_id)]\
#I\
#[$(color window_current_id_bg window_current_bg)]\
\
#[$(color2 window_current)]\
 #W \
#[$(colorf window_current_zoomed)]\
#{?window_zoomed_flag,󰍉 ,}\
#[$(colorf window_current_activity)]\
#{?window_activity_flag,󰂜 ,}\
#[$(colorf window_current_silence)]\
#{?window_silence_flag,󰟢 ,}\
#[$(color window_current_bg status_bg)]\
"
tmux setw -g window-status-format "\
#[$(color window_id_bg status_bg)]\
\
#[$(color2 window_id)]\
#I\
#[$(color window_id_bg window_bg)]\
\
#[$(color2 window)]\
 #W \
#[$(colorf window_zoomed)]\
#{?window_zoomed_flag,󰍉 ,}\
#[$(colorf window_last)]\
#{?window_last_flag,󰋚 ,}\
#[$(colorf window_activity)]\
#{?window_activity_flag,󰂜 ,}\
#[$(colorf window_silence)]\
#{?window_silence_flag,󰟢 ,}\
#[$(color window_bg status_bg)]\
"

get_plugin() {
  set -eu
  if [[ $# -ne 1 ]]; then
    >&2 echo "Usage: get_plugin_text <name>"
    return 1
  fi
  local plugin_name="$1"
  local plugin_script
  local plugin_style
  plugin_script="#($cwd/plugins/${plugin_name}.sh)"
  plugin_style="#[$(colorf "plugin_${plugin_name}")]"
  if [ "$plugin_name" == "session" ]; then
    plugin_style="$plugin_style#{?client_prefix,#[$(colorb plugin_session_prefix)],}"
  fi
  echo "$plugin_style $plugin_script #[$(color2 status)]"
}
add_plugin() {
  set -eu
  if [[ $# -ne 2 ]]; then
    >&2 echo "Usage: add_plugin left|right <name>"
    return 1
  fi
  local plugin_place="$1"
  local plugin_name="$2"
  local plugin_text
  plugin_text=$(get_plugin "$plugin_name")
  if [[ $plugin_place == "left" ]]; then
    tmux set -ga status-left "$plugin_text"
  elif [[ $plugin_place == "right" ]]; then
    tmux set -ga status-right "$plugin_text"
  else
    >&2 echo "Invalid plugin place: $plugin_place"
    return 1
  fi
}

# plugins
tmux set -g status-left ""
add_plugin left session
add_plugin left hostname
tmux set -ga status-left " "
tmux set -g status-right " "
add_plugin right monitor
add_plugin right time
add_plugin right date
# add_plugin right weather
