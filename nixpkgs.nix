let
  # The nixpkgs revision used.
  nixpkgsRev = "179b8146e668636fe59ef7663a6c8cd15d00db7e";
  # The hash of the downloaded nixpkgs.
  # Don't forget to update it when changing the revision, you can get it with
  # nix-prefetch-url --unpack https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz
  nixpkgsSha256 = "0fjab831i12lsnizvviz9f7k6dmi2gpvkysawc8r6nv0naa2q5fh";

  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz";
    sha256 = nixpkgsSha256;
  };
in
  args@{ overlays ? [], ... }:
  let
    # Add our custom overlay to the upstream nixpkgs.
    # This allows us to override some packages and add our own
    extendedArgs = args // {
      inherit overlays;
    };
  in
  import nixpkgs extendedArgs

