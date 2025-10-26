# Script para executar benchmarks da multiplicação de matrizes
# Uso: .\run_benchmarks.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Benchmark de Multiplicação de Matrizes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se o executável existe
if (-not (Test-Path ".\ompmultmat.exe")) {
    Write-Host "Executável não encontrado. Compilando..." -ForegroundColor Yellow
    gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erro na compilação!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Compilação bem-sucedida!" -ForegroundColor Green
    Write-Host ""
}

# Configurações de teste
$matrix_sizes = @(512, 1024, 2048)
$thread_counts = @(1, 2, 4, 8)

# Arquivo de resultados
$output_file = "benchmark_results.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Cabeçalho do arquivo
@"
========================================
Resultados de Benchmark
Data: $timestamp
Máquina: $env:COMPUTERNAME
Processador: $((Get-WmiObject Win32_Processor).Name)
Cores Físicos: $((Get-WmiObject Win32_Processor).NumberOfCores)
Cores Lógicos: $((Get-WmiObject Win32_Processor).NumberOfLogicalProcessors)
========================================

"@ | Out-File $output_file

Write-Host "Informações do Sistema:" -ForegroundColor Green
Write-Host "  Máquina: $env:COMPUTERNAME"
Write-Host "  Processador: $((Get-WmiObject Win32_Processor).Name)"
Write-Host "  Cores Físicos: $((Get-WmiObject Win32_Processor).NumberOfCores)"
Write-Host "  Cores Lógicos: $((Get-WmiObject Win32_Processor).NumberOfLogicalProcessors)"
Write-Host ""

# Loop principal de testes
foreach ($size in $matrix_sizes) {
    foreach ($threads in $thread_counts) {
        $env:OMP_NUM_THREADS = $threads
        
        Write-Host "Executando: Matriz ${size}x${size}, $threads threads..." -ForegroundColor Yellow
        
        $result_header = "`n========================================`nMatriz: ${size}x${size} | Threads: $threads`n========================================`n"
        $result_header | Out-File $output_file -Append
        
        # Executa o benchmark
        $result = echo $size | .\ompmultmat.exe 2>&1
        $result | Out-File $output_file -Append
        
        # Mostra tempo total na tela
        $last_line = ($result | Select-String "MatMul2DCache" | Select-Object -Last 1)
        if ($last_line) {
            Write-Host "  ✓ $last_line" -ForegroundColor Green
        }
        
        Start-Sleep -Milliseconds 500
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testes concluídos!" -ForegroundColor Green
Write-Host "Resultados salvos em: $output_file" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Exibe resumo dos melhores tempos
Write-Host "`nResumo - Melhor implementação por tamanho:" -ForegroundColor Cyan
foreach ($size in $matrix_sizes) {
    $best = Select-String -Path $output_file -Pattern "MatMul2DCache.*time.*s" -Context 1,0 | 
            Where-Object { $_.Context.PreContext -match "Matriz: ${size}" } |
            Select-Object -First 1
    if ($best) {
        Write-Host "  ${size}x${size}: $($best.Line)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Para visualizar todos os resultados: notepad $output_file" -ForegroundColor Cyan


