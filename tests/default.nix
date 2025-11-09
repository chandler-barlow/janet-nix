{ pkgs, janetPackages }:
# jpm.mkJpmPackage {
#   name = "test";
#   src = ./.;
#   jpmDeps = jpm.fetchJpmDeps {
#     src = ./.;
#     hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
#   };
# }
janetPackages.fetchJpmDeps {
    src = ./.;
    hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
}
