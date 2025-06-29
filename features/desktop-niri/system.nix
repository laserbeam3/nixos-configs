# Systemwide configuration for a desktop environment using
# [niri](https://github.com/YaLTeR/niri).
#
##### REQUIRED AFTER IMPORT.
#
# # The desktop feature turns on graphics, but cannot decide which drivers are
# # needed:
# services.xserver.videoDrivers = ["nvidia"];
# hardware.nvidia.open = true;
#
#####
#
# I love the idea of an infinite window manager, especially for my ultrawide
# monitor. As I understand it, XOrg is being deprecated by several major
# distros, so I might as well bite the bullet and use/learn Wayland.
#
# I don't want a full desktop environment (gnome/kde), I want to know all the
# small components and understand how they are glued together.
#
# The starting setup was:
#   - niri as a window manager
#   - waybar as a task bar
#   - a decent window switcher
#   - a powerful app launcher
#   - a TUI login screen (confusingly called a "desktop manager" in linux land)
#   - small wayland packages for various utilities (wallpaper, lock screen...)
#   - gnome apps by default for straightfoward tools (file manager, image
#     viewers and such)
#
# Design principles:
#   - Keyboard shortcuts are great, but I also want casual users to be able to
#     get around with minimal learning.
#   - Very fast animations are good. Anymations help other users follow along
#     with what I'm doing (when screensharing, for example). By default, the
#     fastest animation defined in most examples is too slow.
#   - Don't go crazy with visual flair. One primary accent color, simple static
#     background. I had my fun with compiz back in the day and it's not worth
#     it.
#   - Expect flexibility, not over specific setups. Apps change, they're not
#     pinned to specific workspaces many times. I should be able to find them
#     easily (not only by jumping to a workspace with a numbered shortcut).

{ inputs, outputs, lib, config, pkgs, ...}:
{
  # Turn on graphics
  hardware.graphics.enable = true;
  # TODO. Check if I need this
  # services.xserver.enable = true;

  # Turn on audio. Pipewire is the service to be used.
  # TODO. Verify if I need all the other flags enabled (unsure how...)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  # We need realtime support for audio, so rtkit must also be enabled.
  security.rtkit.enable = true;

  environment.systemPackages = [
    # xwayland-satellite is the mechanism by which niri starts x11 apps (such
    # as steam)
    # TODO: Remove for the next official release of niri. The window manager
    # should start this automatically soon.
    pkgs.xwayland-satellite
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Required by electron apps
    DISPLAY = ":0";  # Required by x11 apps (such as steam)
  };

  # Fonts should be available to the whole system.
  fonts.fontDir.enable = true;
  # These are default font rendering settings. I have experimented at some point
  # with adjusting them, but I actually like the defaults on my monitors. Will
  # leave them in.
  fonts.fontconfig = {
    enable = true;
    subpixel.lcdfilter = "default";  # "none", "default", "light", "legacy"
    subpixel.rgba = "none";  # "none", "default", "light", "legacy"
    hinting.style = "slight";  # "none", "slight", "medium", "full"
  };
  # TODO. Review which fonts I actually use and remove all the monospace fonts
  # with ligatures. Should update configs in ghostty, text editors and waybar.
  fonts.packages = [
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.noto
    pkgs.nerd-fonts.roboto-mono
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.nerd-fonts.symbols-only
    pkgs.font-awesome
    pkgs.noto-fonts
    pkgs.noto-fonts-emoji
  ];

  # The window manager should be enabled as a system program.
  programs.niri.enable = true;

  # The login screen. tuigreet works great and does its job. I tried ly before
  # but mostly had issues with it.
  #
  # Story: While I was configuring tuigreet and switched away from ly I also
  # fixed issues with various startup services that were being enabled out of
  # order. Unsure if ly was the problem or not, but I think ly was turning on
  # niri incorrectly at the time.
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd niri-session
      '';
    };
  };

  # Our lock screen needs access to pam to check the user password.
  security.pam.services.swaylock = {};
}
