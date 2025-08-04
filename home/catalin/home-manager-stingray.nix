{
  inputs,
  lib,
  pkgs,
  config,
  osConfig,
  outputs,
  ...
}: {
  imports = [
    ../../modules/home-manager/common.hm.nix
    ../../modules/home-manager/desktop-niri/default.hm.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # This should make USB devices mount automatically.
  # https://wiki.nixos.org/wiki/USB_storage_devices
  services.udiskie.enable = true;

  # Custom configs.
  desktopNiri.showNvidiaGpuWidget = true;

  # Hide OpenRGB from rofi apps.
  xdg.desktopEntries.OpenRGB = {
    name = "OpenRGB";
    noDisplay = true;
  };

  home = {
    username = lib.mkDefault "catalin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.05";

    file.".config" = {
      recursive = true;
      source = ./.config;
    };

    ##########################################
    #  Add host specific outputs for the attached monitors to the niri config.
    file.".config/niri/config.kdl".text = lib.mkAfter ''
      output "LG Electronics LG HDR DQHD 0x0004F94B" {
        mode "5120x1440@60.000"
        scale 1.0
        variable-refresh-rate on-demand=true
        focus-at-startup
      }

      output "Samsung Electric Company Q90A 0x01000E00" {
        mode "1920x1080@60.000"
        scale 1.0
      }
    '';
  };
}
