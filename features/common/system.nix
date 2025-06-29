# Generic settings enabled for ALL hosts.

{ inputs, outputs, lib, config, pkgs, ...}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Most common cli tools we always want on both desktops and servers.
  environment.systemPackages = [
    pkgs.bat          # Better cat
    pkgs.btop         # Sexier htop
    pkgs.curl
    pkgs.eza          # Sexier ls
    pkgs.fd           # Better find
    pkgs.jq           # Json parsing and queries
    pkgs.nettools     # netstat
    pkgs.python3Full  # For random pythons scripts. TODO: investigate uv on nixos
    pkgs.ripgrep      # Better grep
    pkgs.tldr         # Nice documentation for cli commands
    pkgs.tree         # Directory listings (compatibility, eza can do them to)
    pkgs.vim
    pkgs.wget

    pkgs.uv           # UV is too cool to not install everywhere!

    # Dependencies for this config.
    pkgs.home-manager # We use home manager everywhere
  ];

  ##############################################################################
  ###### Common configs

  ### Shell
  #  zsh is my default shell, but we can turn on bash as well.
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh pkgs.bash ];

  # zsh basic configs should be global and apply to both myself and root.
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        theme = "linuxonly";
      };
    };
  };

  # Even though I prefer GUI editors, EDITOR should default to vim. I can
  # override it on desktop envs.
  environment.sessionVariables.EDITOR = lib.mkDefault "vim";

  ### Git.
  # TODO: Expand to configure global git settings.
  programs.git.enable = true;

  ### OpenSSH should be enabled everywhere.
  # TODO: Lock down security before I start migrating my laptops to nixos and I
  # start interacting with public wifi.
  services.openssh.enable = true;

  ### Locale settings.
  # Set your time zone.
  # TODO: Figure out how to autodetect this on laptops and show multiple
  # clocks in the UI for them.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    # Locale settings are documented here. I'm only including overrides.
    # https://man7.org/linux/man-pages/man7/locale.7.html
    #
    # en_IE.UTF-8 is the closest thing to metric/european formats within
    # english speaking locales. https://unix.stackexchange.com/a/62317

    # Formatting for postal addresses and georgraphic related items.
    LC_ADDRESS = "ro_RO.UTF-8";

    # This should make things be metric instead of imperial.
    LC_MEASUREMENT = "en_IE.UTF-8";

    # Should be formatting for Euros
    LC_MONETARY = "en_IE.UTF-8";

    # Should prefer A4 over Letter for page formats.
    LC_PAPER = "en_IE.UTF-8";

    # Formatting for phone numbers.
    LC_TELEPHONE = "ro_RO.UTF-8";

    # dd/mm/yy and 24 hour clocks. Might also affect "week starts on monday"?
    LC_TIME = "en_IE.UTF-8";
  };


  ##############################################################################
  ###### Configs which affect nixos specific features

  nixpkgs = {
    config.allowUnfree = true;
  };

  ### Configurations for nix itself.
  nix = {
    # TODO. Unsure what this next line does or why I copied it from the web.
    package = lib.mkDefault pkgs.nix;
    # Story: I use flakes because others use flakes... I don't think I'll
    # change that anytime soon, however the docs make a good point about why
    # they're still experimental:
    # https://nix.dev/concepts/flakes#why-are-flakes-controversial
    settings.experimental-features = ["nix-command" "flakes"];
  };

  ### Garbage collection. Auto-delete from /nix/store if older than 10 days.
  # We also get to specify when this gets triggered.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45m";
    options = "--delete-older-than 10d";
  };

  ### Global home-manager settings
  # TODO. I don't know what these 2 settings actually do...
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
  # Home manager takes backups of volatile stuff in the home folder when
  # building a new generation. I don't fully understand what is affected or not.
  # So far, I mainly had problems with some firefox files and I have to keep
  # removing *.hm.bak files before testing new versions of my os. It sucks.
  # TODO: We want to turn on impermancence by default later, and we should be
  # able to remove these after that.
  home-manager.backupFileExtension = "hm.bak";

  ##############################################################################
  ###### Build time settings.

  ### Secret management
  # All hosts need to read/access secrets.
  # Story: Setting up secrets took a lot of figuring out, here's the best way I
  # could get this working:
  #   1. I use an ssh key (ed25519). ssh keys are easy to store in secure
  #      places (including yubikeys)
  #   2. To edit secrets, derive an age key:
  #      `nix run nixpkgs#ssh-to-age -- -private-key -i [path_to_ssh_key] > [path_to_age_key]`
  #   3. (Had to do it once, but optional) derive a public key and store it in .sops.yaml:
  #      `nix-shell -p age -c age-keygen -y [path_to_age_key]`
  #   4. Delete [path_to_age_key] (can be derived again anytime). One only
  #      needs the public key to encrypt data!
  #   5. Actually edit the secrets: `sops secrets.yml`
  #   6. In here, we can just reference the ssh key directly.
  # My understanding is this REQUIRES ed25519 and would not work with RSA.
  #
  # Story: This is what I find cool about nixos. I needed "ssh-to-age" and
  # "age" once to derive a public key. I am sure they get used when building a
  # new generation of my OS. But I never explicitly installed them. I have no
  # reference to either piece of software for my user or for root.
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = ["/persistent/nixos-build-time/.ssh/fortytwo"];
  };
}
