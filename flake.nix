{
  description = "Tobil the NixOS installer";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };

  outputs = {self, nixpkgs, ... }@inputs: let
    system    = "x86_64-linux";
    pkgs      = import nixpkgs { inherit system; };

    pbkdf2-sha512 = pkgs.callPackage ./pbkdf2-sha512 { };

    rbtohex = pkgs.writeShellScriptBin
      "rbtohex"
      (builtins.readFile ./scripts/rbtohex.sh);

    hextorb = pkgs.writeShellScriptBin
      "hextorb"
      (builtins.readFile ./scripts/hextorb.sh);

    yk-luks-gen = pkgs.writeShellScriptBin
      "yk-luks-gen"
      (builtins.readFile ./scripts/yk-luks-gen.sh);

  in {
    devShells.${system}.run-installer = pkgs.mkShell {
      packages = with pkgs; [
        disko
        cryptsetup
        openssl
        parted
        yubikey-personalization
        pbkdf2-sha512
        rbtohex
        hextorb
        yk-luks-gen
      ];
      shellHook = ''
        echo "Tobil NixOS Installer"
      '';
    };
  };
}
