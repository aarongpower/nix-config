# Auto-generated using compose2nix v0.2.3-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."scrypted" = {
    image = "ghcr.io/koush/scrypted";
    environment = {
      "SCRYPTED_NVR_VOLUME" = "/nvr";
    };
    volumes = [
      "/tank/containers/scrypted/db:/server/volume:rw"
      "/tank/nvr:/nvr:rw"
    ];
    labels = {
      "com.centurylinklabs.watchtower.scope" = "scrypted";
    };
    log-driver = "none";
    extraOptions = [
      "--network=host"
    ];
  };
  systemd.services."podman-scrypted" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    partOf = [
      "podman-compose-scrypted-root.target"
    ];
    wantedBy = [
      "podman-compose-scrypted-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-scrypted-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}