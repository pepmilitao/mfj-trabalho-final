{
  description = "Rust raylib development Shell";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, system, ... }:
        let
          inherit (inputs.fenix.packages.${system}.stable) toolchain rust-src;
          libs = with pkgs; [
            llvmPackages.libclang

            glfw3
            ## glfw
            libGL
            libx11
            libxcursor
            libxext
            libxrandr
            libxxf86vm
            wayland
            libdecor
            libxkbcommon
            libxinerama
            libxi

            ## openal
            alsa-lib
            libjack2
            libpulseaudio
            pipewire
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs =
              with pkgs;
              [
                toolchain
                rust-src
                stdenv.cc
                cmake
                pkg-config
                patchelf
                clang
              ]
              ++ libs;
            env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            env.RUST_SRC_PATH = "${rust-src}/lib/rustlib/src/rust/library";
            env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
          };
        };
    };
}
