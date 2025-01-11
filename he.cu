#include <cuda.h>
#include <stdio.h>

#define CHECK_CUDA(call) \
do { \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        printf("CUDA error at %s:%d - %s\n", __FILE__, __LINE__, cudaGetErrorString(err)); \
        exit(EXIT_FAILURE); \
    } \
} while (0)

__global__ void printHello()
{
    int index = threadIdx.x + blockIdx.x * blockDim.x; // 计算全局索引
    printf("hello world from GPU by thread:%d\n", index);
}

int main()
{
    cudaSetDevice(0);
    printf("hello, world");
    dim3 grid_dim = {1, 1, 1};
    dim3 block_dim = {4, 1, 1};
    printHello<<<grid_dim, block_dim>>>();
    // CHECK_CUDA(cudaDeviceSynchronize());
    cudaDeviceSynchronize();
    return 0;
}
