#!/usr/bin/env bash

if pgrep -x rofi; then
    pkill rofi
else
    rofi -show drun -config ~/.config/rofi/rofi-default.rasi
fi
