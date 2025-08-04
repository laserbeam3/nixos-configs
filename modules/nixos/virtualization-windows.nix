# Virtualization with support for windows VMs.
#
# I'm really not sure about everything here. Mileage may vary. I know I haven't
# gotten GPU drivers working yet.

{ inputs, outputs, lib, config, pkgs, ...}:
{
  hardware.graphics.enable = true;
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  boot.initrd.availableKernelModules = [ "amdgpu" "vfio-pci" ];

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = ''
      uri_default = "qemu:///system"
    '';
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      vhostUserPackages = [ pkgs.virtiofsd ];
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [
        (pkgs.OVMFFull.override {
          secureBoot = true;
          tpmSupport = true;
          tlsSupport = true;
          httpSupport = true;
        }).fd
      ];
    };
  };
}
