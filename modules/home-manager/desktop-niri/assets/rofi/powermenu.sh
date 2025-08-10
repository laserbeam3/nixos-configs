#!/usr/bin/env bash

# Current Theme
theme="$HOME/.config/rofi/rofi-powermenu.rasi"

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend=' Suspend'
logout='󰍃 Logout'
yes=' Yes'
no=' No'

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
    -p "`whoami`@`hostname`" \
    -mesg "Uptime: `uptime | sed -e 's/.*up //g' | sed -e 's/,.*//g'`" \
    -theme ${theme}
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme ${theme}
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
confirm_and_run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff
        elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
        elif [[ $1 == '--suspend' ]]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
            systemctl suspend
        elif [[ $1 == '--logout' ]]; then
            niri msg action quit --skip-confirmation
        fi
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        confirm_and_run_cmd --shutdown
        ;;
    $reboot)
        confirm_and_run_cmd --reboot
        ;;
    $lock)
        swaylock
        ;;
    $suspend)
        confirm_and_run_cmd --suspend
        ;;
    $logout)
        confirm_and_run_cmd --logout
        ;;
esac
