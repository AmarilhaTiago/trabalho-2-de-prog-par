# Comandos Úteis - Benchmark e Informações do Sistema

## Compilação

### Windows (MinGW/GCC)
```powershell
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

### Linux
```bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

### Com Makefile
```bash
make              # Compilação padrão
make intel        # Com Intel Compiler (melhor performance)
make debug        # Modo debug
```

## Execução

### Teste manual com tamanho específico
```powershell
# Windows
echo 1024 | .\ompmultmat.exe

# Linux
echo 1024 | ./ompmultmat
```

### Com Makefile
```bash
make test         # Teste rápido (512x512)
make test-medium  # Teste médio (1024x1024)
make test-large   # Teste grande (2048x2048)
```

### Executar benchmarks completos
```powershell
# Windows
.\run_benchmarks.ps1

# Linux/Mac
chmod +x run_benchmarks.sh
./run_benchmarks.sh

# Com Makefile
make benchmark
```

## Configurar Número de Threads

### Windows PowerShell
```powershell
$env:OMP_NUM_THREADS=8
echo 1024 | .\ompmultmat.exe

# Testar com diferentes números de threads
foreach ($t in 1,2,4,8) {
    $env:OMP_NUM_THREADS=$t
    Write-Host "Testing with $t threads..."
    echo 1024 | .\ompmultmat.exe
}
```

### Linux/Mac
```bash
export OMP_NUM_THREADS=8
echo 1024 | ./ompmultmat

# Testar com diferentes números de threads
for t in 1 2 4 8; do
    echo "Testing with $t threads..."
    OMP_NUM_THREADS=$t echo 1024 | ./ompmultmat
done
```

## Informações do Sistema (para o relatório)

### Windows PowerShell

#### Informações do Processador
```powershell
# Informações completas
Get-WmiObject Win32_Processor | Format-List Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

# Resumo
$cpu = Get-WmiObject Win32_Processor
Write-Host "Processador: $($cpu.Name)"
Write-Host "Cores Físicos: $($cpu.NumberOfCores)"
Write-Host "Cores Lógicos: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Frequência: $($cpu.MaxClockSpeed) MHz"
```

#### Informações de Cache
```powershell
# Cache L2
Get-WmiObject Win32_CacheMemory | Where-Object {$_.Level -eq 3} | Format-List DeviceID, InstalledSize, MaxCacheSize

# Alternativa
systeminfo | findstr /C:"Processor"
```

#### Memória RAM
```powershell
# Memória total
$memory = Get-WmiObject Win32_ComputerSystem
$totalRAM = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
Write-Host "Memória Total: $totalRAM GB"

# Detalhes
Get-WmiObject Win32_PhysicalMemory | Format-List Capacity, Speed, Manufacturer
```

#### Sistema Operacional
```powershell
Get-WmiObject Win32_OperatingSystem | Format-List Caption, Version, OSArchitecture
```

#### Versão do Compilador
```powershell
gcc --version
```

#### Número de Processadores
```powershell
$env:NUMBER_OF_PROCESSORS
```

### Linux

#### Informações do Processador
```bash
# Informações completas
lscpu

# Resumo
echo "Processador: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
echo "Cores: $(lscpu | grep "^CPU(s):" | cut -d: -f2 | xargs)"
echo "Threads por core: $(lscpu | grep "Thread" | cut -d: -f2 | xargs)"
echo "Sockets: $(lscpu | grep "Socket" | cut -d: -f2 | xargs)"

# Detalhes do CPU
cat /proc/cpuinfo | grep -E "model name|cpu MHz|cache size" | head -20
```

#### Informações de Cache
```bash
# Cache L1, L2, L3
lscpu | grep -i cache

# Detalhes
cat /sys/devices/system/cpu/cpu0/cache/index*/size
```

#### Memória RAM
```bash
# Memória total
free -h

# Detalhes
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# Informações físicas
sudo dmidecode --type memory | grep -E "Size|Speed|Type:"
```

#### Sistema Operacional
```bash
# Distribuição
cat /etc/os-release

# Kernel
uname -a
```

#### Versão do Compilador
```bash
gcc --version
```

### macOS

#### Informações do Processador
```bash
sysctl -n machdep.cpu.brand_string
sysctl -n hw.ncpu
sysctl -n hw.physicalcpu
```

#### Informações de Cache
```bash
sysctl -a | grep cache
```

#### Memória RAM
```bash
sysctl hw.memsize
# Converter para GB: $(sysctl -n hw.memsize) / 1024^3
```

## Análise de Performance

### Verificar uso de CPU durante execução
```powershell
# Windows - Em outro terminal
while ($true) { 
    Get-Counter '\Processor(_Total)\% Processor Time' | 
    Select-Object -ExpandProperty CounterSamples | 
    Select-Object CookedValue; 
    Start-Sleep -Seconds 1 
}
```

```bash
# Linux
htop  # ou top

# Monitorar durante execução
(echo 2048 | ./ompmultmat) & 
pid=$!
top -p $pid
```

### Verificar uso de memória
```powershell
# Windows
Get-Process ompmultmat | Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
```

```bash
# Linux
ps aux | grep ompmultmat
```

### Profiling com perf (Linux)
```bash
# Compilar com símbolos
gcc -fopenmp -O3 -march=native -g -o ompmultmat ompmultmat.c

# Executar com profiling
perf record -g echo 1024 | ./ompmultmat

# Ver resultados
perf report
```

## Testar Diferentes Configurações

### Testar diferentes tamanhos de bloco
Edite as linhas 123 e 163 em `ompmultmat.c`:
```c
int BLOCK_SIZE = 32;  // Teste 32, 64, 128, 256
```

Depois recompile e execute:
```bash
make clean
make
make benchmark
```

### Testar diferentes políticas de scheduling
Modifique as linhas com `#pragma omp for` nas funções 2D:
```c
// Experimente:
#pragma omp for collapse(2) schedule(static)
#pragma omp for collapse(2) schedule(dynamic)
#pragma omp for collapse(2) schedule(guided)
```

## Exportar Resultados

### Salvar resultados em arquivo
```powershell
# Windows
.\run_benchmarks.ps1 > resultados_completos.txt

# Linux
./run_benchmarks.sh > resultados_completos.txt
```

### Criar gráficos (Python)
```bash
# Instalar dependências
pip install matplotlib pandas numpy

# Criar gráfico (exemplo)
python -c "
import matplotlib.pyplot as plt
import numpy as np

# Seus dados aqui
threads = [1, 2, 4, 8]
speedup_2d = [1, 1.95, 3.8, 7.2]  # Exemplo

plt.plot(threads, speedup_2d, marker='o', label='MatMul2DCache')
plt.plot(threads, threads, '--', label='Speedup Ideal')
plt.xlabel('Número de Threads')
plt.ylabel('Speedup')
plt.title('Speedup vs Threads')
plt.legend()
plt.grid(True)
plt.savefig('speedup_graph.png')
print('Gráfico salvo em speedup_graph.png')
"
```

## Gerar PDF do Relatório

### Usando Pandoc
```bash
# Instalar pandoc: https://pandoc.org/installing.html

# Converter Markdown para PDF
pandoc RELATORIO_TEMPLATE.md -o relatorio.pdf

# Com template personalizado
pandoc RELATORIO_TEMPLATE.md -o relatorio.pdf --toc --number-sections

# Com imagens
pandoc RELATORIO_TEMPLATE.md -o relatorio.pdf --toc -V geometry:margin=1in
```

### Usando Markdown Preview Enhanced (VS Code)
1. Abra `RELATORIO_TEMPLATE.md` no VS Code
2. Clique com botão direito
3. Selecione "Markdown Preview Enhanced: Open Preview"
4. Na preview, clique com botão direito
5. Selecione "Export" → "PDF"

## Dicas de Performance

### Desabilitar outras aplicações
```powershell
# Windows - Fechar aplicações desnecessárias
# Desabilitar antivírus temporariamente durante testes

# Linux - Isolar CPUs
sudo cset shield --cpu 0-7 --kthread=on
sudo cset shield --exec ./ompmultmat -- < input.txt
```

### Configurar prioridade do processo
```powershell
# Windows - Executar com prioridade alta
Start-Process -FilePath ".\ompmultmat.exe" -Priority High
```

```bash
# Linux - Executar com prioridade alta
nice -n -20 ./ompmultmat < input.txt
```

### Verificar Turbo Boost / Frequency Scaling
```bash
# Linux - Verificar governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Configurar para performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Troubleshooting

### Erro: "undefined reference to omp_get_wtime"
Solução: Adicione flag `-fopenmp` na compilação

### Erro: "Permission denied" (Linux)
Solução: `chmod +x ompmultmat` ou `chmod +x run_benchmarks.sh`

### Programa muito lento
- Verifique se compilou com `-O3`
- Verifique se OpenMP está habilitado
- Teste com matriz menor primeiro (512)

### Resultados inconsistentes
- Execute múltiplas vezes e tire a média
- Feche outros programas
- Verifique se há thermal throttling no CPU


