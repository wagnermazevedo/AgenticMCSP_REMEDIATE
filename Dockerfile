# Use a imagem base Python slim
FROM python:3.11-slim

# Instalação de dependências do sistema e Cloud Custodian
# Adicione ferramentas de CLI multi-cloud se necessário, ou garanta que o CodeBuild as inclua.
# Exemplo de instalação básica do Custodian:
RUN pip install --no-cache-dir \
    cloud-custodian \
    c7n-aws \
    c7n-azure \
    c7n-gcp \
    boto3 \
    # Adicione pandas ou outras libs para CSV/HTML se for fazer o post-processamento no Python
    pandas

# Diretório de trabalho dentro do container
WORKDIR /var/task

# Copia os scripts de execução
COPY entrypoint.sh .
COPY run-remediation.sh .
RUN chmod +x entrypoint.sh run-remediation.sh

# Copia o manipulador Python do Lambda (Onde a orquestração e chamada shell acontece)
COPY lambda_function.py .

# Copia os diretórios de políticas Custodian para um caminho fixo
COPY policies/ /custodian/policies/

# Define o ENTRYPOINT. 
# Para o runtime customizado em imagem de container Lambda, o ENTRYPOINT é o que inicia o ambiente.
# Este é o ponto de entrada principal do seu container.
ENTRYPOINT ["./entrypoint.sh"]

# O CMD é o que o ENTRYPOINT executa, geralmente o handler do Lambda.
# O ENTRYPOINT.sh chamará esse CMD, se configurado. Para Lambda, o formato é [arquivo.função]
# Mas como você está usando um shell script para orquestração, vamos manter o CMD do Python.
CMD ["lambda_function.py"] 
# Nota: A AWS Lambda irá sobrescrever isso se o seu ENTRYPOINT não o usar explicitamente.
# Para este cenário, o ENTRYPOINT.sh será o ponto de partida.
