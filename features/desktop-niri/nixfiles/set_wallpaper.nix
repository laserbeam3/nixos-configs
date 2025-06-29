{ pkgs, ... }:

pkgs.writeShellScriptBin "set_wallpaper" ''
  ${pkgs.swww}/bin/swww img "/home/catalin/.config/wallpapers/purple-firewatch.png" --transition-type none
''
