{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;
  inherit (pkgs.lib) inNixShell;

  f = import ./default.nix;

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  yuicompressor = pkgs.writeScriptBin "yuicompressor" ''
    #!${pkgs.stdenv.shell}
    exec java -jar ${pkgs.yuicompressor}/lib/yuicompressor.jar "$@"
  '';

  drv = pkgs.haskell.lib.addBuildTools (haskellPackages.callPackage f {})
    [ pkgs.nodePackages.bower yuicompressor
      haskellPackages.cabal-install haskellPackages.hlint ];

in

  if pkgs.lib.inNixShell then drv.env else drv
