import time
from urllib.parse import quote

import requests
import schedule


LOCAL = 'Terra Santa'  # cidade, aeroporto, coordenadas... (veja as opções abaixo)
HORARIO = '21:28'  # horário diário, formato 'HH:MM'


def rotina_diaria():
    # monta a URL do wttr.in com o local já convertido para formato de URL
    url = f'https://wttr.in/{quote(LOCAL)}?format=%l:+%t+%C&lang=pt&m'
    resposta = requests.get(url, timeout=10)  # timeout evita travar sem internet
    print(resposta.text)


schedule.every().day.at(HORARIO).do(rotina_diaria)  # agenda a função

while True:
    schedule.run_pending()  # executa o que estiver na hora
    time.sleep(60)  # espera 1 minuto antes de conferir de novo