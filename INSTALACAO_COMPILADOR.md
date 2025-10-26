# 🔧 Instalação do Compilador GCC no Windows

## ⚠️ Situação Atual
Nenhum compilador C foi detectado no seu sistema. Você precisa instalar o GCC com suporte a OpenMP.

## 🚀 Opção 1: MSYS2 (Recomendado - Mais Fácil)

### Passo 1: Baixar e Instalar MSYS2
1. Acesse: https://www.msys2.org/
2. Baixe o instalador: `msys2-x86_64-xxxxxxxx.exe`
3. Execute o instalador
4. Instale no caminho padrão: `C:\msys64`

### Passo 2: Instalar GCC com OpenMP
Após a instalação, uma janela do MSYS2 abrirá. Digite:

```bash
# Atualizar o sistema
pacman -Syu

# Se a janela fechar, abra "MSYS2 MSYS" novamente e execute:
pacman -Su

# Instalar o compilador GCC com OpenMP
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-openmp
```

### Passo 3: Adicionar ao PATH
1. Pressione `Win + R`, digite `sysdm.cpl` e aperte Enter
2. Vá na aba "Avançado"
3. Clique em "Variáveis de Ambiente"
4. Em "Variáveis do sistema", encontre "Path" e clique em "Editar"
5. Clique em "Novo" e adicione: `C:\msys64\mingw64\bin`
6. Clique em "OK" em todas as janelas

### Passo 4: Verificar Instalação
**IMPORTANTE:** Feche e abra um novo PowerShell/Terminal, depois execute:
```powershell
gcc --version
```

Deve mostrar algo como: `gcc (Rev...) 13.x.x`

---

## 🔵 Opção 2: MinGW-w64 via Winlibs

### Passo 1: Baixar
1. Acesse: https://winlibs.com/
2. Baixe a versão **UCRT runtime** (mais recente)
3. Escolha a opção **with POSIX threads** (suporta OpenMP)
4. Baixe o arquivo `.zip` (ex: `winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64ucrt-11.0.1-r5.zip`)

### Passo 2: Extrair
1. Extraia o arquivo ZIP em um local, por exemplo: `C:\mingw64`
2. Você terá uma estrutura: `C:\mingw64\bin\gcc.exe`

### Passo 3: Adicionar ao PATH
1. Pressione `Win + R`, digite `sysdm.cpl` e aperte Enter
2. Vá na aba "Avançado"
3. Clique em "Variáveis de Ambiente"
4. Em "Variáveis do sistema", encontre "Path" e clique em "Editar"
5. Clique em "Novo" e adicione: `C:\mingw64\bin`
6. Clique em "OK" em todas as janelas

### Passo 4: Verificar
**Feche e abra um novo PowerShell**, depois:
```powershell
gcc --version
```

---

## 🟢 Opção 3: Chocolatey (Para quem já usa)

Se você tem o Chocolatey instalado:

```powershell
# Execute como Administrador
choco install mingw
```

---

## 🟡 Opção 4: WSL (Windows Subsystem for Linux)

Se preferir usar Linux dentro do Windows:

### Passo 1: Instalar WSL
```powershell
# Execute como Administrador
wsl --install
```

### Passo 2: Reiniciar o computador

### Passo 3: Instalar GCC no Ubuntu
Abra o "Ubuntu" do menu iniciar e execute:
```bash
sudo apt update
sudo apt install build-essential
gcc --version
```

### Passo 4: Navegar até a pasta do projeto
```bash
cd /mnt/c/Users/amari/Documents/projetos/Faculdade/prog-par
```

Depois compile normalmente:
```bash
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
./ompmultmat
```

---

## ✅ Após Instalar

### 1. Feche TODOS os terminais/PowerShell abertos

### 2. Abra um NOVO PowerShell e navegue para o projeto:
```powershell
cd C:\Users\amari\Documents\projetos\Faculdade\prog-par
```

### 3. Verifique se o GCC está funcionando:
```powershell
gcc --version
```

### 4. Compile o programa:
```powershell
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c
```

Se aparecer algum erro sobre OpenMP, tente:
```powershell
gcc -fopenmp -O2 -o ompmultmat ompmultmat.c
```

### 5. Execute um teste:
```powershell
echo 512 | .\ompmultmat.exe
```

---

## 🆘 Problemas Comuns

### "gcc não é reconhecido"
- Você adicionou ao PATH?
- Fechou e abriu um novo terminal?
- O caminho está correto? Verifique se `gcc.exe` existe na pasta

### "undefined reference to 'omp_get_wtime'"
- Você usou a flag `-fopenmp`?
- Tente reinstalar o MinGW com suporte a OpenMP

### "This application requires the MSVCR120.dll"
- Baixe e instale: https://www.microsoft.com/en-us/download/details.aspx?id=40784

---

## 📞 Qual Opção Escolher?

| Opção | Dificuldade | Tempo | Recomendado Para |
|-------|-------------|-------|------------------|
| **MSYS2** | ⭐⭐ Fácil | ~10 min | Iniciantes |
| **Winlibs** | ⭐⭐⭐ Médio | ~5 min | Quem prefere portável |
| **Chocolatey** | ⭐ Muito Fácil | ~5 min | Quem já usa Choco |
| **WSL** | ⭐⭐⭐⭐ Avançado | ~15 min | Quem conhece Linux |

**Recomendação:** Use **MSYS2** - é mais fácil e mantém tudo atualizado.

---

## 🔄 Depois de Instalar, Volte e Execute:

```powershell
# Compilar
gcc -fopenmp -O3 -march=native -o ompmultmat ompmultmat.c

# Testar
echo 512 | .\ompmultmat.exe

# Se tudo funcionar, execute o benchmark:
.\run_benchmarks.ps1
```

---

**Boa sorte! 🚀**

