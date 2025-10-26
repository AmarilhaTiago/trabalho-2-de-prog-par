#!/usr/bin/env python3
"""
Script para gerar gráficos dos resultados de benchmark
Uso: python plot_results.py [benchmark_results.txt]
"""

import re
import sys
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

def parse_results(filename):
    """Parse o arquivo de resultados do benchmark"""
    results = defaultdict(lambda: defaultdict(dict))
    
    current_size = None
    current_threads = None
    
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            # Detecta informações de matriz e threads
            matrix_match = re.search(r'Matriz:\s*(\d+)x\d+\s*\|\s*Threads:\s*(\d+)', line)
            if matrix_match:
                current_size = int(matrix_match.group(1))
                current_threads = int(matrix_match.group(2))
                continue
            
            # Detecta tempos de execução
            if current_size and current_threads:
                # MatMul sequencial
                match = re.search(r'matMul Time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMul'][1] = float(match.group(1))
                
                # MatMulOpenMP
                match = re.search(r'MatMulOpenMP time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMulOpenMP'][current_threads] = float(match.group(1))
                
                # MatMulCache
                match = re.search(r'MatMulCacheOptimized time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMulCache'][1] = float(match.group(1))
                
                # MatMulCacheOpenMP
                match = re.search(r'MatMulCacheOptimizedOpenMP time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMulCacheOpenMP'][current_threads] = float(match.group(1))
                
                # MatMul2D
                match = re.search(r'MatMul2D.*time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMul2D'][current_threads] = float(match.group(1))
                
                # MatMul2DCache
                match = re.search(r'MatMul2DCache.*time\s+([\d.]+)\s*s', line)
                if match:
                    results[current_size]['MatMul2DCache'][current_threads] = float(match.group(1))
    
    return results

def plot_execution_time(results, matrix_size):
    """Gera gráfico de tempo de execução vs threads"""
    plt.figure(figsize=(12, 7))
    
    implementations = ['MatMulOpenMP', 'MatMulCacheOpenMP', 'MatMul2D', 'MatMul2DCache']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    markers = ['o', 's', '^', 'D']
    
    for impl, color, marker in zip(implementations, colors, markers):
        if impl in results[matrix_size]:
            threads = sorted(results[matrix_size][impl].keys())
            times = [results[matrix_size][impl][t] for t in threads]
            plt.plot(threads, times, marker=marker, label=impl, color=color, linewidth=2, markersize=8)
    
    # Adicionar linhas sequenciais como referência
    if 'MatMul' in results[matrix_size]:
        seq_time = results[matrix_size]['MatMul'][1]
        plt.axhline(y=seq_time, color='gray', linestyle='--', label='MatMul (Seq)', alpha=0.7)
    
    if 'MatMulCache' in results[matrix_size]:
        cache_time = results[matrix_size]['MatMulCache'][1]
        plt.axhline(y=cache_time, color='purple', linestyle='--', label='MatMulCache (Seq)', alpha=0.7)
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Tempo de Execução (s)', fontsize=12, fontweight='bold')
    plt.title(f'Tempo de Execução - Matriz {matrix_size}×{matrix_size}', fontsize=14, fontweight='bold')
    plt.legend(loc='best', fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.yscale('log')  # Escala logarítmica para melhor visualização
    plt.tight_layout()
    plt.savefig(f'execution_time_{matrix_size}.png', dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: execution_time_{matrix_size}.png")

def plot_speedup(results, matrix_size):
    """Gera gráfico de speedup vs threads"""
    plt.figure(figsize=(12, 7))
    
    # Baseline sequencial
    if 'MatMul' not in results[matrix_size] or 1 not in results[matrix_size]['MatMul']:
        print(f"⚠ Aviso: Tempo sequencial não encontrado para matriz {matrix_size}")
        return
    
    baseline = results[matrix_size]['MatMul'][1]
    
    implementations = ['MatMulOpenMP', 'MatMulCacheOpenMP', 'MatMul2D', 'MatMul2DCache']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    markers = ['o', 's', '^', 'D']
    
    max_threads = 0
    for impl, color, marker in zip(implementations, colors, markers):
        if impl in results[matrix_size]:
            threads = sorted(results[matrix_size][impl].keys())
            speedups = [baseline / results[matrix_size][impl][t] for t in threads]
            plt.plot(threads, speedups, marker=marker, label=impl, color=color, linewidth=2, markersize=8)
            max_threads = max(max_threads, max(threads))
    
    # Linha de speedup ideal
    ideal_threads = range(1, max_threads + 1)
    plt.plot(ideal_threads, ideal_threads, 'k--', label='Speedup Ideal', linewidth=2, alpha=0.5)
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Speedup', fontsize=12, fontweight='bold')
    plt.title(f'Speedup - Matriz {matrix_size}×{matrix_size}', fontsize=14, fontweight='bold')
    plt.legend(loc='best', fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.xlim(1, max_threads)
    plt.ylim(0, max_threads * 1.1)
    plt.tight_layout()
    plt.savefig(f'speedup_{matrix_size}.png', dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: speedup_{matrix_size}.png")

def plot_efficiency(results, matrix_size):
    """Gera gráfico de eficiência vs threads"""
    plt.figure(figsize=(12, 7))
    
    if 'MatMul' not in results[matrix_size] or 1 not in results[matrix_size]['MatMul']:
        print(f"⚠ Aviso: Tempo sequencial não encontrado para matriz {matrix_size}")
        return
    
    baseline = results[matrix_size]['MatMul'][1]
    
    implementations = ['MatMulOpenMP', 'MatMulCacheOpenMP', 'MatMul2D', 'MatMul2DCache']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    markers = ['o', 's', '^', 'D']
    
    for impl, color, marker in zip(implementations, colors, markers):
        if impl in results[matrix_size]:
            threads = sorted(results[matrix_size][impl].keys())
            efficiencies = [(baseline / results[matrix_size][impl][t] / t) * 100 for t in threads]
            plt.plot(threads, efficiencies, marker=marker, label=impl, color=color, linewidth=2, markersize=8)
    
    # Linha de eficiência ideal (100%)
    plt.axhline(y=100, color='black', linestyle='--', label='Eficiência Ideal', linewidth=2, alpha=0.5)
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Eficiência (%)', fontsize=12, fontweight='bold')
    plt.title(f'Eficiência Paralela - Matriz {matrix_size}×{matrix_size}', fontsize=14, fontweight='bold')
    plt.legend(loc='best', fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.ylim(0, 110)
    plt.tight_layout()
    plt.savefig(f'efficiency_{matrix_size}.png', dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: efficiency_{matrix_size}.png")

def plot_comparison_all_sizes(results):
    """Gera gráfico comparando todos os tamanhos de matriz"""
    plt.figure(figsize=(14, 8))
    
    sizes = sorted(results.keys())
    implementations = ['MatMul2DCache', 'MatMul2D', 'MatMulCacheOpenMP', 'MatMulOpenMP']
    colors = ['#f39c12', '#2ecc71', '#3498db', '#e74c3c']
    
    # Usar máximo número de threads disponível
    max_threads = 8  # Ajuste conforme necessário
    
    x = np.arange(len(sizes))
    width = 0.2
    
    for i, (impl, color) in enumerate(zip(implementations, colors)):
        times = []
        for size in sizes:
            if impl in results[size] and max_threads in results[size][impl]:
                times.append(results[size][impl][max_threads])
            else:
                times.append(0)
        
        offset = (i - len(implementations)/2 + 0.5) * width
        plt.bar(x + offset, times, width, label=impl, color=color, alpha=0.8)
    
    plt.xlabel('Tamanho da Matriz', fontsize=12, fontweight='bold')
    plt.ylabel('Tempo de Execução (s)', fontsize=12, fontweight='bold')
    plt.title(f'Comparação de Desempenho - {max_threads} Threads', fontsize=14, fontweight='bold')
    plt.xticks(x, [f'{s}×{s}' for s in sizes])
    plt.legend(loc='best', fontsize=10)
    plt.grid(True, axis='y', alpha=0.3)
    plt.yscale('log')
    plt.tight_layout()
    plt.savefig('comparison_all_sizes.png', dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: comparison_all_sizes.png")

def generate_summary_table(results):
    """Gera tabela resumo dos resultados"""
    print("\n" + "="*80)
    print("RESUMO DOS RESULTADOS")
    print("="*80)
    
    for size in sorted(results.keys()):
        print(f"\n🔹 Matriz {size}×{size}")
        print("-" * 80)
        
        if 'MatMul' in results[size] and 1 in results[size]['MatMul']:
            baseline = results[size]['MatMul'][1]
            print(f"Baseline (MatMul sequencial): {baseline:.4f} s")
            print()
            
            # Encontrar melhor resultado
            best_time = float('inf')
            best_impl = None
            best_threads = None
            
            for impl in ['MatMulOpenMP', 'MatMulCacheOpenMP', 'MatMul2D', 'MatMul2DCache']:
                if impl in results[size]:
                    for threads, time in results[size][impl].items():
                        speedup = baseline / time
                        efficiency = (speedup / threads) * 100
                        
                        print(f"{impl:25s} | {threads:2d} threads | {time:8.4f} s | "
                              f"Speedup: {speedup:6.2f}× | Eficiência: {efficiency:5.1f}%")
                        
                        if time < best_time:
                            best_time = time
                            best_impl = impl
                            best_threads = threads
            
            if best_impl:
                print(f"\n✓ Melhor: {best_impl} com {best_threads} threads - "
                      f"Speedup de {baseline/best_time:.2f}×")

def main():
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    else:
        filename = 'benchmark_results.txt'
    
    print(f"Lendo resultados de: {filename}")
    print()
    
    try:
        results = parse_results(filename)
    except FileNotFoundError:
        print(f"❌ Erro: Arquivo '{filename}' não encontrado!")
        print("Execute primeiro: ./run_benchmarks.sh ou .\\run_benchmarks.ps1")
        sys.exit(1)
    
    if not results:
        print("❌ Erro: Nenhum resultado encontrado no arquivo!")
        sys.exit(1)
    
    print(f"✓ Resultados carregados para {len(results)} tamanhos de matriz")
    print()
    
    # Gerar gráficos para cada tamanho
    for size in sorted(results.keys()):
        print(f"Gerando gráficos para matriz {size}×{size}...")
        plot_execution_time(results, size)
        plot_speedup(results, size)
        plot_efficiency(results, size)
        print()
    
    # Gerar gráfico de comparação geral
    print("Gerando gráfico de comparação geral...")
    plot_comparison_all_sizes(results)
    print()
    
    # Gerar tabela resumo
    generate_summary_table(results)
    
    print("\n" + "="*80)
    print("✓ Todos os gráficos foram gerados com sucesso!")
    print("="*80)

if __name__ == '__main__':
    try:
        import matplotlib
        import numpy
    except ImportError:
        print("❌ Erro: Bibliotecas necessárias não encontradas!")
        print("\nInstale as dependências com:")
        print("  pip install matplotlib numpy")
        sys.exit(1)
    
    main()


