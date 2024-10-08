# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "tun" "i915" ];
  boot.extraModulePackages = [ ];
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", MODE="0660", GROUP="vfio"
  ''; # Give members of the vfio group access to vfio devices

  # Add support for NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b385c790-4c76-4887-8142-de3863fde9a8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4C2D-CEF3";
      fsType = "vfat";
    };
  
  fileSystems."/mnt/bigboy" =
    { device = "/dev/sda2";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=1000" "gid=1001" "umask=002" ]; # gid=1000 is the group id of bigboyntfs group
    };

  

  swapDevices = [ ];

  ##
  ## Setting up NVIDIA drivers and OpenGL
  ##

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl = {
      enable = true;
      # driSupport = true;
      driSupport32Bit = true;
    };
    # pulseaudio = {
    #   enable = true;
    #   package = pkgs.pulseaudioFull;
    # };
  };

  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };

  # # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["i915"];

  # hardware.nvidia = {

  #   # Modesetting is required.
  #   modesetting.enable = true;

  #   # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #   powerManagement.enable = false;
  #   # Fine-grained power management. Turns off GPU when not in use.
  #   # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #   powerManagement.finegrained = false;

  #   # Use the NVidia open source kernel module (not to be confused with the
  #   # independent third-party "nouveau" open source driver).
  #   # Support is limited to the Turing and later architectures. Full list of 
  #   # supported GPUs is at: 
  #   # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
  #   # Only available from driver 515.43.04+
  #   # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #   open = false;

  #   # Enable the Nvidia settings menu,
	 # # accessible via `nvidia-settings`.
  #   nvidiaSettings = true;

  # #   # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;

  #   # Force full composition pipeline to reduce flickering
  #   forceFullCompositionPipeline = true;
  # };

  # Temporary fix for flickering and frame sync issues with Nvidia drivers on Wayland
  # https://wiki.hyprland.org/hyprland-wiki/pages/Nvidia/#fixing-random-flickering-nuclear-method
  # https://chat.openai.com/share/a71a0d60-fb0e-4be7-8443-8b443f9ee73c
  # boot.extraModprobeConfig = ''
  #   options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
  # '';

  # Setting up IOMMU
  # This is required for PCI passthrough
  # Will be using the NVIDIA GTX 970 for PCI passthrough with the Windows VM
  # boot.kernelParams = [ 
  #   "intel_iommu=on" 
  #   "iommu=pt"
  #   "pcie_acs_override=downstream,multifunction" # Required for PCI passthrough
  #   "vfio-pci.ids=10de:13c2,10de:0fbb" # NVIDIA 970 assigned to vfio so it can be accessed by the VM, both the audo and graphics devices
  # ];
  boot.kernelParams = [ 
    "intel_iommu=on" 
    "iommu=pt"
    "pcie_acs_override=downstream,multifunction" # Required for PCI passthrough
    # "vfio-pci.ids=8086:9bc5,10de:13c2,10de:0fbb"  # assign intel integrated and nvidia GTX970 for passthrough
    "vfio-pci.ids=10de:13c2,10de:0fbb,10de:2206,10de:1aef" # assigning all nvidia cards to passthrough, will use intel integrated for linux desktop
    # "vfio-pci.ids=10de:13c2,10de:0fbb"
    "isolcpus=8,9,10,11,12,13,14,15"
  ];
  # boot.blacklistedKernelModules = [ "i915" ];  # Blacklist Intel GPU driver
  # boot.blacklistedKernelModules = [ "i915" ];  # Blacklist Intel GPU driver so it can be assigned to vfio
  security.pam.loginLimits = [ # these settings required so that vfio can lock enough memory for GPU passthrough
    { domain = "@users"; type = "hard"; item = "memlock"; value = "unlimited"; }
    { domain = "@users"; type = "soft"; item = "memlock"; value = "unlimited"; }
  ];
  # Required to allow looking glass to work properly
  environment.etc."tmpfiles.d/10-looking-glass.conf".text = ''
    #Type Path               Mode  UID           GID  Age Argument
    f     /dev/shm/looking-glass 0660 aaronp kvm -
  '';

}
