#!/bin/bash
# 
# entrypoint.sh - Ponto de entrada para o runtime do Lambda em container.
#
# A AWS espera que o ENTRYPOINT não retorne, mas sim execute o processo principal.
#

set -e

# Executa o manipulador principal do Lambda. 
# O Lambda Runtime Interface Emulator (RIE) irá invocar a função 'handler' dentro de 'lambda_function.py'
# quando um evento da API Gateway (ou outro) chegar.
exec /usr/bin/python3 -m awslambdaric lambda_function.handler 
# Nota: É comum usar 'awslambdaric' para o ambiente container do Lambda, 
# mas o CodeBuild (Ubuntu) não o terá por padrão.
# Se você está usando a imagem base do CodeBuild, o melhor é o ENTRYPOINT do Dockerfile ser a chamada do script.

# ALTERNATIVA (Mais simples, mas requer que seu lambda_function.py tenha o loop de eventos):
# exec /usr/bin/python3 lambda_function.py
