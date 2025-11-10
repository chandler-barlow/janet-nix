{ pkgs, janetPackages }:
# jpm.mkJpmPackage {
#   name = "test";
#   src = ./.;
#   jpmDeps = jpm.fetchJpmDeps {
#     src = ./.;
#     hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
#   };
# }

# let 
#     deps = janetPackages.fetchJpmDeps {
#         hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
#     };
# in
#     janetPackages.mkJpmPackage {
#         name = "test-app";
#         jpmDeps = deps;
#     }

janetPackages.fetchJpmDeps {
    # hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
    src = ./.;
}
