#!/bin/bash

# Verificar se o script está sendo executado com o Bash
if [ -z "$BASH" ]; then
    echo "Este script requer o Bash para execução. Por favor, execute com bash."
    echo Exemplo:
    echo bash copiarTodoDriver.sh
    exit 1
fi


caminho_arquivo_conf="/etc/sync-hd/monitor.conf"

# Verificar se o arquivo existe
if [ -e "$caminho_arquivo_conf" ]; then
    # Carregar as variáveis do arquivo de configuração
    source "$caminho_arquivo_conf"
else
    # Exibir mensagem de erro e sair do script
    echo "Erro: O arquivo de configuração não foi encontrado: $caminho_arquivo_conf"
    exit 1
fi


echo Iniciando copia da pastal local: $enderecoHD
echo para servidor google drive de configuração no rclone de nome: $servidorRclone
nice -n 15 rclone copy --transfers 6 --checkers 10 --checksum --update "$enderecoHD" "$servidorRclone":
sleep 10
cpulimit --pid=$(pgrep -o rclone) --limit=40