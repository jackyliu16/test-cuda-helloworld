{
  description = "A very basic flake";

  # inputs.nixpkgs.url = "github:nixos/nixpkgs/a3f9ad65a0bf298ed5847629a57808b97e6e8077";
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/master";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

  # nixConfig = {
  #   substituters = [
  #     "https://cuda-maintainers.cachix.org"
  #   ];
  #   trusted-public-keys = [
  #     "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  #   ];
  # };

  outputs = { self, nixpkgs, utils, pre-commit-hooks }@flakeArgs: 
    utils.lib.eachDefaultSystem (system: let 
      pkgs = import nixpkgs {
        inherit system;

        overlays = [ ];

        config.allowUnfree = true;
      };
    in {
      devShells.default = import ./shell.nix { inherit pkgs; };
      devShells.fhs = import ./shell.nix { inherit pkgs; };

      devShells.build = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [
          gcc11
          autoAddDriverRunpath
        ] ++ (with pkgs.cudaPackages; [
          cudatoolkit
          cuda_nvcc
          cuda_cudart
        ]);

        # CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
        # LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit}/lib/stubs:${pkgs.cudaPackages.cudatoolkit.lib}/lib:$LD_LIBRARY_PATH";

        # shellHooks = ''
        #   export PATH="${pkgs.gcc11}/bin:${pkgs.cudatoolkit}/bin:${pkgs.cudatoolkit}/nvvm/bin:$PATH"
        #   export CUDA_PATH=${pkgs.cudatoolkit}
        #   export CPATH="${pkgs.cudatoolkit}/include"
        #   export LIBRARY_PATH="$LIBRARY_PATH:/lib"
        #   export CMAKE_CUDA_COMPILER=$CUDA_PATH/bin/nvcc
        #   export CFLAGS="" 
        # '';
      };
    });
}
