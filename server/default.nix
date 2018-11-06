{ nixpkgs ? import <nixpkgs> {} }:
let p = nixpkgs; in

let
  rWrapper = p.rWrapper.override {
    packages = [
      p.rPackages.shiny p.rPackages.jsonlite
      p.rPackages.ggplot2 p.rPackages.plotly
      p.rPackages.shinyWidgets
      p.rPackages.optparse
      p.rPackages.purrr
    ];
  };
in

p.stdenv.mkDerivation {
  name = "benchgraph";
  src = ./.;

  buildInputs = [ rWrapper ];

  buildPhase = ''
    cat <<EOF > benchgraph
    #!/bin/sh

    exec ${rWrapper}/bin/Rscript $out/server.R "\$@"
    EOF
    chmod +x benchgraph
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp benchgraph $out/bin/
    cp server.R $out/
  '';
}
