#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>

__global__ void innerLoops(int n, int k, long* d_adj) {
    int i = blockIdx.x;
    int j = blockIdx.y;

    __syncthreads();

    long s = d_adj[i*n+k] + d_adj[k*n+j];                //[i][k]  [k][j]
    
    if(s < d_adj[i*n+j])                                 //[i][j]
        d_adj[i*n+j] = s;
}

__global__ void setMax(long* d_adj, int n){
    int x = threadIdx.x;
    int y = threadIdx.y;
    int pos = (x * n) + y;
    if(x == y)
        d_adj[pos] = 0;                                 //Diagonal elements
    else
        d_adj[pos] = __INT_MAX__;                       //Others
}

int main(int argc, char** argv){
    int i, j, k, n;
    printf("Enter the number of vertices : \n");
    scanf("%d", &n);

    long h_adj[n * n];
    long* d_adj;
    cudaMalloc((void**)&d_adj, n * n * sizeof(long*));

    setMax<<<1, dim3(n, n, 1)>>>(d_adj, n); 

    cudaMemcpy(h_adj, d_adj, n * n * sizeof(long), cudaMemcpyDeviceToHost);
    
    cudaFree(d_adj);

    while(1){
        printf("Click 1 to enter edge and 0 to finish.\n");
        scanf("%d", &k);
        if(!k)
            break;
        int s, d, w;
        printf("Enter start and end of edge in 1-ordering : \n");
        scanf("%d %d", &s, &d);
        if(s == d){
            printf("Invalid edge.\n");
            continue;
        }
        if(s > n || s < 1 || d > n || d < 1){
            printf("Invalid edge.\n");
            continue;
        }
        printf("Enter edge weight : \n");
        scanf("%d", &w);
        if(w < 0){
            printf("Invalid edge weight.\n");
            continue;
        }
        int pos = ((s - 1) * n) + (d - 1);
        h_adj[pos] = w;
    }
    
    cudaDeviceSynchronize();

    for(k = 0; k < n; k++){
        innerLoops<<< dim3(1,1,1), dim3(n,n,1) >>>(n,k,d_adj);
    }

    for(i = 0;i < n; i++){
        for(j = 0;j < n; j++){
            int pos = (i * n) + j;    
            printf("%ld ", h_adj[pos]);
        }
        printf("\n");
    }

    return 0;
}