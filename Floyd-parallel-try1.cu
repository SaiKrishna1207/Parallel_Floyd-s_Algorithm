#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include<cuda.h>

__global__ void innerLoops(int n, int k, long** d_adj) {
    int i=blockIdx.x;
    int j=blockIdx.y;
    
    long t1=*(*(d_adj+i)+k);
    long t2=*(*(d_adj+i)+j);
    long s = t1+t2;
    __syncthreads();

    long t3=*(*(d_adj+i)+j);
    if(s < t3)
        *(*(d_adj+i)+j) = s;
}

int main(){
    int i, j, k, n;
    printf("Enter the number of vertices : \n");
    scanf("%d", &n);
    long h_adj[n][n];
    for(i = 0;i < n; i++){
        for(j = 0;j < n; j++)
            h_adj[i][j] = __INT_MAX__;
    }
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
        h_adj[s - 1][d - 1] = w;
    }
    for(i = 0; i < n; i++)
        h_adj[i][i] = 0;
    
    long** d_adj;
    cudaMalloc((void**) &d_adj, n*sizeof(long*));
    for(int i=0; i<n; i++){
        cudaMalloc(&d_adj[i], n*sizeof(long)); 
    }
    cudaMemcpy(d_adj, h_adj, n*sizeof(long*), cudaMemcpyHostToDevice);



    cudaDeviceSynchronize();

    for(k = 0; k < n; k++){
        innerLoops<<< dim3(1,1,1), dim3(n,n,1) >>>(n,k,d_adj);
    }

    cudaMemcpy(h_adj,d_adj,n*n,cudaMemcpyDeviceToHost);

    for(i = 0;i < n; i++){
        for(j = 0;j < n; j++)
            printf("%ld ", h_adj[i][j]);
        printf("\n");
    }

    cudaFree(d_adj);

    return 0;
}