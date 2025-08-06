# TODO. Document!

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.framework-12th-gen-intel

    ./hardware-configuration.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop-niri.nix
    ../../modules/nixos/yubikey.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ../../home/catalin
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.hostName = "timeeater"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Common services
  services = {
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
  };

  # This should make USB devices mount automatically.
  services.udisks2.enable = true;

  # Enable the desktop
  programs.steam.enable = true;

  # Laptop specific. Enable power management via TLP.
  services.tlp.enable = true;
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 80; # Applies to EC firmware v3 only
    STOP_CHARGE_THRESH_BAT0 = 85;
  };

  # Based on https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/12th-gen-intel
  services.fwupd.enable = true;


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?
}
