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
  virtualisation.oci-containers.containers."actual-actual_server" = {
    image = "docker.io/actualbudget/actual-server:latest";
    volumes = [
      "/tank/containers/actual/data:/data:rw"
    ];
    ports = [
      "5006:5006/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=actual_server"
      "--network=actual_default"
    ];
  };
  systemd.services."podman-actual-actual_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-actual_default.service"
    ];
    requires = [
      "podman-network-actual_default.service"
    ];
    partOf = [
      "podman-compose-actual-root.target"
    ];
    wantedBy = [
      "podman-compose-actual-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-actual_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f actual_default";
    };
    script = ''
      podman network inspect actual_default || podman network create actual_default
    '';
    partOf = [ "podman-compose-actual-root.target" ];
    wantedBy = [ "podman-compose-actual-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-actual-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
