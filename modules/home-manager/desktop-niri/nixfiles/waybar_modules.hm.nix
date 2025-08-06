{ inputs, outputs, lib, config, pkgs, ... }:

{
  home.packages = [
    pkgs.waybar
    pkgs.rofi-wayland
    pkgs.wttrbar       # Weather widget
    pkgs.pulseaudio    # We need this for `pactl`, even though we enable audio via pipewire
    pkgs.pavucontrol   # The volume control applet
  ];

  programs.waybar.settings.mainBar = {
    ### The modules

    # Just a transparent grey circle. Used as foreground (actually) for radial widgets.
    "custom/radial-progress-bg-outer" = {
      "format" = "<span line_height='0.62ex'></span>";
      "justify" = "center";
    };

    "custom/radial-progress-bg-inner" = {
      "format" = "<span line_height='0.62ex'></span>";
      "justify" = "center";
    };

    "custom/launcher" = {
      "justify" = "center";
      "format" = "󱄅";
      "on-click" = "~/.config/rofi/rofi-toggle.sh";
      "tooltip" = true;
      "tooltip-format" = "Start";
    };

    "niri/window" = {
      "rotate" = 90;
      "max-length" = 40;
    };

    "tray" = {
      "icon-size" = 24;
      "spacing" = 4;
    };

    "group/gcpu" = {
      "orientation" = "inherit";
      "modules" = [
        "cpu"
        "custom/radial-progress-bg-outer"
        "custom/cpu-icon"
      ];
    };
    "custom/cpu-icon" = {
      "format" = "cpu";
    };
    "cpu" = {
      "format-icons" = [
        " "
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
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      "justify" = "center";
      "on-click" = "ghostty -e btop";
    };

    "group/gmemory" = {
      "orientation" = "inherit";
      "modules" = [
        "memory"
        "custom/radial-progress-bg-outer"
        "custom/memory-icon"
      ];
    };
    "custom/memory-icon" = {
      "format" = "mem";
    };
    "memory" = {
      "format-icons" = [
        " "
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
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      "justify" = "center";
      "on-click" = "ghostty -e btop";
      "tooltip-format" = "{used:0.1f}G ({percentage}%) used | {total:0.1f}G total";
    };

    "group/gnvidia" = {
      "orientation" = "inherit";
      "modules" = [
        "custom/nvidia-mem"
        "custom/radial-progress-bg-outer"
        "custom/nvidia-cpu"
        "custom/radial-progress-bg-inner"
        "custom/gpu-icon"
      ];
    };
    "custom/gpu-icon" = {
      "format" = "gpu";
    };
    "custom/nvidia-mem" = {
      "format-icons" = [
        " "
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
      "interval" = 10;
      "exec" = "/home/catalin/.config/scripts/waybar_gpu_metrics --mem --tooltip";
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      "justify" = "center";
      "tooltip" = true;
      "return-type" = "json";
    };

    "custom/nvidia-cpu" = {
      "format-icons" = [
        " "
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
      "interval" = 10;
      "exec" = "/home/catalin/.config/scripts/waybar_gpu_metrics --usage";
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      "justify" = "center";
      "tooltip" = false;
      "return-type" = "json";
    };


    # TODO. Figure out how to read CPU temp in a reasonable way on multiple hardware.
    # "custom/cputemp" = {
    #   "format" = "{}";
    #   "exec" = "~/.config/waybar/bin/cputemp";
    #   "interval" = 10;
    #   "return-type" = "json";
    # };

    "group/gsound" = {
      "orientation" = "inherit";
      "modules" = [
        "pulseaudio#volume"
        "custom/radial-progress-bg-outer"
        "pulseaudio"
      ];
    };

    "pulseaudio#volume" = {
      "format-icons" = [
        " "
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
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      "tooltip-format" = "{volume}% | {desc}";
      "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "on-click-right" = "pavucontrol";
      "on-scroll-up" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "on-scroll-down" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "smooth-scrolling-threshold" = 1;
    };

    "pulseaudio" = {
      "format" = "{icon}";
      "format-bluetooth" = "{icon}";
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

    "group/gbattery" = {
      "orientation" = "inherit";
      "modules" = [
        "battery"
        "custom/radial-progress-bg-outer"
        # "power-profiles-daemon"
      ];
    };

    "battery" = {
      # "rotate" = 270;
      "bat-compatibility" = true;
      "states" = {
        "good" = 95;
        "warning" = 30;
        "critical" = 15;
      };
      "format-icons" = [
        " "
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
      "format" = "<span line_height='0.62ex'>{icon}</span>";
      # "format-charging" = "<b>{icon} </b>";
      # "format-full" = "<span color='#82A55F'><b>{icon}</b></span>";
      "tooltip-format" = "{timeTo} {capacity} % | {power} W | {health} % hp";
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

    "network" = {
      "format" = "{icon}";
      "format-icons" = {
        "wifi" = [
          "󰤨"
        ];
        "ethernet" = [
          "󰌘"
        ];
        "disconnected" = [
          "󰖪"
        ];
      };
      "format-wifi" = "󰤨";
      "format-ethernet" = "󰌘";
      "format-disconnected" = "󰖪";
      "format-linked" = "󰈁";
      "tooltip" = true;
      "tooltip-format" = "{ipaddr}";
      "tooltip-format-wifi" = "{essid} ({signalStrength}%)   \n{ipaddr} | {frequency} MHz{icon} ";
      "tooltip-format-ethernet" = "{ifname} 󰈀 \n{ipaddr} | {frequency} MHz{icon}";
      "tooltip-format-disconnected" = "Not Connected to any type of Network";
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

    "clock" = {
      "format" = "{:%H\n%M}";
      "tooltip-format" = "<tt><small>{calendar}</small></tt>";
      "calendar" = {
        "mode" = "month";
        "mode-mon-col" = 3;
        "weeks-pos" = "left";
        "on-scroll" = 1;
        "on-click-right" = "mode";
        "format" = {
          "today" = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
        };
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
