# Script para auxiliar na instalação do MinGW-w64
# Execute como Administrador

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalador Auxiliar MinGW-w64" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se já está instalado
$gccPath = Get-Command gcc -ErrorAction SilentlyContinue
if ($gccPath) {
    Write-Host "✓ GCC já está instalado!" -ForegroundColor Green
    gcc --version
    Write-Host ""
    Write-Host "Você já pode compilar o programa!" -ForegroundColor Green
    exit 0
}

Write-Host "GCC não encontrado. Vamos instalar!" -ForegroundColor Yellow
Write-Host ""

# Opções de instalação
Write-Host "Escolha o método de instalação:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. MSYS2 (Recomendado - Automático com Chocolatey)" -ForegroundColor Green
Write-Host "2. Download Manual do Winlibs" -ForegroundColor Yellow
Write-Host "3. WSL (Ubuntu no Windows)" -ForegroundColor Blue
Write-Host "4. Sair" -ForegroundColor Red
Write-Host ""

$choice = Read-Host "Digite sua escolha (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Verificando Chocolatey..." -ForegroundColor Yellow
        
        $chocoPath = Get-Command choco -ErrorAction SilentlyContinue
        if (-not $chocoPath) {
            Write-Host "Chocolatey não instalado. Instalando..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "IMPORTANTE: Este script precisa ser executado como ADMINISTRADOR!" -ForegroundColor Red
            Write-Host "Pressione qualquer tecla para continuar ou Ctrl+C para cancelar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            Write-Host ""
            Write-Host "✓ Chocolatey instalado!" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Instalando MSYS2 e MinGW..." -ForegroundColor Yellow
        choco install msys2 -y
        
        Write-Host ""
        Write-Host "Configurando MSYS2..." -ForegroundColor Yellow
        
        # Adicionar ao PATH
        $mingwPath = "C:\tools\msys64\mingw64\bin"
        if (Test-Path $mingwPath) {
            $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            if ($currentPath -notlike "*$mingwPath*") {
                [Environment]::SetEnvironmentVariable("Path", "$currentPath;$mingwPath", "Machine")
                Write-Host "✓ Adicionado ao PATH" -ForegroundColor Green
            }
        }
        
        Write-Host ""
        Write-Host "Instalando GCC via MSYS2..." -ForegroundColor Yellow
        & C:\tools\msys64\usr\bin\bash.exe -lc "pacman -Syu --noconfirm"
        & C:\tools\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm mingw-w64-x86_64-gcc mingw-w64-x86_64-openmp"
        
        Write-Host ""
        Write-Host "✓ Instalação concluída!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANTE: Feche e abra um NOVO terminal PowerShell" -ForegroundColor Red
        Write-Host "Depois execute: gcc --version" -ForegroundColor Yellow
    }
    
    "2" {
        Write-Host ""
        Write-Host "Abrindo página de download do Winlibs..." -ForegroundColor Yellow
        Start-Process "https://winlibs.com/"
        
        Write-Host ""
        Write-Host "INSTRUÇÕES:" -ForegroundColor Cyan
        Write-Host "1. Baixe a versão UCRT runtime com POSIX threads" -ForegroundColor White
        Write-Host "2. Extraia o ZIP para C:\mingw64" -ForegroundColor White
        Write-Host "3. Execute novamente este script e escolha opção 5 para adicionar ao PATH" -ForegroundColor White
        Write-Host ""
        Write-Host "Ou siga as instruções em INSTALACAO_COMPILADOR.md" -ForegroundColor Yellow
    }
    
    "3" {
        Write-Host ""
        Write-Host "Instalando WSL..." -ForegroundColor Yellow
        Write-Host "Isso pode demorar alguns minutos..." -ForegroundColor Yellow
        Write-Host ""
        
        wsl --install
        
        Write-Host ""
        Write-Host "✓ WSL instalado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANTE: Você precisa REINICIAR o computador" -ForegroundColor Red
        Write-Host "Após reiniciar, abra 'Ubuntu' do menu iniciar e execute:" -ForegroundColor Yellow
        Write-Host "  sudo apt update" -ForegroundColor White
        Write-Host "  sudo apt install build-essential" -ForegroundColor White
    }
    
    "4" {
        Write-Host "Saindo..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host "Opção inválida!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

