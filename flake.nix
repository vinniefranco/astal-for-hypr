{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      astal,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        app_launcher = astal.lib.mkLuaPackage {
          inherit pkgs;
          name = "astal-launcher";
          src = ./apps;

          extraPackages = [
            astal.packages.${system}.apps
            pkgs.dart-sass
          ];
        };

        default = astal.lib.mkLuaPackage {
          inherit pkgs;
          name = "astal-bar";
          src = ./bar;

          extraPackages = [
            astal.packages.${system}.apps
            astal.packages.${system}.battery
            astal.packages.${system}.hyprland
            astal.packages.${system}.network
            astal.packages.${system}.tray
            astal.packages.${system}.wireplumber
            pkgs.dart-sass
          ];
        };
      };
    };
}
