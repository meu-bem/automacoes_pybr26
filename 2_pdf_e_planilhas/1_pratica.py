from pypdf import PdfReader, PdfWriter

# --- 1. Juntar vários PDFs em um só ---
writer = PdfWriter()  # PDF de saída, ainda vazio

arquivos = [
    '2_pdf_e_planilhas/amostras/arquivo1.pdf',
    '2_pdf_e_planilhas/amostras/arquivo2.pdf',
]

for caminho in arquivos:
    writer.append(caminho)  # anexa o PDF inteiro ao final

writer.write('2_pdf_e_planilhas/amostras/juntado.pdf')  # grava em disco
writer.close()


# --- 2. Extrair um intervalo de páginas (ex: páginas 2 a 4) ---
leitor = PdfReader('2_pdf_e_planilhas/amostras/juntado.pdf')
writer = PdfWriter()

for i in range(1, 4):  # índice começa em 0, então 1:4 = páginas 2, 3 e 4
    writer.add_page(leitor.pages[i])

writer.write('2_pdf_e_planilhas/amostras/trecho.pdf')
writer.close()


# --- 3. Girar páginas (ex: girar tudo 90 graus) ---
leitor = PdfReader('2_pdf_e_planilhas/amostras/trecho.pdf')
writer = PdfWriter()

for pagina in leitor.pages:
    pagina.rotate(90)  # gira no sentido horário
    writer.add_page(pagina)

writer.write('2_pdf_e_planilhas/amostras/girado.pdf')
writer.close()


# --- 4. Reordenar páginas (ex: inverter a ordem) ---
leitor = PdfReader('2_pdf_e_planilhas/amostras/girado.pdf')
writer = PdfWriter()

for page in leitor.pages[::-1]:
    writer.add_page(page)

writer.write('2_pdf_e_planilhas/amostras/reordenado.pdf')
writer.close()