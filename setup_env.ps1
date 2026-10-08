# Setup de Ambiente no Windows (PowerShell) com Salvaguardas
$ErrorActionPreference = "Stop"

$PYTHON_VERSION = "3.10.14"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Configuração do ambiente (Windows)" -ForegroundColor Cyan
Write-Host "Python pretendido: $PYTHON_VERSION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Checagem de Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Git não foi encontrado no PATH do sistema." -ForegroundColor Yellow
    Write-Host "    Recomendamos instalar o Git para Windows: https://git-scm.com/download/win" -ForegroundColor Yellow
}

# 2. Ajuste de TLS/SSL para downloads seguros em versões legadas do PowerShell
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Verbose "Aviso ao definir TLS 1.2: $_"
}

# 3. Localizar ou Instalar o pyenv-win
$pyenvPath = "$env:USERPROFILE\.pyenv\pyenv-win\bin"
$pyenvShims = "$env:USERPROFILE\.pyenv\pyenv-win\shims"

if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
    if (Test-Path $pyenvPath) {
        $env:PATH = "$pyenvPath;$pyenvShims;$env:PATH"
    }
}

if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
    Write-Host "[*] pyenv-win não encontrado. Instalando..." -ForegroundColor Yellow
    $installer = "$env:TEMP\install-pyenv-win.ps1"
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile $installer
        & $installer
    } catch {
        Write-Host "[!] Erro ao baixar/instalar pyenv-win: $_" -ForegroundColor Red
        exit 1
    } finally {
        if (Test-Path $installer) { Remove-Item $installer -Force -ErrorAction SilentlyContinue }
    }

    # Carregar pyenv-win no PATH da sessão atual
    if (Test-Path $pyenvPath) {
        $env:PATH = "$pyenvPath;$pyenvShims;$env:PATH"
    } else {
        Write-Host "[!] Não foi possível localizar $pyenvPath após instalação." -ForegroundColor Red
        Write-Host "    Feche e abra uma nova janela do PowerShell para tentar novamente." -ForegroundColor Red
        exit 1
    }
    Write-Host "[+] pyenv-win instalado com sucesso!" -ForegroundColor Green
}

# 4. Atualizar lista de versões disponíveis no pyenv
Write-Host "[*] Atualizando definições do pyenv..." -ForegroundColor Blue
try {
    & pyenv update
} catch {
    Write-Host "[AVISO] Falha ao executar 'pyenv update'. Continuando com as versões locais em cache..." -ForegroundColor Yellow
}

# 5. Instalar versão específica do Python se ausente
$installedVersions = @(& pyenv versions --bare 2>$null)
if ($installedVersions -notcontains $PYTHON_VERSION) {
    Write-Host "[*] Instalando Python $PYTHON_VERSION via pyenv (download do binário oficial)..." -ForegroundColor Blue
    & pyenv install $PYTHON_VERSION
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Erro ao instalar Python $PYTHON_VERSION via pyenv." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[*] Python $PYTHON_VERSION já se encontra instalado no pyenv." -ForegroundColor Green
}

# 6. Definir versão local
Write-Host "[*] Definindo versão local do projeto para $PYTHON_VERSION..." -ForegroundColor Blue
& pyenv local $PYTHON_VERSION
& pyenv rehash 2>$null

# 7. Localizar interpretador Python exato
$pyenvRootVersion = "$env:USERPROFILE\.pyenv\pyenv-win\versions\$PYTHON_VERSION\python.exe"
if (Test-Path $pyenvRootVersion) {
    $pythonExec = $pyenvRootVersion
} else {
    $pythonExec = (Get-Command python -ErrorAction SilentlyContinue).Source
}

if (-not $pythonExec) {
    Write-Host "[!] Não foi possível determinar o executável do Python." -ForegroundColor Red
    exit 1
}

Write-Host "[*] Usando Python: $pythonExec" -ForegroundColor Green

# 8. Criar o ambiente virtual .venv e checar integridade
$needCreateVenv = $false
if (-not (Test-Path ".venv")) {
    $needCreateVenv = $true
} elseif (-not (Test-Path ".\.venv\Scripts\python.exe") -or -not (Test-Path ".\.venv\Scripts\Activate.ps1")) {
    Write-Host "[!] Pasta .venv existe mas está incompleta/corrompida. Recriando..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".venv"
    $needCreateVenv = $true
}

if ($needCreateVenv) {
    Write-Host "[*] Criando ambiente virtual em .venv..." -ForegroundColor Blue
    & $pythonExec -m venv .venv
} else {
    Write-Host "[*] Diretório .venv válido já existente." -ForegroundColor Green
}

# 9. Ativar a venv e instalar dependências
$venvPython = ".\.venv\Scripts\python.exe"
$venvPip    = ".\.venv\Scripts\pip.exe"

if (-not (Test-Path $venvPython)) {
    Write-Host "[!] Erro: Interpretador da venv ($venvPython) não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Atualizando pip na venv..." -ForegroundColor Blue
& $venvPython -m pip install --upgrade pip

if (Test-Path "requirements.txt") {
    Write-Host "[*] Instalando dependências de requirements.txt..." -ForegroundColor Blue
    & $venvPip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Houve erros ao instalar algumas dependências. Verifique o log acima." -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] AVISO: requirements.txt não encontrado neste diretório." -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "✔ Ambiente configurado com sucesso!" -ForegroundColor Green
Write-Host "Para ativar o ambiente para desenvolvimento:" -ForegroundColor Green
Write-Host "   .\.venv\Scripts\Activate.ps1" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green
