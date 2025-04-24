get_tmux_option() {
  set -u
  local option_name="$1"
  local default_value="$2"
  local option_value
  if option_value=$(tmux show-option -gv "$option_name"); then
    echo -n "$option_value"
  else
    echo -n "$default_value"
  fi
  set +eu
}

set_tmux_option() {
  set -eu
  local option_name="$1"
  local option_value="$2"
  tmux set-option -g "$option_name" "$option_value"
  set +eu
}

get_tmux_var() {
  set -u
  local option_name="$1"
  local default_value="$2"
  local option_value
  if option_value=$(tmux show-environment -gh "$option_name"); then
    echo -n "${option_value#*=}"
  else
    echo -n "$default_value"
  fi
  set +eu
}

set_tmux_var() {
  set -eu
  local option_name="$1"
  local option_value="$2"
  tmux set-environment -gh "$option_name" "$option_value"
  set +eu
}
