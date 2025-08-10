#!/usr/bin/env bash

if pgrep -x rofi; then
    pkill rofi
else
    # Rofi needs to launch apps made for X (instead of wayland) sometimes, and
    # those need DISPLAY=:0 set.
    DISPLAY=:0 rofi -show drun -config ~/.config/rofi/rofi-default.rasi
fi
