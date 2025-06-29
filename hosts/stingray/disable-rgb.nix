# This loops over all devices supported by openrgb and turns them off.
# TODO: Simplify the script and turn off only my RAM sticks with the next
# version of openrgb. The release candidate has been out for 4 months, I saw
# commits related to my particular RAM sticks, and I'd rather wait for an
# official build than figure out how to compile the rc myself.

{ pkgs, lib, ... }:
let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    done
  '';
in {
  config = {
    services.udev.packages = [ pkgs.openrgb ];
    services.hardware.openrgb.enable = true;
    boot.kernelModules = [ "i2c-dev" ];
    hardware.i2c.enable = true;

    systemd.services.no-rgb = {
      description = "no-rgb";
      serviceConfig = {
        ExecStart = "${no-rgb}/bin/no-rgb";
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
