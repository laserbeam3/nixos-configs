# UNTESTED!!

{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content.type = "gpt";
    content.partitions = {
      # Boot partition.
      ESP = {
        priority = 1;
        name = "ESP";
        start = "1M";
        end = "512M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };

      # Main Partition
      nixos = {
        name = "nixos";
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ]; # Override existing partition
          subvolumes = {
            "/rootfs" = {
              mountpoint = "/";
            };

            "/home" = {
              mountpoint = "/home";
            };

            "/persistent" = {
              mountpoint = "/persistent";
            };

            "/nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "noatime"
              ];
            };

            # TODO. I think this did not work.
            "/swap" = {
              mountpoint = "/.swapvol";
              swap.swapfile.size = "20M";
            };
          };
        };
      };
    };
  };
}
