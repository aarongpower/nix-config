# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  unstable,
  ...
}: let
  importWithExtras = filePath: import filePath {inherit config pkgs lib globals;};
  importWithInputs = filePath: import filePath {inherit config pkgs lib inputs;};
in {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./user.nix
    # ./programs.nix
    (importWithExtras ./age.nix)
    (importWithInputs ./environment.nix)
    ./networking.nix
    ./security.nix
    # ../home/nixos.nix
    ./storage.nix
    ./programs.nix

    # nixos containers
    (importWithInputs ./containers.nix)
    ./nixos-containers/dnsmasq.nix
    ./nixos-containers/zerotier.nix
    ./nixos-containers/monitoring.nix
    # ./nixos-containers/gitea.nix
    ./nixos-containers/garage.nix
    # ./nixos-containers/opencloud.nix

    # Services
    ./services.nix
    ./services/cloudflare.nix
    ./services/samba.nix
    # ./services/k3s.nix

    "${globals.flakeRoot}/ssh/knownHosts.nix"
    ./sops.nix
  ];

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  # Symlink added because there seems to be a bug in the syncthing service
  # definition that causes problems when changing the dataDir
  # When data dir is changed it seems to be trying to put the syncthing
  # database in the nix store
  # But I want to store this in the tank, so I will just symlink it
  systemd.tmpfiles.rules = [
    "L /var/lib/syncthing - - - - /tank/syncthing"
  ];

  nix = {
    extraOptions = ''
      auto-optimise-store = true
    '';

    settings = {
      experimental-features = ["nix-command" "flakes"]; # enable flakes
      substituters = [
        "https://cache.nixos.org/"
        "https://tweag-nickel.cachix.org"
      ];
      trusted-substituters = [
        "https://tweag-nickel.cachix.org"
      ];
      trusted-public-keys = [
        "tweag-nickel.cachix.org-1:GIthuiK4LRgnW64ALYEoioVUQBWs0jexyoYVeLDBwRA="
      ];
      trusted-users = [
        "root"
        "aaronp"
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  nixpkgs = {
    config.allowUnfree = true; # Allow unfree packages
    config.permittedInsecurePackages = [
    ];
  };

  # Enable virtualisation
  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # in your configuration.nix
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_queued_events" = 65536;
  };

  # Weekly garbage collection
  # Delete generations older than 30 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # optimise the store periodically
  nix.optimise.automatic = true;
}
