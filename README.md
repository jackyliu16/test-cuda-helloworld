
# How to build

> 我有点没搞明白为啥二者的环境变量几乎一致为啥会出现这种情况，可能是我对 buildFHSEnv 的理解不够深入，需要再找一下参数什么的看一下，不过这不是当前主要矛盾所以说还没解决。

```bash
$ nix develop .#build

$ nvcc he.cu
```

# How to run

> 按照现在的情况，我可以在我本地 <nixpkgs> 中使用 CUDA 运行该应用程序
