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
    ../../features/common/home-manager.nix
    ../../features/desktop-niri/home-manager.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # This should make USB devices mount automatically.
  # https://wiki.nixos.org/wiki/USB_storage_devices
  services.udiskie.enable = true;

  home = {
    username = lib.mkDefault "catalin";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.05";

    file.".config" = {
      recursive = true;
      source = ./.config;
    };
  };
}
