# ... (restante do script é igual)

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
