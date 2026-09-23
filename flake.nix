{
  description = "Flavio's NixOS multi-host configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 1. Add the NUR input
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nur, ... }: 
  let
    pkgs-unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    # nixpkgs-unstable costuma atrasar alguns dias em relação ao release do
    # claude-code. O manifest.json vendorado aponta a mesma derivation do
    # nixpkgs para o binário oficial mais novo. Para atualizar:
    #   curl -sf https://downloads.claude.ai/claude-code-releases/<versão>/manifest.json \
    #     > home/programs/claude-code/manifest.json
    claude-code-latest = pkgs-unstable.claude-code.override {
      manifest = nixpkgs.lib.importJSON ./home/programs/claude-code/manifest.json;
    };
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # 2. Add the NUR overlay to system modules
          { 
            nixpkgs.overlays = [ 
              nur.overlays.default
              (final: prev: {
                claude-code = claude-code-latest;
              })
            ]; 
          }
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.flavio = import ./home/default.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
      
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # 2. Add the NUR overlay to system modules
          { 
            nixpkgs.overlays = [ 
              nur.overlays.default
              (final: prev: {
                claude-code = claude-code-latest;
              })
            ]; 
          }
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.flavio = import ./home/default.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}
