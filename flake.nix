{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, astal }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = astal.lib.mkLuaPackage {
        inherit pkgs;
        name = "ags-bar";
        src = ./bar;

        extraPackages = [
          astal.packages.${system}.battery
          astal.packages.${system}.hyprland
          astal.packages.${system}.network
          astal.packages.${system}.tray
          astal.packages.${system}.wireplumber
          pkgs.dart-sass
        ];
      };
    };
}
