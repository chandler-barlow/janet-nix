{ pkgs, mkJanet }:
mkJanet {
    name = "minimal";
    src = ./.;   
}
