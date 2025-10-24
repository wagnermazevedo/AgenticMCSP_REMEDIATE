#!/bin/bash
#
# run-remediation.sh - Script principal para execução do Cloud Custodian.
#
# Uso esperado: 
# ./run-remediation.sh <CLIENTE> <PROVEDOR> <REGIAO> <CONTA_ID> <DRY_RUN_FLAG>

# Configura para abortar em caso de erro
set -e

# =================================================================
# 1. Definição de Variáveis e Argumentos
# =================================================================

CLIENTE="$1"
PROVEDOR="$2"
REGIAO="$3"
CONTA_ID="$4"
DRY_RUN_FLAG="$5" # Pode ser --dryrun ou vazio.

# Variáveis estáticas do seu ambiente
S3_REPORTS_BUCKET="agentic-mcsp-remediation-reports"
POLICIES_DIR="/custodian/policies/${PROVEDOR}" # Ex: /custodian/policies/aws
TEMP_OUTPUT_DIR="/tmp/custodian-output"

# Define o timestamp para a pasta de saída (Ex: 20251023-221421)
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Monta o caminho de saída no S3 (formato solicitado pelo usuário)
S3_OUTPUT_PATH="s3://${S3_REPORTS_BUCKET}/${CLIENTE}/${PROVEDOR}/${TIMESTAMP}/"

echo "================================================================"
echo "Iniciando Remediação do Cloud Custodian (AgenticMCSP_REMEDIATE)"
echo "----------------------------------------------------------------"
echo "Cliente: ${CLIENTE}"
echo "Provedor: ${PROVEDOR}"
echo "Conta/Sub/Projeto: ${CONTA_ID}"
echo "Modo: ${DRY_RUN_FLAG:-Execução Completa}"
echo "Caminho de Saída S3: ${S3_OUTPUT_PATH}"
echo "================================================================"

# Cria o diretório de saída temporário local
mkdir -p "$TEMP_OUTPUT_DIR"

# =================================================================
# 2. Configuração de Credenciais Específicas do Provedor
# =================================================================

case "$PROVEDOR" in
    aws)
        echo "Configurando credenciais AWS..."
        # LÓGICA DE ASSUNÇÃO DE ROLE: O Lambda assume uma role de serviço 
        # (ex: codebuild-AgenticMCSP-service-role) que tem permissão 
        # para assumir a Role do cliente (ex: arn:aws:iam::${CONTA_ID}:role/AgenticMCSP-CustodianRole).
        
        # O STS assume a role do cliente e as credenciais temporárias 
        # (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)
        # são exportadas para o ambiente do script.
        
        # Exemplo (Detalhe da implementação fica no Python/Credenciais Helper):
        # source /usr/local/bin/assume-aws-role.sh "${CONTA_ID}"

        # Se a região for necessária para o ambiente (Custodian costuma usar a da política)
        export AWS_DEFAULT_REGION="${REGIAO}"
        
        ;;
    azure)
        echo "Configurando credenciais Azure..."
        # LÓGICA AZURE: Usa Service Principal (SPN) com acesso à Subscrição ${CONTA_ID}
        # ou Managed Identity do Lambda para autenticar.
        
        # Exemplo: Autenticação via CLI ou variáveis de ambiente
        # export AZURE_TENANT_ID=...
        # export AZURE_CLIENT_ID=...
        # export AZURE_CLIENT_SECRET=...
        
        ;;
    gcp)
        echo "Configurando credenciais GCP..."
        # LÓGICA GCP: Usa Service Account para atuar no Projeto ${CONTA_ID}
        # A conta de serviço do container deve ter permissão para se autenticar.
        
        # Exemplo: Autenticação via CLI ou credenciais de aplicação padrão
        # gcloud auth activate-service-account --key-file=/path/to/keyfile.json
        # export CLOUDSDK_CORE_PROJECT="${CONTA_ID}"
        
        ;;
    *)
        echo "ERRO: Provedor de nuvem '${PROVEDOR}' não suportado ou não especificado corretamente."
        exit 1
        ;;
esac

# =================================================================
# 3. Execução do Cloud Custodian
# =================================================================

# O comando 'custodian run'
# -s: Diretório de saída local
# -r: Região alvo
# -o: Saída remota (para enviar o JSON de achados/execução para o S3)
CUSTODIAN_CMD="custodian run -s ${TEMP_OUTPUT_DIR} -r ${REGIAO} ${DRY_RUN_FLAG} -o ${S3_OUTPUT_PATH} -c ${POLICIES_DIR}"

echo "Executando: ${CUSTODIAN_CMD}"

# Executa o comando
# Note que o Custodian irá automaticamente usar as credenciais que foram configuradas no passo 2.
eval "$CUSTODIAN_CMD"

# =================================================================
# 4. Pós-processamento e Finalização
# =================================================================

echo "Remediação concluída. Inserindo o JSON de saída no S3..."
# O Custodian já enviou os arquivos JSON de execução para o S3 (graças ao -o $S3_OUTPUT_PATH).

# Passo Opcional: Geração e Upload de relatórios CSV e HTML.
# Isso requer post-processing. Como é complexo para um simples script shell, 
# vamos adicionar um placeholder, indicando que um script Python faria a conversão 
# dos arquivos JSON recém-criados em ${TEMP_OUTPUT_DIR} ou baixados do S3.

echo "Gerando relatórios CSV, HTML e JSON-ASFF (pós-processamento)..."

# EXEMPLO DE CHAMADA PARA CONVERSÃO (Assumindo um script Python para isso)
# python3 /custodian/utils/report_converter.py \
#   --input-dir ${TEMP_OUTPUT_DIR} \
#   --output-s3-path ${S3_OUTPUT_PATH} \
#   --formats csv html json-asff

echo "Limpeza de diretório temporário."
rm -rf "$TEMP_OUTPUT_DIR"

echo "================================================================"
echo "Processo de Remediação Finalizado com Sucesso. Relatórios em ${S3_OUTPUT_PATH}"
echo "================================================================"
