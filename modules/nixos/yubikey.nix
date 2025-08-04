{
  config,
  pkgs,
  ...
}: {
  # YubiKey
  environment.systemPackages = [
    pkgs.yubikey-personalization  # CLI tools for configuring YubiKey
    pkgs.yubikey-manager          # Manage YubiKey settings
    pkgs.yubioath-flutter         # GUI for managing YubiKey
    pkgs.yubikey-agent
    pkgs.yubico-pam
    pkgs.libfido2                 # Support for FIDO2/WebAuthn
    pkgs.opensc                   # Smart card support
    pkgs.gnupg                    # If using GPG with YubiKey
    pkgs.pcsclite
  ];

  hardware.gpgSmartcards.enable = true;

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
    yubikey-agent.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
