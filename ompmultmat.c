#include <stdio.h>
#include <stdlib.h>
#include <time.h>
# include <omp.h>


void fill_n(int *m, int n , int val){

  for(int i=0; i<n; i++)
    m[i]=val;
}

void Parfill_n(int *m, int n , int val){
  #pragma omp for nowait
  for(int i=0; i<n; i++)
    m[i]=val;
}
   
  
int pos(int *m, int i, int j, int cols){
  // Row major
  return m[i*cols + j];
}

 int areMatricesEqual(int *a, int *b, int n, int m){
  
  for (int i = 0; i < n; i++)  {
    for (int j = 0; j < m; j++){
      if (pos(a, i, j, m) != pos(b, i, j, m))
            return 0;
    }          
  }
  return 1;
}
  
int *allocate(int rows, int cols){
  
  return (int *) malloc(rows*cols*sizeof(int));
}


// naive implementation C = A*B

void MatMul(int* c, int* a, int* b, int n, int m, int p) {

  fill_n(c, n * p, 0);

  for (int i = 0; i < n; i++){
    
    for (int j = 0; j < p; j++){
      
      for (int k = 0; k < m; k++){
	c[i*p + j] += pos(a, i, k, m) * pos(b, k, j, p);
      }
    }
  }
}

// OpemMP naive implementation C = A*B

void MatMulOpenMP(int *c, int * a, int * b, int n, int m, int p ){
  #pragma omp parallel
  {
  Parfill_n(c, n * p, 0);

  #pragma omp  for collapse(2)
  for (int i = 0; i < n; i++)  {
    for (int j = 0; j < p ; j++){
      int result = 0;
      
      #pragma omp simd reduction(+:result)
      for (int  k = 0; k < m ; k++) {
	result += pos(a, i, k, m) * pos(b, k, j, p);
      }       
      c[i*p + j] = result;
    }
  }
  }
}

// Cached implementation C = A*B

void MatMulCache(int* c, int* a, int* b, int n, int m, int p) {

  fill_n(c, n  * p, 0);

  for (int i = 0; i < n; i++){
    
    for (int k = 0; k <  m; k++){
      
      for (int j = 0; j < p; j++){
	c[i*p + j] += pos(a, i, k, m) * pos(b, k, j, p);
      }
    }
  }
}


// Cached OpenMp implementation C = A*B

void MatMulCacheOpenMP(int* c, int* a, int* b, int n, int m, int p) {

  #pragma omp parallel
  {
  Parfill_n(c, n * p, 0);
  
  #pragma omp  for
  for (int i = 0; i < n; i++){  
    for (int k = 0; k <  m; k++){
      for (int j = 0; j < p; j++){
	c[i*p + j] += pos(a, i, k, m) * pos(b, k, j, p);
      }
    }
  }
  }
}


// 2D Partitioning OpenMP implementation C = A*B (sem cache)
// Divide as matrizes em blocos (tiles) para melhor localidade e paralelismo

void MatMul2D(int* c, int* a, int* b, int n, int m, int p) {
  int BLOCK_SIZE = 64; // Tamanho do bloco/tile - ajustável conforme cache
  
  #pragma omp parallel
  {
  Parfill_n(c, n * p, 0);
  
  // Paraleliza sobre os blocos da matriz C
  #pragma omp for collapse(2) schedule(dynamic)
  for (int ii = 0; ii < n; ii += BLOCK_SIZE) {
    for (int jj = 0; jj < p; jj += BLOCK_SIZE) {
      // Para cada bloco de C, itera sobre os blocos de A e B
      for (int kk = 0; kk < m; kk += BLOCK_SIZE) {
        
        // Calcula os limites dos blocos
        int i_end = (ii + BLOCK_SIZE < n) ? ii + BLOCK_SIZE : n;
        int j_end = (jj + BLOCK_SIZE < p) ? jj + BLOCK_SIZE : p;
        int k_end = (kk + BLOCK_SIZE < m) ? kk + BLOCK_SIZE : m;
        
        // Multiplica os blocos (ordem i-j-k, sem otimização de cache)
        for (int i = ii; i < i_end; i++) {
          for (int j = jj; j < j_end; j++) {
            int result = 0;
            #pragma omp simd reduction(+:result)
            for (int k = kk; k < k_end; k++) {
              result += pos(a, i, k, m) * pos(b, k, j, p);
            }
            c[i*p + j] += result;
          }
        }
      }
    }
  }
  }
}


// 2D Partitioning OpenMP implementation with Cache Optimization C = A*B
// Combina particionamento 2D com otimização de cache (troca ordem dos loops)

void MatMul2DCache(int* c, int* a, int* b, int n, int m, int p) {
  int BLOCK_SIZE = 64; // Tamanho do bloco/tile - ajustável conforme cache
  
  #pragma omp parallel
  {
  Parfill_n(c, n * p, 0);
  
  // Paraleliza sobre os blocos da matriz C
  #pragma omp for collapse(2) schedule(dynamic)
  for (int ii = 0; ii < n; ii += BLOCK_SIZE) {
    for (int jj = 0; jj < p; jj += BLOCK_SIZE) {
      // Para cada bloco de C, itera sobre os blocos de A e B
      for (int kk = 0; kk < m; kk += BLOCK_SIZE) {
        
        // Calcula os limites dos blocos
        int i_end = (ii + BLOCK_SIZE < n) ? ii + BLOCK_SIZE : n;
        int j_end = (jj + BLOCK_SIZE < p) ? jj + BLOCK_SIZE : p;
        int k_end = (kk + BLOCK_SIZE < m) ? kk + BLOCK_SIZE : m;
        
        // Multiplica os blocos (ordem i-k-j, otimizado para cache)
        for (int i = ii; i < i_end; i++) {
          for (int k = kk; k < k_end; k++) {
            int a_elem = pos(a, i, k, m);
            #pragma omp simd
            for (int j = jj; j < j_end; j++) {
              c[i*p + j] += a_elem * pos(b, k, j, p);
            }
          }
        }
      }
    }
  }
  }
}


int main(void) {
  int N = 32; // 64, 1024, 2048
  int *a, *b, *c, *r;
  double ts;

  scanf("%d", &N);
  
  printf("Matrix size: %d  memory used %f MB \n", N, N * N * sizeof(int) / 1e6);
  
  
  
  a = allocate(N, N);
  b = allocate(N, N);
  c = allocate(N, N);
  r = allocate(N, N);

  // init Matrices  
  for (int i = 0; i < N*N; i++) {
    a[i] = i + 1;
    b[i] = 2*i + 1;
  }

  ts = omp_get_wtime();
  MatMul(r, a, b, N, N, N );
  printf("matMul Time %f s\n",  omp_get_wtime() - ts );

  ts = omp_get_wtime();
  MatMulOpenMP(c, a, b, N, N, N);
  if (areMatricesEqual(c, r, N, N))
    printf("MatMulOpenMP time %f s\n", omp_get_wtime() - ts );
  

  ts=omp_get_wtime();
  MatMulCache(c, a, b, N, N, N);
  if (areMatricesEqual(c, r, N, N)){
   printf("MatMulCacheOptimized time %f s\n",  omp_get_wtime() - ts );
  }

  ts=omp_get_wtime();
  MatMulCacheOpenMP(c, a, b, N, N, N);
  if (areMatricesEqual(c, r, N, N)){
    printf("MatMulCacheOptimizedOpenMP time %f s\n", omp_get_wtime() - ts );
  }

  ts=omp_get_wtime();
  MatMul2D(c, a, b, N, N, N);
  if (areMatricesEqual(c, r, N, N)){
    printf("MatMul2D (Particionamento 2D sem cache) time %f s\n", omp_get_wtime() - ts );
  }

  ts=omp_get_wtime();
  MatMul2DCache(c, a, b, N, N, N);
  if (areMatricesEqual(c, r, N, N)){
    printf("MatMul2DCache (Particionamento 2D com cache) time %f s\n", omp_get_wtime() - ts );
  }
    
  free(a);
  free(b);
  free(c);
  free(r);

  return 0;
}

