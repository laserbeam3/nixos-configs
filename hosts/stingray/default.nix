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
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./yubikey.nix

    # Disable RAM rgb lights. Well, sort of, the drivers for my particular ugly
    # RAM sticks appear to be implemented only in the upcoming release. They
    # still glow for now...
    ./disable-rgb.nix

    ../../features/common/system.nix
    ../../features/desktop-niri/system.nix
    ../../features/windows-apps/system.nix

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

  # This should make USB devices mount automatically.
  services.udisks2.enable = true;

  # Enable the desktop
  programs.steam.enable = true;

  # Requirements for feature/desktop-niri
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];
  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    # Prime mode is imported from "github:nixos/nixos-hardware"
    prime = {
      amdgpuBusId = "PCI:16:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?
}
