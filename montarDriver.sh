#!/bin/bash

# Verificar se o script está sendo executado com o Bash
if [ -z "$BASH" ]; then
    echo "Este script requer o Bash para execução. Por favor, execute com bash."
    echo Exemplo:
    echo bash montarDriver.sh
    exit 1
fi

caminho_arquivo_conf="monitor.conf"

# Verificar se o arquivo existe
if [ -e "$caminho_arquivo_conf" ]; then
    # Carregar as variáveis do arquivo de configuração
    source "$caminho_arquivo_conf"
else
    # Exibir mensagem de erro e sair do script
    echo "Erro: O arquivo de configuração não foi encontrado: $caminho_arquivo_conf"
    exit 1
fi

echo ============================================================================================
echo Endereço físico da partição:"$enderecoFisico"
echo Endereço da pasta a ser montada a partição local:"$enderecoHD"
echo Nome da pasta montada a partição local:"$pastahd"
echo Configuração acesso rclone para google drive:"$servidorRclone"
echo Pasta montada o google drive:"$enderecoDriver"
echo ============================================================================================

if [ ! -e $enderecoHD ]; then
    sudo mkdir -p $enderecoHD

    if [ ! -e $enderecoHD ]; then
        echo A pasta "$enderecoHD" não existe, e não foi possível criá-la.
        echo Tente novamente.
        exit 1
    fi

    echo Pasta criada!
fi

sudo mount -o rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2 "$enderecoFisico" "$enderecoHD"

sleep 5

if [ -n "$(ls -A $enderecoHD)" ]; then
    echo "Partição local montada com sucesso"
else
    echo "Erro ao montar partição local, não podemos continuar o processo de montar o google drive e ativar o monitoramento!"
    echo "Tente novamente"
    exit 1
fi

rclone mount --vfs-cache-mode full "$servidorRclone": "$enderecoDriver" > /dev/null 2>&1 &

sleep 10

if [ "$(ls -A $enderecoDriver)" ]; then
    echo "Google drive Montado com sucesso!"
else
    echo "Erro ao montar GOOGLE DRIVE, não podemos continuar o processo de montar o google drive e ativar o monitoramento!"
    echo "Desmontando o drive LOCAL $enderecoHD"
    sudo umount $enderecoHD
    exit 1
fi

sleep 5
bash ativarmonitor.sh > /dev/null &
sleep 5
monitorRodando=$(ps -aux | grep inotifywait | grep "$pastahd")

if [ -n "$monitorRodando" ]; then
    echo monitoramento ativado com sucesso.
else
    echo inotifywait não inicializado corretamente!
    echo Verifique o problema, não será possível iniciar o google drive com monitoramento ativo então,
    echo Será desmontado o Google Drive e também o HD local!
    sudo umount $enderecoHD
    sudo umount $enderecoDriver
fi
