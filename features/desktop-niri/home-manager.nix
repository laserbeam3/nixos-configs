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
    ./nixfiles/waybar.nix
    ./nixfiles/firefox.nix
  ];

  home.packages = [
    pkgs.albert  # Albert is our app launcher. Keybinding in niri.
    pkgs.ghostty  # We need a terminal emulator always. Keybinding in niri.

    # Basic gnome apps (might want to change them later, but not worth now)
    pkgs.gthumb    # File manager
    pkgs.nautilus  # Image viewer

    # I need a wallpaper
    pkgs.swww      # Apparently, I need a wallpaper daemon. Why. Ok. Sure...
    (import ./nixfiles/set_wallpaper.nix { inherit pkgs; })
  ];

  home.file.".config/ghostty" = {
    recursive = true;
    source = ./.config/ghostty;
  };
  home.file.".config/niri" = {
    recursive = true;
    source = ./.config/niri;
  };
  home.file.".config/swaylock" = {
    recursive = true;
    source = ./.config/swaylock;
  };
  home.file.".config/wallpapers" = {
    recursive = true;
    source = ./.config/wallpapers;
  };

  home.file.".local/share/fonts/radial-progress.ttf" = {
    recursive = false;
    source = ./assets/radial-progress.ttf;
  };

  ### Lockscreen
  # TODO. There's references to swaylock in both system and user settings. do we need in both?
  programs.swaylock.enable = true;

  ### Wallpaper
  # We need a wallpaper daemon.
  # WARNING. wpaperd keeps crashing! There are scary coredumps in systemd and
  # overnight I lose my wallpaper. Should figure out dependencies or replace with something else.

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
        animation.reveal.hide_duration = 100;
        animation.reveal.show_duration = 100;
        animation.resize.hide_duration = 100;
        animation.resize.show_duration = 100;
        animation.workspace.duration = 100;
        animation.workspace.switch = 100;
      };
      keys = {
        modifier = "Super";
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

  ### App launcher
  # We use albert because I find rofi and other similar minimalist launchers
  # too minimal. I really need my launcher to do things like "timer 10
  # minutes" to start a timer. If google can do small tasks like that, so
  # should my launcher! Albert needs a background service to run. This service
  # should start after the window manager.
  systemd.user.services.albert = {
    Unit = {
      Description = "Albert launcher";
      Before = "graphical-session.target";
      BindsTo = "graphical-session.target";
      Wants = "niri.service";
      After = "niri.service";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.albert}/bin/albert";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
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
      Settings = ''
        gtk-application-prefer-dark-theme = 1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme = 1
      '';
    };
  };

  ### Other things.
  # swayland-sattelite is a recommended niri module, but will become part of the window manager in
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

}
