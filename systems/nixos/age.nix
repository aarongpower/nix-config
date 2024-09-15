{ flakeRoot, ... }:

{
  age = {
     identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets.cloudflare-tunnel-key = {
      file = "${flakeRoot}/secrets/cloudflare-tunnel-key.age";
      owner = "cloudflared";
      group = "cloudflared";
    };
  };
}