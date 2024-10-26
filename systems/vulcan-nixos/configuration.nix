{ config, pkgs, lib, usefulValues, ... }:

let
  importWithExtras = filePath: import filePath { inherit config pkgs lib usefulValues; };
in
{
  imports = [
    (importWithExtras ./age.nix)
    ./environment.nix
    ./networking.nix
    ./programs.nix
    ./security.nix
    ./user.nix
  ];

  # nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  wsl.enable = true;
  wsl.defaultUser = "aaronp";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    git
    curl
    helix
    direnv
    poetry
    zellij
    wormhole-rs
  ];
}

