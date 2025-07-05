{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = false;
  users.users.catalin = {
    hashedPasswordFile = config.sops.secrets.catalin-password.path;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ifTheyExist [
      "docker"
      "podman"
      "git"
      "network"
      "networkmanager"
      "wheel"
    ];
    packages = [
      pkgs.imagemagick
      pkgs.chromium
      pkgs.hyperfine
      pkgs.nmap
      pkgs.obs-studio
      pkgs.signal-desktop-bin
      pkgs.spotify
      pkgs.steam
      pkgs.sublime-merge
      pkgs.vscode
      pkgs.zed-editor
    ];
  };

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us, ro";
  services.xserver.xkb.options = "grp:win_space_toggle";

  sops.secrets.catalin-password = {
    sopsFile = ../../secrets/secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.catalin = import ./home-manager-${config.networking.hostName}.nix;
}
