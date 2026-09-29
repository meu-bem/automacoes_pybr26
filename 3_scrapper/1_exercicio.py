from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

BASE = 'https://books.toscrape.com/catalogue/category/books/'
CATEGORIAS = ['mystery_3', 'travel_2']  # nome da pasta de cada categoria no site


def pegar_livros(categoria):
    url = f'{BASE}{categoria}/index.html'
    titulos = []
    precos = []

    while url:  # repete enquanto houver próxima página
        resposta = requests.get(url, timeout=10)
        resposta.encoding = resposta.apparent_encoding
        sopa = BeautifulSoup(resposta.text, 'html.parser')

        for livro in sopa.select('.product_pod'):
            titulos.append(livro.h3.a['title'])
            preco = livro.select_one('.price_color').get_text(strip=True)
            precos.append(float(preco.replace('£', '')))  # tira o £ e converte para número

        proximo = sopa.select_one('li.next a')  # botão "next", se existir
        if proximo:
            url = urljoin(url, proximo['href'])  # monta o link da próxima página
        else:
            url = None  # sem próxima página, o while termina

    return titulos, precos


for categoria in CATEGORIAS:
    titulos, precos = pegar_livros(categoria)

    menor_preco = min(precos)
    titulo_mais_barato = titulos[precos.index(menor_preco)]  # mesma posição na lista de títulos
    media = sum(precos) / len(precos)

    print(f'--- {categoria} ({len(precos)} livros) ---')
    print('Preços:', precos)
    print(f'Mais barato: {titulo_mais_barato} (£{menor_preco:.2f})')
    print(f'Média: £{media:.2f}')