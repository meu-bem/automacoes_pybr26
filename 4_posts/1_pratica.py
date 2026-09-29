import csv
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

PASTA_PRODUTOS = Path('4_posts/produtos')
PASTA_SAIDA = Path('4_posts/cards_prontos')
PASTA_SAIDA.mkdir(exist_ok=True)  # cria a pasta de saída

TAMANHO_CARD = (800, 800)
TAMANHO_FOTO = (760, 600)  # todas as fotos ficam exatamente deste tamanho
MARGEM_TOPO = 20

fonte_nome = ImageFont.truetype('DejaVuSans-Bold.ttf', 40)
fonte_preco = ImageFont.truetype('DejaVuSans-Bold.ttf', 56)

with open(PASTA_PRODUTOS / 'produtos.csv', encoding='utf-8') as csvfile:
    for linha in csv.DictReader(csvfile):  # cada linha vira um dicionário
        foto = Image.open(PASTA_PRODUTOS / linha['arquivo'])
        # redimensiona e corta o excesso, centralizado
        foto = ImageOps.fit(foto, TAMANHO_FOTO, method=Image.LANCZOS, centering=(0.5, 0.5))

        card = Image.new('RGB', TAMANHO_CARD, 'white')  # fundo branco
        x_centro = (TAMANHO_CARD[0] - TAMANHO_FOTO[0]) // 2  # centraliza a foto na horizontal
        card.paste(foto, (x_centro, MARGEM_TOPO))

        desenho = ImageDraw.Draw(card)
        desenho.text((x_centro, 650), linha['nome'], font=fonte_nome, fill='black')
        desenho.text((x_centro, 710), f'R$ {linha["preco"]}', font=fonte_preco, fill='#ca1414')

        card.save(PASTA_SAIDA / f'card_{linha["arquivo"]}')

print(f'{len(list(PASTA_SAIDA.iterdir()))} cards gerados em {PASTA_SAIDA}/')