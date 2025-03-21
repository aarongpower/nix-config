{
  description = "Unified flake for both NixOS and Darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
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
      url = "github:nix-community/home-manager/release-24.05";
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

    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
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
    ...
  } @ inputs: let
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
    ];
    linuxModules = [
      agenix.nixosModules.default
    ];
    darwinModules = [
      ./systems/astra/configuration.nix
      # Other Darwin specific modules
    ];
  in {
    nixosConfigurations = {
      yggdrasil = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          sharedModules
          ++ linuxModules
          ++ [
            ./systems/yggdrasil/configuration.nix
            inputs.proxmox-nixos.nixosModules.proxmox-ve
            ({...}: let
              generatedContainers = self.packages.x86_64-linux.generate-containers {containersDir = ./systems/yggdrasil/containers;};
              # Debug statement to print the output path
              # _ = builtins.trace "generatedContainers output path: ${generatedContainers}" null;
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
            {
              nixpkgs.overlays = (overlays ++ [ inputs.proxmox-nixos.overlays.x86_64-linux ]);
            }
          ];
        specialArgs = {inherit inputs usefulValues;};
      };
      vulcan-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = linuxModules ++ [
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
    packages.x86_64-linux.generate-containers = { containersDir }:
        let
          result = import ./derivations/generate-containers/default.nix {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            compose2nix = compose2nix;
            inherit containersDir;
          };
        in
          builtins.trace "generate-containers output path: ${result}" result;
   };
}
# TAGGED: 2024-09-15T06:48:20.372342378+00:00

