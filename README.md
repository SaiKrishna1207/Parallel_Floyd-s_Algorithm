# Parallel_Floyd-s_Algorithm
This project aims to parallelize the Floyd's algorithm, using NVIDIA's CUDA C.

Floyd's Algorithm is used to find shortest path distances between every pair in the given graph, using Dynamic Programming. For any 2 points, the key computation in the algorithm finds the minimum of the current path cost between the 2 vertices and the cost of the path with a 3rd vertex as an intermediate state in the path.

So, for every pair (i, j), where i is the source vertex and j is the destination vertex, the kernel calculates : **min (dp[i][j], dp[i][k] + dp[k][j])**, 
where k is the intermediate vertex through which the path is traversed. Since this has to be done for all **n** vertices, and it takes **O(n^2)** time to traverse the edges, the overall step complexity of the serial algorithm is **O(n^3)**.

By using CUDA, the GPU is involved and hence this step complexity is brought down approximately to **O(n)** as each thread performs the computation for 1 edge. To avoid collisions in accesses and better synchronization, the performance takes a slight hit as the threads wait after the read and perform the write only after all the reads are done.

The speedup achieved was as follows : 

## Contributors :

(1) Sai Krishna Anand : https://github.com/SaiKrishna1207/

(2) Dhanwin Rao : https://github.com/Dhanwin247/
