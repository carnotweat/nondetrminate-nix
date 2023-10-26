{ config, lib, pkgs, inputs, system, ... }:

{
  imports = [
    inputs.guix-overlay.nixosModules.guix
  ];

　# Enabling the Guix daemon and install the package manager in your system.
  services.guix.enable = true;
}
