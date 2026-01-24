{
  description = "takano_y's dotfiles with Nix + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      username = "takano_y";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/default.nix
        ];

        extraSpecialArgs = {
          inherit username;
        };
      };

      # 開発用シェル
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ nil nixfmt ];
      };
    };
}
