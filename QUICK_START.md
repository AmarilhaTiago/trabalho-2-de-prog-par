# 🚀 Guia Rápido de Início

## ⚡ Início Rápido (3 passos)

### 1. Compilar
```bash
# Windows (PowerShell)
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# Linux/Mac
make
```

### 2. Executar Benchmark
```bash
# Windows
.\run_benchmarks.ps1

# Linux/Mac
chmod +x run_benchmarks.sh
./run_benchmarks.sh
```

### 3. Gerar Gráficos
```bash
# Instalar dependências (apenas uma vez)
pip install matplotlib numpy

# Gerar gráficos
python plot_results.py
```

✅ **Pronto!** Os gráficos estarão salvos como PNG e os resultados em `benchmark_results.txt`

---

## 📊 O que foi implementado?

O código possui **6 implementações** de multiplicação de matrizes:

| Implementação | Tipo | Cache | Particionamento | Descrição |
|--------------|------|-------|-----------------|-----------|
| `MatMul` | Sequencial | ❌ | - | Baseline (referência) |
| `MatMulOpenMP` | Paralela | ❌ | 1D | Paralelização simples |
| `MatMulCache` | Sequencial | ✅ | - | Otimização de cache |
| `MatMulCacheOpenMP` | Paralela | ✅ | 1D | Paralela + cache |
| **`MatMul2D`** | Paralela | ❌ | **2D** | **Particionamento em blocos** |
| **`MatMul2DCache`** | Paralela | ✅ | **2D** | **Blocos + cache (melhor!)** |

### 🎯 Novidades do Particionamento 2D

- ✅ Divide matrizes em **blocos de 64×64**
- ✅ Melhor uso do **cache L1/L2**
- ✅ **Paralelização mais eficiente** com schedule dinâmico
- ✅ **Speedup superior** às implementações 1D
- ✅ Vetorização **SIMD** para performance extra

---

## 🔧 Testes Manuais

### Teste simples (512×512)
```bash
# Windows
echo 512 | .\ompmultmat.exe

# Linux/Mac
echo 512 | ./ompmultmat
```

### Teste com 8 threads
```bash
# Windows
$env:OMP_NUM_THREADS=8
echo 1024 | .\ompmultmat.exe

# Linux/Mac
export OMP_NUM_THREADS=8
echo 1024 | ./ompmultmat
```

### Testar diferentes tamanhos
```bash
# Windows
foreach ($size in 512,1024,2048) { echo $size | .\ompmultmat.exe }

# Linux/Mac
for size in 512 1024 2048; do echo $size | ./ompmultmat; done
```

---

## 📈 Resultados Esperados

Para uma matriz **1024×1024** com **8 threads**:

| Implementação | Tempo Esperado | Speedup |
|--------------|----------------|---------|
| MatMul (seq) | ~2.5s | 1.0× |
| MatMulOpenMP | ~0.35s | ~7× |
| MatMulCacheOpenMP | ~0.12s | ~20× |
| **MatMul2D** | ~0.10s | ~25× |
| **MatMul2DCache** | **~0.06s** | **~40×** |

> ⚠️ Valores variam conforme o processador

---

## 📝 Para o Relatório

### Informações da Máquina (Windows)
```powershell
# Copie essas informações
$cpu = Get-WmiObject Win32_Processor
Write-Host "Processador: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "Threads: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Frequência: $($cpu.MaxClockSpeed) MHz"

$ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
Write-Host "RAM: $ram GB"

gcc --version | Select-Object -First 1
```

### Informações da Máquina (Linux)
```bash
# Copie essas informações
echo "Processador: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "Cores: $(lscpu | grep '^CPU(s):' | cut -d: -f2 | xargs)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Compilador: $(gcc --version | head -1)"
```

### Use o Template
1. Abra `RELATORIO_TEMPLATE.md`
2. Preencha com suas informações e resultados
3. Converta para PDF:
   ```bash
   pandoc RELATORIO_TEMPLATE.md -o relatorio.pdf --toc
   ```

---

## 🐛 Troubleshooting

### ❌ "gcc: command not found"
**Solução:** Instale o GCC
- Windows: MinGW-w64 ou MSYS2
- Linux: `sudo apt install build-essential`
- Mac: `xcode-select --install`

### ❌ "undefined reference to omp_get_wtime"
**Solução:** Adicione `-fopenmp` na compilação
```bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

### ❌ Programa muito lento
**Soluções:**
1. Certifique-se de usar `-O3` na compilação
2. Teste com matriz menor primeiro (512)
3. Verifique número de threads: `echo $env:OMP_NUM_THREADS` (Windows) ou `echo $OMP_NUM_THREADS` (Linux)
4. Feche outros programas

### ❌ "ModuleNotFoundError: No module named 'matplotlib'"
**Solução:**
```bash
pip install matplotlib numpy
# ou
python -m pip install matplotlib numpy
```

### ❌ Resultados inconsistentes
**Soluções:**
1. Execute múltiplas vezes e tire a média
2. Feche navegadores e outros programas
3. Conecte o laptop na tomada (evitar throttling)

---

## 📚 Arquivos do Projeto

```
prog-par/
├── ompmultmat.c              # ⭐ Código principal
├── run_benchmarks.ps1        # Script de benchmark (Windows)
├── run_benchmarks.sh         # Script de benchmark (Linux/Mac)
├── plot_results.py           # Gera gráficos
├── Makefile                  # Facilita compilação
├── README.md                 # Documentação completa
├── RELATORIO_TEMPLATE.md     # Template do relatório
├── COMANDOS_UTEIS.md         # Comandos úteis
└── QUICK_START.md           # Este arquivo
```

---

## 🎯 Checklist do Trabalho

- [ ] Código compilando sem erros
- [ ] Executar benchmarks (512, 1024, 2048)
- [ ] Testar com 1, 2, 4, 8 threads
- [ ] Gerar gráficos com `plot_results.py`
- [ ] Coletar informações da máquina
- [ ] Preencher `RELATORIO_TEMPLATE.md`
- [ ] Converter relatório para PDF
- [ ] Verificar se MatMul2DCache é o mais rápido
- [ ] Analisar speedup e eficiência
- [ ] Revisar e enviar!

---

## 💡 Dicas Finais

### Para Melhor Performance:
1. **Compilar com otimização máxima**: `-O3 -march=native`
2. **Usar número correto de threads**: Igual ao número de cores físicos
3. **Ajustar BLOCK_SIZE**: Teste 32, 64, 128 (edite linhas 123 e 163)
4. **Fechar outros programas**: Evita competição por CPU

### Para o Relatório:
1. **Explicar o particionamento 2D**: Use diagramas
2. **Comparar todos os métodos**: Tabelas e gráficos
3. **Analisar speedup**: Por que não é linear?
4. **Discutir cache**: Por que i-k-j é melhor que i-j-k?

### Diferencial:
- 🌟 Testar diferentes BLOCK_SIZE (32, 64, 128)
- 🌟 Testar diferentes schedules (static, dynamic, guided)
- 🌟 Adicionar gráfico de cache misses (com perf, Linux)
- 🌟 Comparar com BLAS ou NumPy

---

## 🆘 Precisa de Ajuda?

1. **Leia primeiro:** `README.md` e `COMANDOS_UTEIS.md`
2. **Verifique:** Compilação com `-fopenmp -O3`
3. **Teste:** Com matriz pequena (512) primeiro
4. **Compare:** Seus resultados com os esperados

---

## ✅ Verificação Rápida

Rode este teste para verificar se está tudo funcionando:

```bash
# Windows
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
$env:OMP_NUM_THREADS=4
echo 512 | .\ompmultmat.exe

# Linux/Mac
make
export OMP_NUM_THREADS=4
echo 512 | ./ompmultmat
```

**Deve mostrar:**
```
Matrix size: 512  memory used 1.048576 MB
matMul Time X.XXX s
MatMulOpenMP time X.XXX s
MatMulCacheOptimized time X.XXX s
MatMulCacheOptimizedOpenMP time X.XXX s
MatMul2D (Particionamento 2D sem cache) time X.XXX s
MatMul2DCache (Particionamento 2D com cache) time X.XXX s
```

Se viu essa saída, **está tudo certo!** 🎉

---

**Boa sorte com o trabalho! 🚀**

