{ pkgs, ... }:

let
  juno = pkgs.callPackage ./juno {};
in
{
  gtk = {
    enable = true;
    theme = {
      name = "Juno-ocean";
      package = juno;
    };
  };
}
