import pandas as pd

tabela = pd.read_excel('2_pdf_e_planilhas/amostras/vendas_bagunca.xlsx')  # lê a planilha
tabela = tabela.dropna()
tabela['vendedor'] = tabela['vendedor'].str.split().str.join(' ').str.title()
# soma o valor por vendedor e ordena do maior para o menor
resumo = tabela.groupby('vendedor')['valor'].sum().sort_values(ascending=False)
resumo.to_excel('2_pdf_e_planilhas/amostras/resumo_vendas.xlsx')  # salva o resumo