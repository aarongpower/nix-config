{
  description = "Unified flake for both NixOS and Darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    concierge = {
      url = "github:aarongpower/nix-concierge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
      # inputs.nixpkgs.follows = "nixpkgs"; # nixpkgs not referenced in proxmox-nixos
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    home-manager,
    fenix,
    nix-darwin,
    agenix,
    compose2nix,
    # sops-nix,
    ...
  } @ inputs: let
    system = builtins.currentSystem;
    usefulValues = {
      flakeRoot = ./.;
      timezone = "Asia/Jakarta";
    };
    # flakeRoot = ./.;
    overlays = [
      fenix.overlays.default
    ];
    sharedModules = [
      ({pkgs, ...}: {nixpkgs.overlays = overlays;})
      inputs.lix-module.nixosModules.default
      # sops-nix.nixosModules.sops
    ];
    linuxModules = [
      agenix.nixosModules.default
      # inputs.vscode-server.nixosModules.default
    ];
    darwinModules = [
      ./systems/astra/configuration.nix
      # Other Darwin specific modules
    ];
    # unstablePkgs = import nixpkgs-unstable {inherit system;};
  in {
    nixosConfigurations = {
      yggdrasil = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            ./systems/yggdrasil/configuration.nix
            inputs.proxmox-nixos.nixosModules.proxmox-ve
            ({...}: let
              generatedContainers = self.packages.x86_64-linux.generate-containers {containersDir = ./systems/yggdrasil/containers;};
              # Debug statement to print the output path
              _ = builtins.trace "generatedContainers output path: ${generatedContainers}" null;
            in {
              imports = [
                (import "${generatedContainers}/containers.nix")
              ];
            })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaronp = import ./home/yggdrasil.nix;
              home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix usefulValues;};
            }
            ({lib, ...}: {
              nixpkgs.overlays = lib.mkBefore [
                inputs.proxmox-nixos.overlays.x86_64-linux
              ];
            })
          ]
          ++ linuxModules ++ sharedModules;
        specialArgs = {inherit inputs usefulValues;};
      };
      vulcan-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          linuxModules
          ++ sharedModules
          ++ [
            nixos-wsl.nixosModules.default
            ./systems/vulcan-nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaronp = import ./home/vulcan-nixos.nix;
              home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix usefulValues;};
            }
          ];
        specialArgs = {inherit inputs usefulValues;};
      };
    };

    darwinConfigurations = {
      astra = nix-darwin.lib.darwinSystem {
        modules =
          darwinModules
          ++ sharedModules
          ++ [
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaronpower = import ./home/astra.nix;
              home-manager.extraSpecialArgs = {inherit inputs agenix fenix;};
            }
          ];
        specialArgs = {inherit self;};
      };
    };
    packages.x86_64-linux.generate-containers = {containersDir}:
      import ./derivations/generate-containers/default.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        compose2nix = compose2nix;
        inherit containersDir;
      };
  };
}
# TAGGED: 2024-09-15T06:48:20.372342378+00:00

