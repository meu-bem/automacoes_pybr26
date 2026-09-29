from pathlib import Path
import shutil

pasta = Path('1_organização/pasta_pagunçada')  # pasta a organizar

# extensão -> nome da subpasta de destino
destinos = {
    '.pdf': 'Documentos',
    '.jpg': 'Imagens',
    '.png': 'Imagens',
    '.zip': 'Compactados',
    '.mp4': 'Videos',
    '.xlsx': 'Planilhas'
}

for arquivo in pasta.iterdir():  # percorre tudo que está dentro da pasta
    # só move arquivos (não pastas) com extensão conhecida
    if arquivo.is_file() and arquivo.suffix in destinos:
        pasta_destino = pasta / destinos[arquivo.suffix]
        pasta_destino.mkdir(exist_ok=True)  # cria a subpasta se ainda não existir
        shutil.move(arquivo, pasta_destino / arquivo.name)  # move o arquivo