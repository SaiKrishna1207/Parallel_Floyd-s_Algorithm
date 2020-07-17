#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>

int main(){
    int i, j, k, n;
    printf("Enter the number of vertices : \n");
    scanf("%d", &n);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    long adj[n][n];
    for(i = 0;i < n; i++){
        for(j = 0;j < n; j++)
            adj[i][j] = __INT_MAX__;
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
        adj[s - 1][d - 1] = w;
    }
    for(i = 0; i < n; i++)
        adj[i][i] = 0;

    cudaDeviceSynchronize();    
    cudaEventRecord(start);

    for(k = 0; k < n; k++){
        for(i = 0; i < n; i++){
            for(j = 0;j < n; j++){
                long s = (long)adj[i][k] + (long)adj[k][j];
                if(s < adj[i][j])
                    adj[i][j] = s;
            }
        }
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    for(i = 0;i < n; i++){
        for(j = 0;j < n; j++)
            printf("%ld ", adj[i][j]);
        printf("\n");
    }
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("%f ms\n",milliseconds) ;

    return 0;
}