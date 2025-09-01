{
  description = "NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default-linux";
    hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    disko,
    nixpkgs,
    home-manager,
    sops-nix,
    systems,
    ...
  } @ inputs:
  let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    inherit lib;

    # For reference, if we declare our own packages, overlays and modules in
    # our config we ned to add them here as well. For reference on how this is
    # done: https://github.com/Misterio77/nix-config/blob/main/flake.nix

    nixosConfigurations = {
      # Main desktop
      stingray = lib.nixosSystem {
        modules = [ ./hosts/stingray ];
        specialArgs = { inherit inputs outputs; };
      };

      timeeater = lib.nixosSystem {
        modules = [ ./hosts/timeeater ];
        specialArgs = { inherit inputs outputs; };
      };
    };
  };
}
