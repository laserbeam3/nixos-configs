# WIP. Not yet imported anywhere. Still researching.
# Goals:
#   - enable virtualization
#   - use qemu
#   - figure out if we can install the vm declaratively form nix (download windows enterprise iso,
#     save the activation key in secrets.yaml, setup the VM, and maybe even install an app from
#     here? how far can we go? )
#
# This should set up a windows VM for the windows apps I might need.

{ inputs, outputs, lib, config, pkgs, ...}:
{
  # Phase 1. Copy paste from https://nixos.wiki/wiki/Virt-manager
  programs.virt-manager.enable = lib.mkDefault true;
  users.groups.libvirtd.members = ["catalin"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
