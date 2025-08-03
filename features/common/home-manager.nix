{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  # Turn on completions for different shells and replace default commands with modern alternatives:
  #   - cd with zoxide
  #   - ls with eza
  #   - ctrl+r with fzf
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
    };
    git.enable = true;

    bat.enable = true;
    eza = {
      enable = true;
      git = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      options = [ "--cmd" "cd" ];
    };
  };
}
