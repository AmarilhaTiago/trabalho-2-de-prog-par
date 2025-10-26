#!/bin/bash
# Script para executar benchmarks da multiplicação de matrizes
# Uso: ./run_benchmarks.sh

echo "========================================"
echo "Benchmark de Multiplicação de Matrizes"
echo "========================================"
echo ""

# Compila o programa se necessário
if [ ! -f "./ompmultmat" ]; then
    echo "Executável não encontrado. Compilando..."
    gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
    
    if [ $? -ne 0 ]; then
        echo "Erro na compilação!"
        exit 1
    fi
    echo "Compilação bem-sucedida!"
    echo ""
fi

# Configurações de teste
MATRIX_SIZES=(512 1024 2048)
THREAD_COUNTS=(1 2 4 8)

# Arquivo de resultados
OUTPUT_FILE="benchmark_results.txt"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Informações do sistema
CPU_INFO=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
CORES=$(lscpu | grep "^CPU(s):" | cut -d: -f2 | xargs)
THREADS=$(lscpu | grep "^Thread" | cut -d: -f2 | xargs)

# Cabeçalho do arquivo
cat > $OUTPUT_FILE << EOF
========================================
Resultados de Benchmark
Data: $TIMESTAMP
Hostname: $(hostname)
Processador: $CPU_INFO
CPUs: $CORES
========================================

EOF

echo "Informações do Sistema:"
echo "  Hostname: $(hostname)"
echo "  Processador: $CPU_INFO"
echo "  CPUs: $CORES"
echo ""

# Loop principal de testes
for SIZE in "${MATRIX_SIZES[@]}"; do
    for THREADS in "${THREAD_COUNTS[@]}"; do
        export OMP_NUM_THREADS=$THREADS
        
        echo "Executando: Matriz ${SIZE}x${SIZE}, $THREADS threads..."
        
        echo "" >> $OUTPUT_FILE
        echo "========================================" >> $OUTPUT_FILE
        echo "Matriz: ${SIZE}x${SIZE} | Threads: $THREADS" >> $OUTPUT_FILE
        echo "========================================" >> $OUTPUT_FILE
        
        # Executa o benchmark
        echo $SIZE | ./ompmultmat >> $OUTPUT_FILE 2>&1
        
        # Mostra tempo na tela
        LAST_TIME=$(tail -1 $OUTPUT_FILE | grep "MatMul2DCache")
        if [ ! -z "$LAST_TIME" ]; then
            echo "  ✓ $LAST_TIME"
        fi
        
        sleep 0.5
    done
done

echo ""
echo "========================================"
echo "Testes concluídos!"
echo "Resultados salvos em: $OUTPUT_FILE"
echo "========================================"

# Resumo
echo ""
echo "Resumo - Melhor implementação por tamanho:"
for SIZE in "${MATRIX_SIZES[@]}"; do
    BEST=$(grep -A 10 "Matriz: ${SIZE}x${SIZE}" $OUTPUT_FILE | grep "MatMul2DCache" | head -1)
    echo "  ${SIZE}x${SIZE}: $BEST"
done

echo ""
echo "Para visualizar todos os resultados: cat $OUTPUT_FILE"


