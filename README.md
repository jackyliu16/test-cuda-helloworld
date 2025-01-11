
# How to build

> 我有点没搞明白为啥二者的环境变量几乎一致为啥会出现这种情况，可能是我对 buildFHSEnv 的理解不够深入，需要再找一下参数什么的看一下，不过这不是当前主要矛盾所以说还没解决。

```bash
$ nix develop .#build

$ nvcc he.cu
```

# How to run

> 应该可以按照下面的方式成功运行程序

```bash
$ nix develop .#fhs OR nix-shell

[nix-shell]$ ./a.out 
hello, worldhello world from GPU by thread:0
hello world from GPU by thread:1
hello world from GPU by thread:2
hello world from GPU by thread:3
```
