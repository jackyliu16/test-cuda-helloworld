
# How to build

> 我有点没搞明白为啥二者的环境变量几乎一致为啥会出现这种情况，可能是我对 buildFHSEnv 的理解不够深入，需要再找一下参数什么的看一下，不过这不是当前主要矛盾所以说还没解决。

FIXME: 没有办法在 F H S 环境下正常编译环境，可能需要进一步分析缘由

```bash
$ nix develop .#build

$ nvcc he.cu

# ERROR MESSAGE
$ nix develop .#fhs

[nix-shell]$ nvcc he.cu 
/nix/store/bwkb907myixfzzykp21m9iczkhrq5pfy-binutils-2.43.1/bin/ld: 找不到 -lcudadevrt: No such file or directory
/nix/store/bwkb907myixfzzykp21m9iczkhrq5pfy-binutils-2.43.1/bin/ld: 找不到 -lcudart_static: No such file or directory
collect2: 错误：ld 返回 1
```

# How to run

> 应该可以按照下面的方式成功运行程序

```bash
$ nix develop .#fhs OR nix-shell OR nix develop .#build

[nix-shell]$ ./a.out 
hello, worldhello world from GPU by thread:0
hello world from GPU by thread:1
hello world from GPU by thread:2
hello world from GPU by thread:3
```

## 无法从 build devShell 运行应用程序的简单分析

1. 根据 cat /etc/ld.so.conf 链接文件中所指示的信息，发现在 F H S 环境下可以正常看到对应 /run/opengl-driver/ 的环境变量，同时可以在 LD_DEBUG=libs 运行二进制程序的日志信息中检视到对应 libcuda.so.1 动态库文件是从 /etc/ld.so.conf 文件中间接获取的。

> 下文中所指 ld.so.cache 是由 ldconfig 工具生成的。该工具会通过扫描一系列库文件，如 /lib, /usr/lib, /etc/ld.so.conf, /etc/ld.so.conf.d/ 指定的目录，并且将对应的信息缓存到 /etc/ld.so.cache 中。

```
   2046441:	find library=libcuda.so.1 [0]; searching
   2046441:	 search path=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib		(system search path)
   2046441:	  trying file=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1
   2046441:	 search path=/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib		(RUNPATH from file ./a.out)
   2046441:	  trying file=/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib/libcuda.so.1
   2046441:	 search cache=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/etc/ld.so.cache
   2046441:	  trying file=/run/opengl-driver/lib/libcuda.so.1
   2046441:	
   2046441:	
   2046441:	calling init: /run/opengl-driver/lib/libcuda.so.1
```

2. 获取到 FHS 环境下的这些因素，在 nix develop .#build 中根据 nix 的修改，甚至没有提供对应到 /etc/ld.so.chache 文件让我们对比，只可以通过 LD_DEBUG 日志文件的分析得到当前确实没有找到 libcuda 动态库（找了所有相关的位置没有找到之后 calling fini 开始退出加载）。

```
   2044196:	find library=libcuda.so.1 [0]; searching
   2044196:	 search path=/run/opengl-driver:$LD_LIBRARY_PATH/glibc-hwcaps/x86-64-v3:$LD_LIBRARY_PATH/glibc-hwcaps/x86-64-v2:$LD_LIBRARY_PATH		(LD_LIBRARY_PATH)
   2044196:	  trying file=/run/opengl-driver/libcuda.so.1
   2044196:	  trying file=$LD_LIBRARY_PATH/glibc-hwcaps/x86-64-v3/libcuda.so.1
   2044196:	  trying file=$LD_LIBRARY_PATH/glibc-hwcaps/x86-64-v2/libcuda.so.1
   2044196:	  trying file=$LD_LIBRARY_PATH/libcuda.so.1
   2044196:	 search path=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib		(system search path)
   2044196:	  trying file=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1
   2044196:	 search path=/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib		(RUNPATH from file ./a.out)
   2044196:	  trying file=/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib/libcuda.so.1
   2044196:	 search cache=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/etc/ld.so.cache
   2044196:	 search path=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib:/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v3:/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v2:/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib		(system search path)
   2044196:	  trying file=/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1
   2044196:	  trying file=/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v3/libcuda.so.1
   2044196:	  trying file=/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v2/libcuda.so.1
   2044196:	  trying file=/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/libcuda.so.1
   2044196:	
   2044196:	
   2044196:	calling fini:  [0]
```

### 一些佐证信息

1. FHS

```
openat(AT_FDCWD, "/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=16295, ...}) = 0
mmap(NULL, 16295, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ffff7e9f000
close(3)                                = 0
openat(AT_FDCWD, "/run/opengl-driver/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = 3
```

2. build

```
openat(AT_FDCWD, "/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/16gwxzrvk51x2bhrp25s78fkn5j5k1nl-gcc-11.5.0-lib/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/wn7v2vhyyyi6clcyn0s9ixvl7d4d87ic-glibc-2.40-36/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v3/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v3/", 0x7fffffff26f0, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v2/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/glibc-hwcaps/x86-64-v2/", 0x7fffffff26f0, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/2d5spnl8j5r4n1s4bj1zmra7mwx0f1n8-xgcc-13.3.0-libgcc/lib/libcuda.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
```
