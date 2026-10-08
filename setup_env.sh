#!/usr/bin/env bash
set -e

PYTHON_VERSION="3.10.14"

echo "=========================================="
echo "Configuração do ambiente (Linux / macOS)"
echo "Python pretendido: $PYTHON_VERSION"
echo "=========================================="

# 1. Checagem de ferramentas básicas do sistema
for cmd in curl git; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[!] Erro: '$cmd' não está instalado."
        if command -v apt &> /dev/null; then
            echo "    Execute: sudo apt update && sudo apt install -y $cmd"
        elif command -v dnf &> /dev/null; then
            echo "    Execute: sudo dnf install -y $cmd"
        elif command -v pacman &> /dev/null; then
            echo "    Execute: sudo pacman -S --noconfirm $cmd"
        fi
        exit 1
    fi
done

# 2. Verificar dependências de compilação do Python no Linux (Ubuntu/Debian)
if command -v apt &> /dev/null; then
    MISSING_PKGS=()
    BUILD_DEPS=(make build-essential libssl-dev zlib1g-dev libbz2-dev \
                libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils \
                tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev)
    for pkg in "${BUILD_DEPS[@]}"; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            MISSING_PKGS+=("$pkg")
        fi
    done

    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        echo "[!] Pacotes de compilação ausentes detectados: ${MISSING_PKGS[*]}"
        if [ "$EUID" -eq 0 ]; then
            echo "[*] Instalando dependências de compilação como root..."
            apt update && apt install -y "${MISSING_PKGS[@]}"
        elif command -v sudo &> /dev/null && [ -t 0 ]; then
            echo "[*] Solicitando permissão sudo para instalar dependências de compilação..."
            sudo apt update && sudo apt install -y "${MISSING_PKGS[@]}"
        else
            echo "[AVISO] Não foi possível instalar pacotes automaticamente sem sudo/interação."
            echo "        Caso o 'pyenv install' falhe na compilação, execute antes:"
            echo "        sudo apt update && sudo apt install -y ${MISSING_PKGS[*]}"
        fi
    fi
fi

# 3. Localizar ou Instalar o pyenv
if ! command -v pyenv &> /dev/null; then
    if [ -d "$HOME/.pyenv/bin" ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
    fi
fi

if ! command -v pyenv &> /dev/null; then
    echo "[*] pyenv não encontrado. Instalando via pyenv.run..."
    curl -fsSL https://pyenv.run | bash

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
    eval "$(pyenv init -)" 2>/dev/null || true

    echo "[+] pyenv instalado!"
    echo "[i] Para tornar o pyenv disponível em novas abas do terminal, adicione ao seu ~/.bashrc:"
    echo '    export PYENV_ROOT="$HOME/.pyenv"'
    echo '    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    echo '    eval "$(pyenv init -)"'
fi

# 4. Instalar o Python via pyenv
if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
    echo "[*] Instalando Python $PYTHON_VERSION via pyenv (pode levar alguns minutos)..."
    pyenv install -s "$PYTHON_VERSION" || {
        echo "[!] Falha ao compilar/instalar o Python $PYTHON_VERSION."
        echo "    Verifique se as dependências de compilação (build-essential, libssl-dev, etc) estão presentes."
        exit 1
    }
else
    echo "[*] Python $PYTHON_VERSION já se encontra instalado no pyenv."
fi

# 5. Definir versão local para o projeto
echo "[*] Definindo versão local do projeto para $PYTHON_VERSION..."
pyenv local "$PYTHON_VERSION"

# Obter o caminho absoluto do interpretador Python correto
PYTHON_EXEC="$(pyenv which python)"
echo "[*] Interpretador Python ativo: $PYTHON_EXEC ($($PYTHON_EXEC --version))"

# 6. Criar o ambiente virtual .venv
if [ ! -d ".venv" ]; then
    echo "[*] Criando ambiente virtual em .venv..."
    "$PYTHON_EXEC" -m venv .venv
else
    echo "[*] Diretório .venv já existe."
fi

# 7. Validar integridade da venv
if [ ! -f ".venv/bin/activate" ]; then
    echo "[!] Erro: .venv/bin/activate não encontrado. A criação do venv pode ter sido interrompida."
    echo "[*] Recriando .venv..."
    rm -rf .venv
    "$PYTHON_EXEC" -m venv .venv
fi

# 8. Ativar a venv e instalar dependências
echo "[*] Ativando .venv..."
# shellcheck source=/dev/null
source .venv/bin/activate

echo "[*] Atualizando pip..."
pip install --upgrade pip

if [ -f "requirements.txt" ]; then
    echo "[*] Instalando pacotes do requirements.txt..."
    pip install -r requirements.txt
else
    echo "[!] AVISO: requirements.txt não encontrado neste diretório."
fi

echo "[*] Desativando ambiente virtual..."
deactivate

echo "=========================================="
echo "✔ Ambiente configurado com sucesso!"
echo "Para ativar o ambiente para desenvolvimento:"
echo "  source .venv/bin/activate"
echo "=========================================="
