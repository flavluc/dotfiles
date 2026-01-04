{
  description = "Flavio's NixOS multi-host configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 1. Add the NUR input
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # 2. Add the NUR overlay to system modules
          { nixpkgs.overlays = [ nur.overlays.default ]; }
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
          { nixpkgs.overlays = [ nur.overlays.default ]; }
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
