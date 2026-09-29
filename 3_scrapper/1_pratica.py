import requests
from bs4 import BeautifulSoup

url = 'https://books.toscrape.com/index.html'
resposta = requests.get(url)  # baixa a página
resposta.encoding = resposta.apparent_encoding  # deixa o chardet detectar de verdade
sopa = BeautifulSoup(resposta.text, 'html.parser')  # transforma o HTML em algo navegável

for livro in sopa.select('.product_pod'):  # um .product_pod por livro
    titulo = livro.h3.a['title']  # título completo fica no atributo title do link
    preco = livro.select_one('.price_color').get_text()  # texto do preço
    print(f'{titulo}: {preco}')