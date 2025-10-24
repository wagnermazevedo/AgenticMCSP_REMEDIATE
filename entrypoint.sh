#!/bin/bash
# 
# entrypoint.sh - Ponto de entrada padrão para o runtime do Lambda em container.
#
# O AWS Lambda espera que o ENTRYPOINT execute o manipulador (handler) principal.
#

set -e

# Se 'CMD' foi especificado, executa o comando.
# Em um ambiente Lambda, o CMD seria o caminho para o runtime/handler.
# Ex: Executando o script Python principal do Lambda.
exec /usr/bin/python3 lambda_function.py
