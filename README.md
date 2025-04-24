# tmux-shadowline

A clean and quiet tmux status line theme, designed for personal use.

## Overview

**tmux-shadowline** is a custom status bar theme for [tmux](https://github.com/tmux/tmux), featuring muted grays, soft contrast, and subtle color highlights. It’s meant to stay out of your way while still providing enough visual cues for active windows, status updates, and plugin info.

I built this for myself — tuned carefully to my habits and screen — but if you're interested in using it, feel free. I might expose some options if there's demand. Otherwise, it stays opinionated and minimal.

## Screenshot

> Make sure you have a Nerd Font installed for proper icons.

![image](https://github.com/user-attachments/assets/428c6c05-ebfd-4409-91c2-fdeae90f9ffd)

## Installation

You can add this as a plugin via [TPM](https://github.com/tmux-plugins/tpm).

```tmux
# run the script manually if you run TPM in background
# otherwise the status bar will flash on startup
run 'bash -c "[[ -x ~/.tmux/plugins/tmux-shadowline/shadowline.tmux ]] && ~/.tmux/plugins/tmux-shadowline/shadowline.tmux"'

set -g @plugin 'yourname/tmux-shadowline'
# and other plugins...

run -b '~/.tmux/plugins/tpm/tpm'
```

Or clone and run directly:

```bash
git clone https://github.com/yourname/tmux-shadowline ~/.tmux-shadowline
echo 'run ~/.tmux-shadowline/shadowline.tmux' >> ~/.tmux.conf
```

## Customization
Not really customizable at the moment — unless you edit the file.
I might add toggles or variables for colors/layouts if others actually use it.
