{pkgs, ...}: {
  security = {
    sudo.extraRules = [
      {
        users = ["terraform"];
        commands = [
          "/sbin/pvesm"
          "/sbin/qm"
          "/usr/bin/tee /var/lib/vz/*"
        ];
      }
      # Allow aaron to run nix and nixos-rebuild without entering sudo password
      {
        users = ["aaronp"];
        commands = [
          "/run/current-system/sw/bin/nix"
          "/run/current-system/sw/bin/nixos-rebuild"
        ];
      }
    ];
    # Allow aaron to run work vm without entering sudo password
    # sudo.extraConfig = ''
    #   aaronp ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/quickemu --vm ./windows-11.conf *
    # '';

    # Specify the capabilities for the QEMU binary
    # wrappers.qemu-system-x86_64 = {
    #   source = "${pkgs.qemu}/bin/qemu-system-x86_64";
    #   owner = "root";
    #   group = "root";
    #   permissions = "u+rx,g+rx";
    #   capabilities = "cap_net_admin+ep";
    # };

    # polkit.enable = true;

    # rtkit.enable = true;

    # Required to get swaylock to work
    # pam.services.swaylock = {};
  };
}
