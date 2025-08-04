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
  imports = [
    ./waybar_modules.hm.nix
  ];

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
      "group/gcpu"
      "group/gmemory"
    ]
    ++ (if config.desktopNiri.showNvidiaGpuWidget then ["group/gnvidia"] else [])
    ++ (if config.desktopNiri.showLaptopWidgets then ["group/gbattery"] else [])
    ++ [
      "group/gsound"
      "network"
      "niri/language"
      "custom/weather"
      # "idle_inhibitor"
      "clock"
    ];
  };
}
