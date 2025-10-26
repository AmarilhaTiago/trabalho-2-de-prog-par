# Relatório: Multiplicação de Matrizes Paralela com OpenMP
## Particionamento 2D

---

### Disciplina: Programação Paralela
### Aluno(s): [SEU NOME AQUI]
### Data: [DATA]

---

## 1. Introdução

Este relatório apresenta a implementação e análise de desempenho de algoritmos paralelos para multiplicação de matrizes utilizando OpenMP, com foco no particionamento 2D.

A multiplicação de matrizes é uma operação fundamental em computação científica, aprendizado de máquina e processamento de imagens. Para matrizes grandes, abordagens paralelas são essenciais para obter desempenho adequado.

## 2. Objetivos

- Implementar multiplicação de matrizes com particionamento 2D usando OpenMP
- Comparar desempenho com implementações sequenciais e paralelas 1D
- Analisar o speedup obtido em diferentes tamanhos de matrizes
- Avaliar o impacto da otimização de cache no particionamento 2D

## 3. Metodologia

### 3.1 Implementações Avaliadas

Foram implementadas e comparadas 6 versões do algoritmo:

1. **MatMul (Sequencial Naive)**
   - Implementação básica sequencial
   - Ordem de loops: i-j-k
   - Baseline para comparação

2. **MatMulOpenMP (Paralela 1D Naive)**
   - Paralelização simples com `#pragma omp for collapse(2)`
   - Distribui linhas da matriz C entre threads
   - Sem otimização de cache

3. **MatMulCache (Sequencial com Cache)**
   - Ordem de loops otimizada: i-k-j
   - Melhor localidade de cache
   - Sequencial

4. **MatMulCacheOpenMP (Paralela 1D com Cache)**
   - Combina paralelização 1D com otimização de cache
   - `#pragma omp for` no loop externo (i)
   - Ordem i-k-j

5. **MatMul2D (Paralela 2D sem Cache)** ⭐ NOVA
   - Particionamento em blocos (tiles) de 64x64
   - `#pragma omp for collapse(2)` nos loops de blocos
   - Schedule dinâmico para balanceamento de carga
   - Ordem de loops dentro do bloco: i-j-k

6. **MatMul2DCache (Paralela 2D com Cache)** ⭐ NOVA
   - Particionamento em blocos de 64x64
   - Ordem de loops otimizada dentro do bloco: i-k-j
   - Vetorização SIMD com `#pragma omp simd`
   - Melhor localidade de cache e paralelismo

### 3.2 Particionamento 2D - Conceito

O particionamento 2D divide as matrizes em blocos (tiles) de tamanho fixo. Para multiplicar C = A × B:

```
Para cada bloco (ii, jj) de C:
    Para cada bloco kk intermediário:
        Multiplicar bloco de A[ii,kk] por bloco de B[kk,jj]
        Acumular no bloco C[ii,jj]
```

**Vantagens:**
- Blocos menores cabem melhor no cache L1/L2
- Reduz cache misses
- Maior reutilização de dados
- Melhor balanceamento de carga com schedule dinâmico

### 3.3 Máquina Utilizada

**Especificações do Sistema:**
- **Processador:** [INSERIR PROCESSADOR - ex: Intel Core i7-9700K]
- **Cores Físicos:** [INSERIR - ex: 8]
- **Threads (Cores Lógicos):** [INSERIR - ex: 8]
- **Memória RAM:** [INSERIR - ex: 16 GB]
- **Cache L1:** [INSERIR - ex: 32 KB por core]
- **Cache L2:** [INSERIR - ex: 256 KB por core]
- **Cache L3:** [INSERIR - ex: 12 MB compartilhado]
- **Sistema Operacional:** [INSERIR - ex: Windows 10 / Ubuntu 22.04]
- **Compilador:** [INSERIR - ex: GCC 11.2.0]
- **Flags de Compilação:** `-fopenmp -O3 -march=native`

### 3.4 Parâmetros de Teste

- **Tamanhos de Matriz:** 512×512, 1024×1024, 2048×2048
- **Número de Threads:** 1, 2, 4, 8
- **Tamanho do Bloco (2D):** 64×64
- **Repetições:** [INSERIR número de execuções para média]

## 4. Resultados

### 4.1 Tempos de Execução

**Matriz 512×512**

| Implementação | 1 Thread | 2 Threads | 4 Threads | 8 Threads |
|--------------|----------|-----------|-----------|-----------|
| MatMul (Seq) | [___] s | - | - | - |
| MatMulOpenMP | - | [___] s | [___] s | [___] s |
| MatMulCache | [___] s | - | - | - |
| MatMulCacheOpenMP | - | [___] s | [___] s | [___] s |
| MatMul2D | - | [___] s | [___] s | [___] s |
| MatMul2DCache | - | [___] s | [___] s | [___] s |

**Matriz 1024×1024**

| Implementação | 1 Thread | 2 Threads | 4 Threads | 8 Threads |
|--------------|----------|-----------|-----------|-----------|
| MatMul (Seq) | [___] s | - | - | - |
| MatMulOpenMP | - | [___] s | [___] s | [___] s |
| MatMulCache | [___] s | - | - | - |
| MatMulCacheOpenMP | - | [___] s | [___] s | [___] s |
| MatMul2D | - | [___] s | [___] s | [___] s |
| MatMul2DCache | - | [___] s | [___] s | [___] s |

**Matriz 2048×2048**

| Implementação | 1 Thread | 2 Threads | 4 Threads | 8 Threads |
|--------------|----------|-----------|-----------|-----------|
| MatMul (Seq) | [___] s | - | - | - |
| MatMulOpenMP | - | [___] s | [___] s | [___] s |
| MatMulCache | [___] s | - | - | - |
| MatMulCacheOpenMP | - | [___] s | [___] s | [___] s |
| MatMul2D | - | [___] s | [___] s | [___] s |
| MatMul2DCache | - | [___] s | [___] s | [___] s |

### 4.2 Speedup

Speedup calculado em relação ao **MatMul (Sequencial)**

**Matriz 1024×1024 com 8 Threads**

| Implementação | Tempo (s) | Speedup |
|--------------|-----------|---------|
| MatMul (baseline) | [___] | 1.00× |
| MatMulOpenMP | [___] | [___]× |
| MatMulCache | [___] | [___]× |
| MatMulCacheOpenMP | [___] | [___]× |
| MatMul2D | [___] | [___]× |
| **MatMul2DCache** | [___] | **[___]×** |

### 4.3 Eficiência Paralela

Eficiência = Speedup / Número de Threads

**Matriz 2048×2048**

| Implementação | 2 Threads | 4 Threads | 8 Threads |
|--------------|-----------|-----------|-----------|
| MatMulOpenMP | [___]% | [___]% | [___]% |
| MatMulCacheOpenMP | [___]% | [___]% | [___]% |
| MatMul2D | [___]% | [___]% | [___]% |
| MatMul2DCache | [___]% | [___]% | [___]% |

## 5. Análise dos Resultados

### 5.1 Comparação entre Implementações

[INSERIR ANÁLISE]

**Observações Esperadas:**
- MatMul2DCache deve ser a implementação mais rápida
- Particionamento 2D deve superar 1D para matrizes grandes
- Otimização de cache deve trazer ganho significativo
- Eficiência deve diminuir com mais threads (overhead)

### 5.2 Impacto do Particionamento 2D

[INSERIR ANÁLISE]

**Pontos a discutir:**
- Comparar MatMul2D vs MatMulOpenMP (mesmo sem cache)
- Comparar MatMul2DCache vs MatMulCacheOpenMP
- Explicar por que 2D é melhor para matrizes grandes
- Discutir o papel do tamanho do bloco (64×64)

### 5.3 Impacto da Otimização de Cache

[INSERIR ANÁLISE]

**Pontos a discutir:**
- Comparar MatMul2D vs MatMul2DCache
- Explicar a diferença entre ordem i-j-k e i-k-j
- Discutir cache misses e localidade temporal/espacial

### 5.4 Escalabilidade

[INSERIR ANÁLISE]

**Pontos a discutir:**
- Como o speedup varia com o número de threads?
- Por que a eficiência diminui com mais threads?
- Qual o speedup máximo possível? (Lei de Amdahl)

## 6. Conclusões

### 6.1 Principais Achados

1. [INSERIR CONCLUSÃO]
2. [INSERIR CONCLUSÃO]
3. [INSERIR CONCLUSÃO]

### 6.2 Melhor Implementação

A implementação **MatMul2DCache** obteve o melhor desempenho, com speedup de **[___]×** em relação à versão sequencial para matrizes 2048×2048 com 8 threads.

### 6.3 Lições Aprendidas

[INSERIR LIÇÕES APRENDIDAS]

**Aspectos importantes:**
- Importância da localidade de cache
- Benefícios do particionamento 2D
- Balanceamento de carga com schedule dinâmico
- Trade-offs entre paralelismo e overhead

## 7. Referências

1. OpenMP Architecture Review Board. *OpenMP Application Programming Interface Version 5.0*. 2018.
2. Chapman, B., Jost, G., & Van Der Pas, R. *Using OpenMP: Portable Shared Memory Parallel Programming*. MIT Press, 2007.
3. Mattson, T., Sanders, B., & Massingill, B. *Patterns for Parallel Programming*. Addison-Wesley, 2004.

## 8. Apêndices

### Apêndice A: Código-Fonte

O código-fonte completo está disponível em `ompmultmat.c`.

### Apêndice B: Scripts de Teste

Scripts para reproduzir os testes:
- `run_benchmarks.ps1` (Windows)
- `run_benchmarks.sh` (Linux/Mac)

### Apêndice C: Comandos de Compilação

```bash
# GCC
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# Intel Compiler (melhor performance)
icc -qopenmp -O3 -xHost -o ompmultmat ompmultmat.c
```

### Apêndice D: Configuração de Threads

```bash
# Windows PowerShell
$env:OMP_NUM_THREADS=8

# Linux/Mac
export OMP_NUM_THREADS=8
```

---

**Nota:** Para converter este relatório em PDF, você pode usar:
- Pandoc: `pandoc RELATORIO_TEMPLATE.md -o relatorio.pdf`
- Markdown to PDF (extensão VS Code)
- Copiar para Word/Google Docs e exportar como PDF


