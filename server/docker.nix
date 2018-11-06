{ nixpkgs ? import ../nixpkgs.nix {} }:

let
  p = nixpkgs;
  benchgraph = import ./default.nix { inherit nixpkgs; };
  tmpDir = p.writeTextFile {
    name = "tmpdir";
    destination = "/tmp/.touch";
    text = "";
  };
in

p.dockerTools.buildLayeredImage {
  name = "benchgraph";
  contents = tmpDir;

  config = {
    Cmd = [ "${benchgraph}/bin/benchgraph" "/benchs" ];
  };
}
