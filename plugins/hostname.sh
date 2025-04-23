#!/usr/bin/env bash

plugin_hostname_max_length=20

hostname=$(hostname)
if [ ${#hostname} -gt "$plugin_hostname_max_length" ]; then
  hostname="${hostname:0:$plugin_hostname_max_length}…"
fi
echo " $hostname"
