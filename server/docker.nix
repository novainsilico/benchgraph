{ nixpkgs ? import ../nixpkgs.nix {} }:

let
  p = nixpkgs;
  benchgraph = import ./default.nix { inherit nixpkgs; };
in

p.dockerTools.buildImage {
  name = "benchgraph";
  contents = benchgraph;

  runAsRoot = ''
    mkdir -p /tmp
  '';

  config = {
    Cmd = [ "/bin/benchgraph" ];
  };
}
