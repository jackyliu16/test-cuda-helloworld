# Run with `nix-shell cuda-fhs.nix`
{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
  sha256 = "sha256:10i7fllqjzq171afzhdf2d9r1pk9irvmq5n55h92rc47vlaabvr4";
}) { }}:
# { pkgs ? import (builtins.fetchTarball {
#   url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
#   sha256 = "sha256:0bd0mf9ai0gn3lz0arbmj6zrf7r505la46z86v2nj84a1161v1lw";
# }) { }}:
# { pkgs ? import <nixpkgs> { }}:
(pkgs.buildFHSEnv {
  name = "cuda-env";
  targetPkgs = pkgs: with pkgs; [ 
    # addOpenGLRunpath
    # git gitRepo gnupg autoconf curl procps gnumake util-linux m4 gperf unzip

    gcc11
    autoAddDriverRunpath
    cudatoolkit
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart

    # linuxPackages.nvidia_x11
    # libGLU libGL
    # xorg.libXi xorg.libXmu freeglut
    # xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
    # ncurses5
    # stdenv.cc
    # binutils
  ];
  # multiPkgs = pkgs: with pkgs; [ zlib ];
  runScript = "bash";

  # PATH = "${pkgs.gcc11}/bin:${pkgs.cudatoolkit}/bin:${pkgs.cudatoolkit}/nvvm/bin:$PATH";
  # # LD_LIBRARY_PATH = "/run/opengl-driver";
  # LIBRARY_PATH = "$LIBRARY_PATH:/lib";
  # LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit}/lib/stubs:${pkgs.cudaPackages.lib}/lib:${pkgs.cudatoolkit}/lib64:$LD_LIBRARY_PATH:/lib";
  # CPATH="${pkgs.cudatoolkit}/include";
  # CMAKE_CUDA_COMPILER="$CUDA_PATH/bin/nvcc";
  # CFLAGS="";


  profile = ''
    export CUDA_PATH="${pkgs.cudatoolkit}";
    export LIBRARY_PATH="${pkgs.cudatoolkit}/lib:$LIBRARY_PATH";
    export LD_LIBRARY_PATH="${pkgs.cudatoolkit}/lib:$LD_LIBRARY_PATH";
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH";
    export PATH=/nix/store/53ww4g3wf0y5vxwmypw04q1a0h83qjfd-cuda-merged-12.4/bin:$PATH
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
    export EXTRA_CCFLAGS="-I/usr/include"
    export NIX_LDFLAGS="-L${pkgs.cudatoolkit}/lib:$NIX_LDFLAGS"
  '';

}).env
    # export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
    # export EXTRA_CCFLAGS="-I/usr/include"
