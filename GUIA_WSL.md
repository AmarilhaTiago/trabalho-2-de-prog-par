# 🐧 Guia Completo - WSL (Windows Subsystem for Linux)

## 📋 Passo a Passo Completo

---

## PARTE 1: Instalar WSL

### Passo 1: Instalar WSL (PowerShell como Administrador)

```powershell
# Execute PowerShell como ADMINISTRADOR
# Clique com botão direito no menu Iniciar → "Terminal (Admin)" ou "PowerShell (Admin)"

# Instalar WSL com Ubuntu
wsl --install
```

**⏱️ Isso vai demorar alguns minutos...**

### Passo 2: Reiniciar o Computador

```powershell
# Após a instalação, reinicie
Restart-Computer
```

### Passo 3: Configurar Ubuntu (Após Reiniciar)

Após reiniciar, o Ubuntu abrirá automaticamente. Se não abrir:
- Procure "Ubuntu" no menu Iniciar
- Ou digite `wsl` no PowerShell

**Na primeira execução, você precisará:**
1. Criar um nome de usuário (ex: `amari`)
2. Criar uma senha (não aparece enquanto digita, é normal)
3. Confirmar a senha

---

## PARTE 2: Instalar Ferramentas de Desenvolvimento

### Passo 4: Atualizar o Sistema (Dentro do Ubuntu/WSL)

```bash
# Atualizar lista de pacotes
sudo apt update

# Atualizar pacotes instalados
sudo apt upgrade -y
```

### Passo 5: Instalar GCC e OpenMP

```bash
# Instalar compilador e ferramentas
sudo apt install build-essential -y

# Instalar bibliotecas OpenMP
sudo apt install libomp-dev -y

# Verificar instalação
gcc --version
```

**Deve mostrar:** `gcc (Ubuntu ...) 11.x.x` ou superior

### Passo 6: Instalar Python e Dependências (Opcional - para gráficos)

```bash
# Instalar Python e pip
sudo apt install python3 python3-pip -y

# Instalar bibliotecas para gráficos
pip3 install matplotlib numpy
```

---

## PARTE 3: Acessar e Compilar o Projeto

### Passo 7: Navegar para o Projeto

```bash
# O disco C: do Windows fica em /mnt/c/ no WSL
cd /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par

# Listar arquivos para confirmar
ls -la
```

**Você deve ver:** `ompmultmat.c`, `README.md`, etc.

### Passo 8: Compilar o Programa

```bash
# Compilar com otimizações
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# Verificar se compilou
ls -lh ompmultmat
```

**Deve mostrar:** `ompmultmat` em verde (executável)

---

## PARTE 4: Executar e Testar

### Passo 9: Teste Rápido

```bash
# Teste com matriz 512x512
echo 512 | ./ompmultmat
```

**Saída esperada:**
```
Matrix size: 512  memory used 1.048576 MB
matMul Time 0.XXX s
MatMulOpenMP time 0.XXX s
MatMulCacheOptimized time 0.XXX s
MatMulCacheOptimizedOpenMP time 0.XXX s
MatMul2D (Particionamento 2D sem cache) time 0.XXX s
MatMul2DCache (Particionamento 2D com cache) time 0.XXX s
```

✅ **Se viu isso, está funcionando!**

### Passo 10: Configurar Número de Threads

```bash
# Verificar quantos cores você tem
nproc

# Definir número de threads (use o número de cores, ex: 8)
export OMP_NUM_THREADS=8

# Verificar
echo $OMP_NUM_THREADS
```

### Passo 11: Testes com Diferentes Tamanhos

```bash
# Matriz 512x512
echo 512 | ./ompmultmat

# Matriz 1024x1024
echo 1024 | ./ompmultmat

# Matriz 2048x2048
echo 2048 | ./ompmultmat
```

---

## PARTE 5: Benchmark Completo

### Passo 12: Executar Script de Benchmark

```bash
# Dar permissão de execução
chmod +x run_benchmarks.sh

# Executar benchmark
./run_benchmarks.sh
```

**Isso vai:**
- Testar com matrizes 512, 1024, 2048
- Testar com 1, 2, 4, 8 threads
- Salvar resultados em `benchmark_results.txt`

### Passo 13: Ver Resultados

```bash
# Ver resultados no terminal
cat benchmark_results.txt

# Ou usar less (aperte 'q' para sair)
less benchmark_results.txt

# Ou abrir no editor
nano benchmark_results.txt
```

---

## PARTE 6: Gerar Gráficos (Opcional)

### Passo 14: Gerar Gráficos

```bash
# Gerar gráficos
python3 plot_results.py
```

**Isso cria arquivos PNG:**
- `execution_time_512.png`
- `speedup_1024.png`
- `efficiency_2048.png`
- etc.

### Passo 15: Ver Gráficos no Windows

```bash
# Abrir pasta no Windows Explorer
explorer.exe .
```

Ou copie os PNGs para o Desktop:
```bash
cp *.png /mnt/c/Users/amari/Desktop/
```

---

## 📊 COMANDOS RÁPIDOS - RESUMO

### Se você já instalou tudo, use estes comandos:

```bash
# 1. Abrir WSL
wsl

# 2. Ir para o projeto
cd /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par

# 3. Compilar (apenas primeira vez ou após mudar o código)
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# 4. Definir threads
export OMP_NUM_THREADS=8

# 5. Testar
echo 1024 | ./ompmultmat

# 6. Benchmark completo
./run_benchmarks.sh

# 7. Gerar gráficos
python3 plot_results.py

# 8. Abrir resultados no Windows
explorer.exe .
```

---

## 🔧 COMANDOS ÚTEIS NO WSL

### Compilação

```bash
# Compilação básica
gcc -fopenmp -O3 -o ompmultmat ompmultmat.c

# Com mais otimizações
gcc -fopenmp -O3 -march=native -funroll-loops -o ompmultmat ompmultmat.c

# Para debug
gcc -fopenmp -g -O0 -o ompmultmat ompmultmat.c
```

### Testar com Diferentes Configurações

```bash
# Testar com diferentes números de threads
for threads in 1 2 4 8; do
    echo "=== Testando com $threads threads ==="
    export OMP_NUM_THREADS=$threads
    echo 1024 | ./ompmultmat
    echo ""
done
```

### Informações do Sistema (para o relatório)

```bash
# Informações do processador
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|MHz"

# Resumo
echo "Processador: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "Cores: $(nproc)"
echo "Threads: $(lscpu | grep '^CPU(s):' | awk '{print $2}')"

# Memória
free -h

# Sistema operacional
cat /etc/os-release | grep PRETTY_NAME

# Compilador
gcc --version | head -1
```

### Copiar Resultados para Windows

```bash
# Copiar resultados para Desktop
cp benchmark_results.txt /mnt/c/Users/amari/Desktop/

# Copiar gráficos
cp *.png /mnt/c/Users/amari/Desktop/

# Copiar tudo para uma pasta
mkdir -p /mnt/c/Users/amari/Desktop/resultados_trabalho
cp benchmark_results.txt *.png /mnt/c/Users/amari/Desktop/resultados_trabalho/
```

---

## 🎯 FLUXO COMPLETO - PRIMEIRA VEZ

Execute tudo de uma vez (copie e cole no WSL):

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar ferramentas
sudo apt install build-essential libomp-dev python3 python3-pip -y

# Instalar bibliotecas Python
pip3 install matplotlib numpy

# Ir para o projeto
cd /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par

# Compilar
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# Configurar threads
export OMP_NUM_THREADS=$(nproc)

# Teste rápido
echo 512 | ./ompmultmat

echo ""
echo "✅ Tudo instalado e funcionando!"
echo "Execute: ./run_benchmarks.sh para benchmark completo"
```

---

## 🆘 PROBLEMAS COMUNS

### "wsl: command not found"
```powershell
# No PowerShell como Administrador
wsl --install
# Reinicie o computador
```

### "sudo: unable to resolve host"
```bash
# Editar hosts
sudo nano /etc/hosts
# Adicione esta linha (substitua 'seu-hostname' pelo nome do seu PC):
127.0.0.1 seu-hostname
```

### "Permission denied" ao executar ./ompmultmat
```bash
# Dar permissão de execução
chmod +x ompmultmat
```

### WSL muito lento ao acessar arquivos do Windows
**Solução:** Copie o projeto para dentro do WSL:
```bash
# Copiar projeto para home do WSL
cp -r /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par ~/
cd ~/prog-par

# Compilar e executar normalmente
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
echo 512 | ./ompmultmat
```

### Gráficos não aparecem
```bash
# Instalar backend do matplotlib
pip3 install matplotlib --upgrade

# Ou gere os gráficos e abra no Windows
python3 plot_results.py
explorer.exe .
```

---

## 💡 DICAS PRO

### 1. Criar Alias para Facilitar

```bash
# Adicionar ao ~/.bashrc
echo 'alias projpar="cd /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par"' >> ~/.bashrc
source ~/.bashrc

# Agora você pode usar:
projpar
```

### 2. Script de Compilação Rápida

```bash
# Criar script
cat > compile.sh << 'EOF'
#!/bin/bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c && \
echo "✅ Compilado com sucesso!" || \
echo "❌ Erro na compilação"
EOF

chmod +x compile.sh

# Usar
./compile.sh
```

### 3. Usar Makefile

```bash
# Já existe no projeto!
make          # Compila
make test     # Teste rápido
make benchmark # Benchmark completo
make clean    # Limpar
```

### 4. Monitorar Performance

```bash
# Executar com monitoramento
time echo 1024 | ./ompmultmat

# Ver uso de CPU em tempo real (em outro terminal WSL)
htop
# Instale com: sudo apt install htop
```

---

## 📈 RESULTADOS ESPERADOS

Com 8 threads, matriz 1024x1024:

| Implementação | Tempo Esperado | Speedup |
|--------------|----------------|---------|
| MatMul (seq) | ~2-3s | 1.0× |
| MatMulOpenMP | ~0.4s | ~7× |
| MatMulCacheOpenMP | ~0.15s | ~20× |
| MatMul2D | ~0.12s | ~25× |
| **MatMul2DCache** | **~0.07s** | **~40×** |

> ⚠️ Valores variam conforme o processador

---

## 🚀 CHECKLIST

- [ ] WSL instalado e configurado
- [ ] GCC e OpenMP instalados
- [ ] Projeto acessível no WSL
- [ ] Compilação bem-sucedida
- [ ] Teste rápido funcionando
- [ ] Número de threads configurado
- [ ] Benchmark completo executado
- [ ] Resultados salvos
- [ ] Gráficos gerados (opcional)
- [ ] Informações da máquina coletadas
- [ ] Pronto para o relatório!

---

## 🎓 PARA O RELATÓRIO

### Coletar Informações da Máquina

```bash
# Execute isso e copie a saída para o relatório
echo "========================================="
echo "INFORMAÇÕES DO SISTEMA"
echo "========================================="
echo ""
echo "Processador: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "Arquitetura: $(uname -m)"
echo "Cores Físicos: $(lscpu | grep '^Core(s) per socket' | awk '{print $4}')"
echo "Threads: $(nproc)"
echo "Frequência: $(lscpu | grep 'MHz' | head -1 | awk '{print $3}') MHz"
echo "Cache L1d: $(lscpu | grep 'L1d' | awk '{print $3}')"
echo "Cache L1i: $(lscpu | grep 'L1i' | awk '{print $3}')"
echo "Cache L2: $(lscpu | grep 'L2' | awk '{print $3}')"
echo "Cache L3: $(lscpu | grep 'L3' | awk '{print $3}')"
echo "Memória Total: $(free -h | grep Mem | awk '{print $2}')"
echo ""
echo "Sistema Operacional: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo "Kernel: $(uname -r)"
echo "Compilador: $(gcc --version | head -1)"
echo ""
echo "========================================="
```

---

**Pronto! Agora você pode usar o WSL para compilar e executar! 🐧🚀**


