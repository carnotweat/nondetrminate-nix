{
  description = "Morph NixOS configuration with flakes";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  #inputs.morph.url = "github:DBCDK/morph/v1";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # morph support
        #morph.module
        #{ deployment = { targetHost = "pub"; }; }

        # Use the flake path for the nix path
        { nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ]; }

        ./configuration.nix
      ];
    };
  };
}
