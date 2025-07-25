{
  pkgs,
  windows-vm,
  ...
}: {
  users.users.aaronp = {
    isNormalUser = true;
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Aaron Power";
    extraGroups = [];
    packages = with pkgs; [
    ];
    openssh = {
      authorizedKeys.keys = [
        # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdDtpJfoDrvCg8OFE57JihGkC37Fujk29fCWiuuj3bwUgvu5Bx+1ln7V0xg554u1mya6lz7uAZtzBNH7D0BUQtZtAr+sc9L7pyMJGhjx/QyRVq452a+P/A7jDA2E+UDA/8acr6DAkBz93/Ia5KoP7Y9YbI7awutZLbgwOeHRqBBV7dy7CWDoCMiFRb8rSqGN/NXl1c6fDz6cnAK3ci9RQEOL9QHcuwm0hhj9Brs/+uxZM+Rqe7kIm6RkSUNfmz0TiLyxUPa/tQLogmgjCKoCZQ8hC79g5d5u5cO4mmoYYh/ig8IFYpyxul2MAIDnzcuSVqarTSvEAEfJ+ZtJMT3PasryfSK5j00ewq5BVRy/7gIDVMF+Lyzvn6S9t5vnspGnfSXsMRqeBuIQiGtFzsMvqArJ+nWK8T5Iw18wzCup33LEW3jA8dtXadjK/0JwKdWY6rC+St3BRYpsp/MIi0V/B3F8OXpoQT3+ZegpveDVL326C7JjUaeRLoBZwBMsGJjxU= aaronpower@MacBook-Pro.lan"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiq6S6RPb9nTROQIFC71uupPe4fY9yvehTppujmQeHj aarongpower@gmail.com"
      ];
    };
  };

  # users.users.syncthing = {
  #   extraGroups = [ "users" ];
  # };
}
