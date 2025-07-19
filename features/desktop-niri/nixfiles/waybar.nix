# System task bar and applets.
#
# I'm building my own taskbar using mainly waybar and rofi-wayland (applets).
# Goals (WIP - not even close with most of them):
#  - Must work as a sidebar (having any system tray top/bottom of the screen
#    on an ultrawide is very werid)
#  - Must be readable.
#  - Must never resize.
#  - Must be opaque and work with any wallpaper.
#  - Must include all relevant widgets a casual expects on a Windows taskbar.
#  - On-hover applets must behave VERY well with mouse events and stay visible
#    for as long as they are needed
# TODO: Add laptop modules (wifi, bluetooth, vpn, display switching...)

{ inputs, outputs, lib, config, pkgs, ... }:

{
  home.packages = [
    pkgs.waybar
    pkgs.rofi-wayland
    pkgs.wttrbar       # Weather widget
    pkgs.pulseaudio    # We need this for `pactl`, even though we enable audio via pipewire
    pkgs.pavucontrol   # The volume control applet
  ];

  programs.waybar = {
    enable = true;
    style = ../assets/waybar_style.css;
  };

  # Moved the actual layout here to keep indentation low and readable.
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "left";
    width = 48;

    ### Layout
    # Indented design:
    # Top: Launcher & Power menu (WIP)
    # Middle: A combined workspace/apps widget listing groups of windows
    #   separated by workspace, in order. Icons from unfocused workspaces
    #   should be dimmed. (WIP)
    # Bot: System tray, applets and clock

    modules-left = [
      "custom/launcher"
    ];

    modules-center = [
      "niri/window"  # TODO: Build a fantastical window/workspace tray
    ];

    modules-right = [
      "tray"
      "privacy#screen"
      "privacy#mic"
      "group/gnetwork"
      "group/gperfstats"
      "group/gsound"
      "niri/language"
      "custom/weather"
      # "idle_inhibitor"
      "clock"
    ];

    ### The modules

    "group/gperfstats" = {
      "orientation" = "inherit";
      "modules" = [
        "group/gcpu"
        "group/gmemory"
      ];
    };

    "custom/launcher" = {
      "justify" = "center";
      "format" = "󱄅";
      "on-click" = "albert toggle";
      "tooltip" = true;
      "tooltip-format" = "Start";
    };

    "niri/window" = {
      "rotate" = 90;
      "max-length" = 40;
    };


    "group/gcpu" = {
      "orientation" = "inherit";
      "modules" = [
        "cpu"
        "custom/cpu-icon"
      ];
    };
    "custom/cpu-icon" = {
      "format" = "cpu";
    };
    "cpu" = {
      "format-icons" = [
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
      ];
      "format" = "<span line_height='0.7ex'>{icon}</span>";
      "justify" = "center";
      "on-click" = "ghostty -e btop";
    };

    "group/gmemory" = {
      "orientation" = "inherit";
      "modules" = [
        "memory"
        "custom/memory-icon"
      ];
    };
    "custom/memory-icon" = {
      "format" = "mem";
    };
    "memory" = {
      "format-icons" = [
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
      ];
      "format" = "<span line_height='0.7ex'>{icon}</span>";
      "justify" = "center";
      "on-click" = "ghostty -e btop";
    };

    # TODO. Figure out how to read CPU temp in a reasonable way on multiple hardware.
    # "custom/cputemp" = {
    #   "format" = "{}";
    #   "exec" = "~/.config/waybar/bin/cputemp";
    #   "interval" = 10;
    #   "return-type" = "json";
    # };

    "privacy#screen" = {
      "justify" = "center";
      "icon-size" = 24;
      "transition-duration" = 100;
      "modules" = [
        {
          "type" = "screenshare";
          "tooltip" = true;
          "tooltip-icon-size" = 24;
        }
      ];
    };

    "privacy#mic" = {
      "justify" = "center";
      "icon-size" = 24;
      "transition-duration" = 100;
      "modules" = [
        {
          "type" = "audio-in";
          "tooltip" = true;
          "tooltip-icon-size" = 24;
        }
      ];
    };

    "group/gsound" = {
      "orientation" = "inherit";
      "modules" = [
        "pulseaudio#volume"
        "pulseaudio"
      ];
    };

    "tray" = {
      "icon-size" = 24;
      "spacing" = 4;
    };

    "pulseaudio" = {
      "format" = "{icon}";
      "format-bluetooth" = "{icon}";
      "tooltip-format" = "{volume}% {icon} | {desc}";
      "format-muted" = "󰖁";
      "format-icons" = {
        "headphones" = "󰋌";
        "handsfree" = "󰋌";
        "headset" = "󰋌";
        "phone" = "";
        "portable" = "";
        "car" = " ";
        "default" = "󰕾";
      };
    };

    "pulseaudio#volume" = {
      "format-icons" = [
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
      ];
      "format" = "<span line_height='0.7ex'>{icon}</span>";
      "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "on-click-middle" = "pavucontrol";
      "on-scroll-up" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "on-scroll-down" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "smooth-scrolling-threshold" = 1;
    };

    "network#icon" = {
      "format" = "{icon}";
      "format-icons" = {
        "wifi" = [
          "󰤨"
        ];
        "ethernet" = [
          "󰈀"
        ];
        "disconnected" = [
          "󰖪"
        ];
      };
      "format-wifi" = "󰤨";
      "format-ethernet" = "󰈀";
      "format-disconnected" = "󰖪";
      "format-linked" = "󰈁";
      "tooltip" = false;
      "on-click" = "pgrep -x rofi &>/dev/null && notify-send rofi || networkmanager_dmenu";
    };

    "network#speed" = {
      "format" = " {bandwidthDownBits} ";
      "rotate" = 90;
      "interval" = 5;
      "tooltip-format" = "{ipaddr}";
      "tooltip-format-wifi" = "{essid} ({signalStrength}%)   \n{ipaddr} | {frequency} MHz{icon} ";
      "tooltip-format-ethernet" = "{ifname} 󰈀 \n{ipaddr} | {frequency} MHz{icon}";
      "tooltip-format-disconnected" = "Not Connected to any type of Network";
      "tooltip" = true;
      "on-click" = "pgrep -x rofi &>/dev/null && notify-send rofi || networkmanager_dmenu";
    };

    "bluetooth" = {
      "format-on" = "";
      "format-off" = "󰂲";
      "format-disabled" = "";
      "format-connected" = "<b></b>";
      "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
      "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
      "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
      "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      "on-click" = "rofi-bluetooth -config ~/.config/rofi/menu.d/network.rasi -i";
    };

    "bluetooth#status" = {
      "format-on" = "";
      "format-off" = "";
      "format-disabled" = "";
      "format-connected" = "<b>{num_connections}</b>";
      "format-connected-battery" = "<small><b>{device_battery_percentage}%</b></small>";
      "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
      "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
      "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
      "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      "on-click" = "rofi-bluetooth -config ~/.config/rofi/menu.d/network.rasi -i";
    };

    "battery" = {
      "rotate" = 270;
      "states" = {
        "good" = 95;
        "warning" = 30;
        "critical" = 15;
      };
      "format" = "{icon}";
      "format-charging" = "<b>{icon} </b>";
      "format-full" = "<span color='#82A55F'><b>{icon}</b></span>";
      "format-icons" = [
        "󰁻"
        "󰁼"
        "󰁾"
        "󰂀"
        "󰂂"
        "󰁹"
      ];
      "tooltip-format" = "{timeTo} {capacity} % | {power} W";
    };

    "clock" = {
      "format" = "{:%H\n%M}";
      "tooltip-format" = "<tt><small>{calendar}</small></tt>";
      "calendar" = {
        "mode" = "month";
        "mode-mon-col" = 3;
        "weeks-pos" = "right";
        "on-scroll" = 1;
        "on-click-right" = "mode";
        "format" = {
          "today" = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
        };
      };
    };

    "power-profiles-daemon" = {
      "format" = "{icon}";
      "tooltip-format" = "Power profile = {profile}\nDriver = {driver}";
      "tooltip" = true;
      "format-icons" = {
        "default" = "";
        "performance" = "<span color='#B37F34'><small></small></span>";
        "balanced" = "<span><small> </small></span>";
        "power-saver" = "<span color='#a6e3a1'><small></small></span>";
      };
    };

    "niri/language" = {
      "format" = "{shortDescription}";
    };

    "custom/weather" = {
      "format" = "{}";
      "tooltip" = true;
      "interval" = 3600;
      "exec" = "wttrbar --custom-indicator '{ICON}'";
      "return-type" = "json";
    };

    # TODO: VPN selection (should be a script)
    # "custom/vpn" = {
    #   "format" = "{}; ";
    #   "exec" = "~/.config/waybar/bin/vpn";
    #   "return-type" = "json";
    #   "interval" = 5;
    # };

    # TODO: Support making hotspots.
    # "custom/hotspot" = {
    #   "format" = "{}; ";
    #   "exec" = "~/.config/waybar/bin/hotspot";
    #   "return-type" = "json";
    #   "on-click" = "hash wihotspot && wihotspot";
    #   "interval" = 5;
    # };

    # TODO. Get a color picker and/or sets of similar tools.
    # "custom/colorpicker" = {
    #   "format" = "{}";
    #   "return-type" = "json";
    #   "interval" = "once";
    #   "exec" = "colorpicker -j";
    #   "on-click" = "sleep 1 && colorpicker";
    #   "signal" = 1;
    # };

    # TODO. Button for a screen recording. Should figure out if I can OBS this, or some other tool.
    # "custom/recorder" = {
    #   "format" = "{}";
    #   "interval" = "once";
    #   "exec" = "echo ''";
    #   "tooltip" = "false";
    #   "exec-if" = "pgrep 'wl-screenrec'";
    #   "on-click" = "recorder";
    #   "signal" = 4;
    # };

    "idle_inhibitor" = {
      "format" = "{icon}";
      "tooltip-format-activated" = "Idle Inhibitor is active";
      "tooltip-format-deactivated" = "Idle Inhibitor is not active";
      "format-icons" = {
        "activated" = "󰔡";
        "deactivated" = "󰔢";
      };
    };
  };
}
