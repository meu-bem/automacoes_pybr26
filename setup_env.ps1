# Setup de Ambiente no Windows (PowerShell) com Salvaguardas
$ErrorActionPreference = "Stop"

# 3.10.11 é a última 3.10 com binário para Windows (3.10.12+ só têm código-fonte)
$PYTHON_VERSION = "3.10.11"

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

# 3. Preferir um Python 3.10+ já instalado (não exige admin nem rede)
function Find-SystemPython {
    $candidates = @(
        @("py", "-3.10"), @("py", "-3.11"), @("py", "-3.12"), @("py", "-3"),
        @("python"), @("python3")
    )
    foreach ($c in $candidates) {
        $cmd = Get-Command $c[0] -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }
        $extra = @($c | Select-Object -Skip 1)
        try {
            $exe = & $cmd.Source @extra -c "import sys; print(sys.executable) if (3,10) <= sys.version_info[:2] < (3,13) else None" 2>$null
            if ($LASTEXITCODE -eq 0 -and $exe -and (Test-Path $exe) -and $exe -notlike "*WindowsApps*") { return $exe }
        } catch { }
    }
    return $null
}

$pythonExec = Find-SystemPython

if ($pythonExec) {
    Write-Host "[*] Python existente encontrado, pulando pyenv-win." -ForegroundColor Green
} else {
    Write-Host "[*] Nenhum Python 3.10-3.12 encontrado. Usando pyenv-win (instalação por usuário, sem admin)..." -ForegroundColor Yellow

    $pyenvPath = "$env:USERPROFILE\.pyenv\pyenv-win\bin"
    $pyenvShims = "$env:USERPROFILE\.pyenv\pyenv-win\shims"
    if (-not (Get-Command pyenv -ErrorAction SilentlyContinue) -and (Test-Path $pyenvPath)) {
        $env:PATH = "$pyenvPath;$pyenvShims;$env:PATH"
    }

    if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
        Write-Host "[*] pyenv-win não encontrado. Instalando..." -ForegroundColor Yellow
        $installer = "$env:TEMP\install-pyenv-win.ps1"
        try {
            Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile $installer
            & $installer
        } catch {
            Write-Host "[!] Erro ao baixar/instalar pyenv-win: $_" -ForegroundColor Red
            Write-Host "    Alternativa sem admin: instale o Python 3.10.11 (ou 3.11/3.12) pelo instalador oficial," -ForegroundColor Red
            Write-Host "    marcando 'Install just for me' (https://www.python.org/downloads/windows/) e rode o script de novo." -ForegroundColor Red
            exit 1
        } finally {
            if (Test-Path $installer) { Remove-Item $installer -Force -ErrorAction SilentlyContinue }
        }
        if (Test-Path $pyenvPath) {
            $env:PATH = "$pyenvPath;$pyenvShims;$env:PATH"
        } else {
            Write-Host "[!] Não foi possível localizar $pyenvPath após instalação." -ForegroundColor Red
            Write-Host "    Feche e abra uma nova janela do PowerShell para tentar novamente." -ForegroundColor Red
            exit 1
        }
        Write-Host "[+] pyenv-win instalado com sucesso!" -ForegroundColor Green
    }

    $installedVersions = @(& pyenv versions --bare 2>$null)
    if ($installedVersions -notcontains $PYTHON_VERSION) {
        Write-Host "[*] Instalando Python $PYTHON_VERSION via pyenv..." -ForegroundColor Blue
        & pyenv install $PYTHON_VERSION
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!] Erro ao instalar Python $PYTHON_VERSION via pyenv." -ForegroundColor Red
            exit 1
        }
    }

    & pyenv local $PYTHON_VERSION
    & pyenv rehash 2>$null
    $pythonExec = "$env:USERPROFILE\.pyenv\pyenv-win\versions\$PYTHON_VERSION\python.exe"
}

if (-not $pythonExec -or -not (Test-Path $pythonExec)) {
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

if (-not (Test-Path $venvPython)) {
    Write-Host "[!] Erro: Interpretador da venv ($venvPython) não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Atualizando pip na venv..." -ForegroundColor Blue
& $venvPython -m pip install --upgrade pip

if (Test-Path "requirements.txt") {
    Write-Host "[*] Instalando dependências de requirements.txt..." -ForegroundColor Blue
    # Vários pacotes (PyAutoGUI, MouseInfo, PyScreeze...) só têm código-fonte: precisam de setuptools/wheel na venv
    & $venvPython -m pip install --upgrade setuptools wheel
    & $venvPython -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[*] Tentando novamente sem isolamento de build..." -ForegroundColor Yellow
        & $venvPython -m pip install --no-build-isolation -r requirements.txt
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Houve erros ao instalar as dependências. Verifique o log acima." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[!] AVISO: requirements.txt não encontrado neste diretório." -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "[OK] Ambiente configurado com sucesso!" -ForegroundColor Green
Write-Host "Para ativar o ambiente para desenvolvimento:" -ForegroundColor Green
Write-Host "   .\.venv\Scripts\Activate.ps1" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green
