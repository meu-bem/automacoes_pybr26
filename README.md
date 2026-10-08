# Automações Python Brasil 2026

Instruções para clonar o repositório e configurar o ambiente de desenvolvimento usando `pyenv` e `venv` com Python **3.10.14**, tanto no **Linux** quanto no **Windows**.

---

## ⚡ Configuração Rápida via Script (Recomendado)

Se preferir não executar cada comando manualmente, utilize os scripts inclusos no repositório.

### 1. Clone o repositório na branch `main`:
```bash
git clone -b main git@github.com:meu-bem/automacoes_pybr26.git
cd automacoes_pybr26
```

### 2. Execute o script para o seu sistema:

#### 🐧 Linux / macOS:
```bash
chmod +x setup_env.sh
./setup_env.sh
```

#### 🪟 Windows (PowerShell):
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\setup_env.ps1
```

> O script automaticamente:
> - Instala o `pyenv` (caso não esteja instalado);
> - Instala o Python **3.10.14** e define como local (`pyenv local 3.10.14`);
> - Cria a pasta `.venv` via `python -m venv .venv`;
> - Ativa a venv, atualiza o `pip` e instala o `requirements.txt`;
> - Desativa a venv ao finalizar.

Para começar a trabalhar após a execução do script:
- **Linux:** `source .venv/bin/activate`
- **Windows:** `.\.venv\Scripts\Activate.ps1`

---

## 📖 Configuração Passo a Passo Manual

Caso prefira executar o processo manualmente etapa por etapa, siga as instruções abaixo:

### 1. Clonar o Repositório

Como a branch padrão do repositório pode estar apontando para outra branch (como `solutions`), clone especificando diretamente a branch `main`:

```bash
git clone -b main git@github.com:meu-bem/automacoes_pybr26.git
cd automacoes_pybr26
```

> **Nota:** Caso utilize HTTPS em vez de SSH:
> ```bash
> git clone -b main https://github.com/meu-bem/automacoes_pybr26.git
> cd automacoes_pybr26
> ```

---

### 🐧 Linux (Ubuntu/Debian e derivados)

#### 2.1. Instalar dependências para compilar o Python
Antes de instalar versões de Python via `pyenv`, instale as bibliotecas necessárias:

```bash
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git
```

#### 2.2. Instalar o `pyenv`
Execute o instalador oficial:

```bash
curl https://pyenv.run | bash
```

Adicione as variáveis ao seu arquivo de configuração do shell (`~/.bashrc` ou `~/.zshrc`):

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```

Recarregue o shell:
```bash
source ~/.bashrc
```

#### 2.3. Instalar o Python 3.10.14 e definir no projeto
No diretório do projeto, instale e defina a versão local:

```bash
pyenv install 3.10.14
pyenv local 3.10.14
```

Verifique se a versão ativa é a 3.10.14:
```bash
python --version
```

#### 2.4. Criar e ativar o ambiente virtual (.venv)
```bash
python -m venv .venv
source .venv/bin/activate
```

#### 2.5. Instalar as dependências
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 2.6. Desativar o ambiente virtual
Quando terminar de trabalhar:
```bash
deactivate
```

---

### 🪟 Windows (PowerShell)

No Windows, utilize o `pyenv-win`.

#### 2.1. Instalar o `pyenv-win`
Abra o PowerShell como Administrador ou usuário comum e execute:

```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

> **Atenção:** Feche e reabra o PowerShell para carregar as novas variáveis de ambiente.

#### 2.2. Instalar o Python 3.10.14 e definir no projeto
Navegue até a pasta do projeto no PowerShell:

```powershell
pyenv update
pyenv install 3.10.14
pyenv local 3.10.14
```

Verifique a versão ativa:
```powershell
python --version
```

#### 2.3. Criar e ativar o ambiente virtual (.venv)
> **Dica:** Caso o PowerShell bloqueie a execução de scripts, habilite temporariamente rodando:
> `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

*(Se estiver utilizando o `cmd.exe`, utilize `.\.venv\Scripts\activate.bat`)*

#### 2.4. Instalar as dependências
```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

#### 2.5. Desativar o ambiente virtual
Quando terminar de trabalhar:
```powershell
deactivate
```

---

## 3. Resumo dos Comandos Rápidos Manuais

| Etapa | Linux | Windows (PowerShell) |
|---|---|---|
| **Clonar repo** | `git clone -b main <URL>` | `git clone -b main <URL>` |
| **Instalar Python** | `pyenv install 3.10.14` | `pyenv install 3.10.14` |
| **Definir versão** | `pyenv local 3.10.14` | `pyenv local 3.10.14` |
| **Criar venv** | `python -m venv .venv` | `python -m venv .venv` |
| **Ativar venv** | `source .venv/bin/activate` | `.\.venv\Scripts\Activate.ps1` |
| **Instalar deps** | `pip install -r requirements.txt` | `pip install -r requirements.txt` |
| **Desativar venv** | `deactivate` | `deactivate` |
