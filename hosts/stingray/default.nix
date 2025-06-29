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
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./yubikey.nix

    # Disable RAM rgb lights. Well, sort of, the drivers for my particular ugly
    # RAM sticks appear to be implemented only in the upcoming release. They
    # still glow for now...
    ./disable-rgb.nix

    ../../features/common/system.nix
    ../../features/desktop-niri/system.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ../../home/catalin
  ];

  environment = {
    systemPackages = [
      pkgs.openrgb
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "stingray"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Common services
  services = {
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
  };

  # Enable the desktop
  programs.steam.enable = true;

  # Requirements for feature/desktop-niri
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?
}
