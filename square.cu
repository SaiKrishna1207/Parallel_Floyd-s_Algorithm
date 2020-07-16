#include<stdio.h>

__global__ void square(float *d_out, float* d_in){
    int idx = threadIdx.x;
    float f = d_in[idx];
    d_out[idx] = f * f * f;
}

int main(int argc, char** argv){
    const int Ar_s = 96;
    const int Ar_b = Ar_s * sizeof(float);
 
    float h_in[Ar_s];
    int i;
    for(i = 0;i < Ar_s; i++)
        h_in[i] = float(i);

    float h_out[Ar_s];

    float *d_in, *d_out;
    cudaMalloc((void **) &d_in, Ar_b);
    cudaMalloc((void **) &d_out, Ar_b);

    cudaMemcpy(d_in, h_in, Ar_b, cudaMemcpyHostToDevice);

    square<<<1, Ar_s>>> (d_out, d_in);

    cudaMemcpy(h_out, d_out, Ar_b, cudaMemcpyDeviceToHost);

    for(i = 0; i < Ar_s; i++){
        printf("%f", h_out[i]);
        if(i%4 != 3)
            printf("\t");
        else
            printf("\n");
    }

    cudaFree(d_in);
    cudaFree(d_out);

    return 0;
}