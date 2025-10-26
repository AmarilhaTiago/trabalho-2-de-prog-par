# Multiplicação de Matrizes Paralela com OpenMP

## Descrição do Projeto

Este projeto implementa e compara diferentes abordagens para multiplicação de matrizes usando OpenMP, incluindo:

1. **MatMul** - Implementação sequencial naive (baseline)
2. **MatMulOpenMP** - Paralela naive com particionamento 1D
3. **MatMulCache** - Sequencial com otimização de cache
4. **MatMulCacheOpenMP** - Paralela 1D com otimização de cache
5. **MatMul2D** - Paralela com **particionamento 2D** sem otimização de cache
6. **MatMul2DCache** - Paralela com **particionamento 2D** e otimização de cache

## Características do Particionamento 2D

### O que é Particionamento 2D?

O particionamento 2D divide as matrizes em blocos (tiles) de tamanho fixo (ex: 64x64). Cada thread OpenMP processa blocos inteiros da matriz resultado C, calculando o produto de blocos correspondentes das matrizes A e B.

### Vantagens do Particionamento 2D:

1. **Melhor Localidade de Cache**: Trabalha com blocos menores que cabem melhor no cache L1/L2
2. **Redução de Cache Misses**: Reutiliza dados carregados no cache
3. **Balanceamento de Carga**: Schedule dinâmico distribui blocos entre threads
4. **Escalabilidade**: Funciona bem com muitos cores (8+ processadores)

### Diferenças entre MatMul2D e MatMul2DCache:

- **MatMul2D**: Usa ordem de loops i-j-k dentro de cada bloco
- **MatMul2DCache**: Usa ordem i-k-j para maximizar localidade de cache + vectorização SIMD

## Compilação

### Windows (MinGW/GCC)
```bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

### Linux/Mac
```bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

### Com Intel Compiler (melhor performance)
```bash
icc -qopenmp -O3 -xHost -o ompmultmat ompmultmat.c
```

## Execução

Para testar com diferentes tamanhos de matriz:

```bash
# Matriz 512x512
echo 512 | ./ompmultmat

# Matriz 1024x1024
echo 1024 | ./ompmultmat

# Matriz 2048x2048
echo 2048 | ./ompmultmat
```

### Definir número de threads OpenMP

```bash
# Windows PowerShell
$env:OMP_NUM_THREADS=8
echo 1024 | .\ompmultmat.exe

# Linux/Mac
export OMP_NUM_THREADS=8
echo 1024 | ./ompmultmat
```

## Testes Recomendados

Execute testes com os seguintes tamanhos de matriz:
- 512x512
- 1024x1024
- 2048x2048
- 4096x4096 (se houver memória suficiente)

E com diferentes números de threads:
- 1 thread (para referência)
- 2, 4, 8, 16 threads (para análise de speedup)

## Estrutura dos Resultados

O programa exibe o tempo de execução (em segundos) para cada implementação:

```
Matrix size: 1024  memory used 4.194304 MB
matMul Time 2.450000 s
MatMulOpenMP time 0.320000 s
MatMulCacheOptimized time 0.890000 s
MatMulCacheOptimizedOpenMP time 0.115000 s
MatMul2D (Particionamento 2D sem cache) time 0.095000 s
MatMul2DCache (Particionamento 2D com cache) time 0.062000 s
```

## Análise de Performance Esperada

Para matrizes grandes (1024+) em máquinas com 8+ cores:

1. **MatMul2DCache** deve ser o mais rápido
2. **MatMul2D** deve ser mais rápido que **MatMulCacheOpenMP**
3. Speedup esperado: 15-40x comparado com sequencial

## Ajuste de Parâmetros

O tamanho do bloco (BLOCK_SIZE) nas funções 2D pode ser ajustado:

- **32**: Para processadores com cache L1 pequeno
- **64**: Valor padrão, bom para maioria dos casos
- **128**: Para processadores modernos com cache grande

Edite as linhas 123 e 163 em `ompmultmat.c` para testar diferentes valores.

## Requisitos

- Compilador com suporte a OpenMP (GCC 4.2+, Clang, MSVC, Intel)
- Processador com pelo menos 8 cores (recomendado)
- Memória RAM suficiente para matrizes grandes

## Informações da Máquina

Para o relatório, inclua informações da máquina usada:

```bash
# Windows
systeminfo | findstr /C:"Processor"
echo %NUMBER_OF_PROCESSORS%

# Linux
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
cat /proc/meminfo | grep MemTotal
```

## Autores

[Seu Nome / Grupo]

## Licença

Projeto acadêmico para a disciplina de Programação Paralela.


