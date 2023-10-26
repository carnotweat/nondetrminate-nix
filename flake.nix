{
  description = "my NixOS configuration with flakes";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";  
  inputs.guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";
    outputs = { self, nixpkgs, guix-overlay }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #hermetic - teck every input to be followed. Use the flake path for the nix path
        { nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ]; }
        ./configuration.nix
      ];
    };
  };
}
