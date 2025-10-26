# Makefile para Multiplicação de Matrizes com OpenMP

CC = gcc
CFLAGS = -fopenmp -O3 -march=native -Wall
TARGET = ompmultmat
SOURCE = ompmultmat.c

# Alvo padrão
all: $(TARGET)

# Compilação
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "Compilação concluída com sucesso!"

# Compilação com Intel Compiler (melhor performance)
intel: $(SOURCE)
	icc -qopenmp -O3 -xHost -o $(TARGET) $(SOURCE)
	@echo "Compilação com Intel Compiler concluída!"

# Compilação para debug
debug: CFLAGS = -fopenmp -g -Wall -O0
debug: $(TARGET)
	@echo "Compilação em modo debug concluída!"

# Teste rápido (matriz 512x512)
test: $(TARGET)
	@echo "Executando teste rápido (512x512)..."
	@echo 512 | ./$(TARGET)

# Teste médio (matriz 1024x1024)
test-medium: $(TARGET)
	@echo "Executando teste médio (1024x1024)..."
	@echo 1024 | ./$(TARGET)

# Teste grande (matriz 2048x2048)
test-large: $(TARGET)
	@echo "Executando teste grande (2048x2048)..."
	@echo 2048 | ./$(TARGET)

# Benchmark completo
benchmark: $(TARGET)
	@echo "Executando benchmark completo..."
	@bash run_benchmarks.sh || powershell -ExecutionPolicy Bypass -File run_benchmarks.ps1

# Limpar arquivos compilados
clean:
	rm -f $(TARGET) $(TARGET).exe *.o
	@echo "Arquivos temporários removidos!"

# Limpar resultados de benchmark
clean-results:
	rm -f benchmark_results.txt
	@echo "Resultados de benchmark removidos!"

# Limpar tudo
cleanall: clean clean-results

# Mostrar informações do sistema
sysinfo:
	@echo "=== Informações do Sistema ==="
	@echo "Sistema Operacional:"
	@uname -a || systeminfo | findstr /C:"OS"
	@echo ""
	@echo "Processador:"
	@lscpu 2>/dev/null || wmic cpu get name 2>/dev/null || sysctl -n machdep.cpu.brand_string 2>/dev/null
	@echo ""
	@echo "Memória:"
	@free -h 2>/dev/null || wmic memorychip get capacity 2>/dev/null || sysctl hw.memsize 2>/dev/null
	@echo ""
	@echo "Compilador:"
	@$(CC) --version | head -1

# Ajuda
help:
	@echo "Targets disponíveis:"
	@echo "  make              - Compila o programa"
	@echo "  make intel        - Compila com Intel Compiler"
	@echo "  make debug        - Compila em modo debug"
	@echo "  make test         - Teste rápido (512x512)"
	@echo "  make test-medium  - Teste médio (1024x1024)"
	@echo "  make test-large   - Teste grande (2048x2048)"
	@echo "  make benchmark    - Executa benchmark completo"
	@echo "  make clean        - Remove arquivos compilados"
	@echo "  make clean-results- Remove resultados de benchmark"
	@echo "  make cleanall     - Remove tudo"
	@echo "  make sysinfo      - Mostra informações do sistema"
	@echo "  make help         - Mostra esta ajuda"

.PHONY: all intel debug test test-medium test-large benchmark clean clean-results cleanall sysinfo help


