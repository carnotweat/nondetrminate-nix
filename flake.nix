{
  description = "my NixOS configuration with flakes";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  #inputs.morph.url = "github:DBCDK/morph/v1";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Use the flake path for the nix path
        { nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ]; }
        ./configuration.nix
      ];
    };
  };
}
