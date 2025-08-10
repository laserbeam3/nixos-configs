# Imported as home-manager.users.catalin = import <this file>
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nixfiles/waybar.hm.nix
    ./nixfiles/firefox.hm.nix
  ];

  options.desktopNiri = {
    showNvidiaGpuWidget = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show GPU widget in the taskbar.";
    };

    showLaptopWidgets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show laptop specific widgets in the taskbar (battery and such).";
    };
  };

  config = {
    home.packages = [
      pkgs.rofi-wayland  # Rofi is also our app launcher. Keybinding in niri.
      pkgs.ghostty  # We need a terminal emulator always. Keybinding in niri.

      # Basic gnome apps (might want to change them later, but not worth now)
      pkgs.gthumb    # Image viewer
      pkgs.nautilus  # File manager

      # I need a wallpaper
      pkgs.swww      # Apparently, I need a wallpaper daemon. Why. Ok. Sure...
      (import ./nixfiles/set_wallpaper.nix { inherit pkgs; })
    ];

    home.file.".config/ghostty" = {
      recursive = true;
      source = ./assets/ghostty;
    };

    home.file.".config/rofi" = {
      recursive = true;
      source = ./assets/rofi;
    };

    home.file.".config/wallpapers" = {
      recursive = true;
      source = ./assets/wallpapers;
    };

    # TODO. Should build this with nix instead of including it as a binary.
    home.file.".config/scripts/waybar_gpu_metrics" = {
      recursive = true;
      source = ./assets/waybar_gpu_metrics;
    };

    home.file.".local/share/fonts/radial-progress.ttf" = {
      recursive = false;
      source = ./assets/radial-progress.ttf;
    };

    ### App switcher
    # Niri switcher is the most compenent app switcher I could find and works good enough to compare
    # with a regular alt tab. I might want to investigate, configure or fork this eventually.
    programs.niriswitcher = {
      enable = true;
      settings = {
        separate_workspaces = false;
        appearance = {
          icon_size = 96;
          workspace_format = "{output} {idx}";
          animation.reveal.hide_duration = 80;
          animation.reveal.show_duration = 80;
          animation.resize.hide_duration = 80;
          animation.resize.show_duration = 80;
          animation.workspace.duration = 80;
          animation.workspace.switch = 80;
        };
        keys = {
          modifier = "Alt";
          switch = {
            next = "Tab";
            prev = "Shift+Tab";
          };
          workspace = {
            next = "grave";
            prev = "Shift+asciitilde";
          };
        };
      };
    };

    ### Theming
    # I like dark mode. Apparently I have to specify that in many many places.
    # I'm actually unsure I covered them all...
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    # TODO: Do I need this?
    # home.sessionVariables.GTK_THEME = "palenight";
    home.sessionVariables.GTK_THEME = "Adwaita";

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita";
        package = pkgs.gnome-themes-extra;
      };

      iconTheme = {
        name = "Vimix-beryl-dark";
        package = pkgs.vimix-icon-theme;
      };

      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    ############################################################################
    # Niri shared configuration. Behaviour is shared across hosts, but each
    # host may override outputs, inputs and layouts based on default monitors
    # and input devices.

    # TODO(catalin): Move this into a separate module file to learn about
    # options in nix. The goal of that module is to let me extract window rules
    # outside of the config file, and hide some of the syntax for that.

    home.file.".config/niri/config.kdl".text = ''
      spawn-at-startup "waybar"
      spawn-at-startup "swww-daemon"
      spawn-at-startup "set_wallpaper"
      spawn-at-startup "niriswitcher"
      prefer-no-csd

      window-rule {
        draw-border-with-background false
        geometry-corner-radius 6
        clip-to-geometry true
      }

      window-rule {
        match is-floating=false
        shadow {
          off
        }

        focus-ring {
          width 5
          active-color "#97bf6c"
          inactive-color "#aab4a2"
          urgent-color "#b5a0f2"
        }
      }

      window-rule {
        match app-id="org.gnome.Nautilus" title="^Open (Folder|File)$"
        open-floating true
      }

      window-rule {
        match app-id="org.gnome.Nautilus" title="^Save (As|Folder|File)$"
        open-floating true
      }

      window-rule {
        match app-id="org.pulseaudio.pavucontrol"
        open-floating true
        default-floating-position x=0 y=0 relative-to="bottom-left"
      }

      input {
        keyboard {
          xkb {
            model "pc104"
            layout "us,ro(std)"
            options "grp:win_space_toggle"
          }
          numlock
        }
      }

      layout {
        gaps 6
        center-focused-column "never"
        always-center-single-column
        default-column-display "normal"  // "normal" / "tabbed"

        default-column-width { proportion 0.25; }
        preset-column-widths {
          proportion 0.25
          proportion 0.3333
          proportion 0.5
        }

        focus-ring {
          width 5
          active-color "#ed8fad"
          inactive-color "#aab4a2"
          urgent-color "#b5a0f2"
        }

        border {
          off
        }

        shadow {
          on
          color "#000000a0"
        }

        tab-indicator {
          width 4
          gap 8
          corner-radius 4
          length total-proportion=0.35
          gaps-between-tabs 12
          position "left"
          place-within-column
          hide-when-single-tab
        }
      }

      animations {
        slowdown 0.45
        window-resize {
          curve "linear"
          duration-ms 0
        }
      }

      // A hot corner to activate the Overview is nice, but I want a different
      // corner, not top left. I want a "start" button in top left right now.
      // Until things change or other hot-corners get implemented, I shall turn
      // them off.
      gestures {
        hot-corners {
          off
        }
      }

      binds {
        // Mod-Shift-/, which is usually the same as Mod-?,
        // shows a list of important hotkeys.
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Suggested binds for running programs: terminal, app launcher, screen locker.
        Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
        Mod+D hotkey-overlay-title="Run an Application: launcher" { spawn "~/.config/rofi/rofi-toggle.sh"; }
        Mod+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+A repeat=false { toggle-overview; }
        Mod+Q              { close-window; }

        Mod+R              { switch-preset-column-width; }
        Mod+Shift+R        { switch-preset-window-height; }
        Mod+Ctrl+R         { reset-window-height; }
        Mod+F              { maximize-column; }
        Mod+Shift+F        { fullscreen-window; }
        Mod+E              { expand-column-to-available-width; }

        Mod+C              { center-column; }
        Mod+Ctrl+C         { center-visible-columns; }

        Mod+V              { toggle-window-floating; }
        Mod+Shift+V        { switch-focus-between-floating-and-tiling; }
        Mod+W              { toggle-column-tabbed-display; }

        Print              { screenshot; }
        Ctrl+Print         { screenshot-window write-to-disk=false; }
        Alt+Print          { screenshot-screen write-to-disk=false; }

        // Applications such as remote-desktop clients and software KVM switches may
        // request that niri stops processing the keyboard shortcuts defined here
        // so they may, for example, forward the key presses as-is to a remote machine.
        // It's a good idea to bind an escape hatch to toggle the inhibitor,
        // so a buggy application can't hold your session hostage.
        //
        // The allow-inhibiting=false property can be applied to other binds as well,
        // which ensures niri always processes them, even when an inhibitor is active.
        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        // The quit action will show a confirmation dialog to avoid accidental exits.
        Ctrl+Alt+Delete { spawn "~/.config/rofi/powermenu.sh"; }

        // Example volume keys mappings for PipeWire & WirePlumber.
        // The allow-when-locked=true property makes them work even when the session is locked.
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        // Alt+Tab!
        Alt+Tab repeat=false { spawn "niriswitcherctl" "show" "--window"; }
        Alt+Shift+Tab repeat=false { spawn "niriswitcherctl" "show" "--window"; }
        Alt+Grave repeat=false { spawn "niriswitcherctl" "show" "--workspace"; }
        Alt+Shift+Grave repeat=false { spawn "niriswitcherctl" "show" "--workspace"; }

        ///////////////////////////////////////////////////////////////////
        // Everything below is about moving between windows via arrow keys.

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Down  { move-window-down; }

        // The following binds move the focused window in and out of a column.
        // If the window is alone, they will consume it into the nearby column to the side.
        // If the window is already in a column, they will expel it out.
        Mod+Alt+Left         { consume-or-expel-window-left; }
        Mod+Alt+Right        { consume-or-expel-window-right; }
        Mod+Alt+Up           { move-window-up; }
        Mod+Alt+Down         { move-window-down; }

        Mod+Ctrl+Left        { focus-monitor-left; }
        Mod+Ctrl+Right       { focus-monitor-right; }
        Mod+Ctrl+Up          { focus-workspace-up; }
        Mod+Ctrl+Down        { focus-workspace-down; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+Up    { move-column-to-workspace-up; }
        Mod+Shift+Ctrl+Down  { move-column-to-workspace-down; }

        Mod+Alt+Ctrl+Left    { move-window-to-monitor-left; }
        Mod+Alt+Ctrl+Right   { move-window-to-monitor-right; }
        Mod+Alt+Ctrl+Up      { move-window-to-workspace-up; }
        Mod+Alt+Ctrl+Down    { move-window-to-workspace-down; }

        // You can refer to workspaces by index. However, keep in mind that
        // niri is a dynamic workspace system, so these commands are kind of
        // "best effort".
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Minus       { set-column-width "-10%"; }
        Mod+Equal       { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Actions to switch layouts.
        // Note: if you uncomment these, make sure you do NOT have
        // a matching layout switch hotkey configured in xkb options above.
        // Having both at once on the same hotkey will break the switching,
        // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        // Mod+Space       { switch-layout "next"; }
        // Mod+Shift+Space { switch-layout "prev"; }
      }
    '';

    ############################################################################
    # Lockscreen
    # TODO. There's references to swaylock in both system and user settings. do we need in both?

    programs.swaylock.enable = true;
    home.file.".config/swaylock/config".text = ''
      image=~/.config/wallpapers/purple-firewatch.png
      indicator-radius=120
      indicator-thickness=30
      show-keyboard-layout
      ignore-empty-password
    '';


    ### Other things.
    # xwayland-sattelite is a recommended niri module, but will become part of the window manager in
    # future releases.
    # TODO: Remove with the next niri release.
    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland outside your Wayland";
        Before = "graphical-session.target";
        BindsTo = "graphical-session.target";
        Wants = "niri.service";
        After = "niri.service";
      };
      Service = {
        Type = "simple";
        Slice = "session.slice";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
