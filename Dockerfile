# Use uma imagem base Python slim (menor e mais rápida)
FROM python:3.11-slim

# Instalação de dependências do sistema necessárias (opcional, mas bom ter para libs como 'cryptography')
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     && rm -rf /var/lib/apt/lists/*

# Instalação do Cloud Custodian (c7n) e pacotes AWS/Multi-Cloud
# É crucial incluir os pacotes do(s) provedor(es) que você utilizará (aws, azure, gcp)
RUN pip install --no-cache-dir \
    cloud-custodian \
    c7n-aws \
    c7n-org \
    boto3

# Diretório de trabalho dentro do container
WORKDIR /var/task

# Copia o código da sua Lambda (por exemplo, lambda_handler.py) e os arquivos de política (.yml)
# O Cloud Custodian policies (.yml) deve estar disponível para o script Python da Lambda.
COPY lambda_handler.py .
# Exemplo de política:
# COPY policies/ .

# Opcional: Define variáveis de ambiente úteis
ENV CUSTODIAN_CACHE_DIR /tmp/c7n-cache

# Comando de entrada (Entrypoint) para o AWS Lambda. 
# A AWS já tem um Runtime padrão para Python, mas se a imagem for o destino final, 
# você pode definir o ENTRYPOINT e o CMD.
# Para imagem de container Lambda, o CMD deve apontar para o handler: [arquivo.função]
CMD ["lambda_handler.handler"]
