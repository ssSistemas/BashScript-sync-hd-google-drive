#!/bin/bash


#função para sincronizar hd e google drive
sincronizarHD() {
    sleep 30
    nice -n 15 bash sync-copiarTodoDriver.sh > /dev/null 2>&1 &
    
    
    
    sleep 30
    
    while [ "a" = "a" ]
    do
        if ! ps -aux | grep -q '[r]clone copy --transfers 2 --checkers 3 --checksum --update'; then
            nice -n 15 bash sync-atualizarTodoDriver.sh > /dev/null 2>&1 &
            break
        else
            sleep 300
        fi
    done
}

# Verificar se o script está sendo executado com o Bash
if [ -z "$BASH" ]; then
    echo "Este script requer o Bash para execução. Por favor, execute com bash."
    echo Exemplo:
    echo bash montarDriver.sh
    exit 1
fi

parametro=$1

if [ "$parametro" = "?" ]; then
    echo o sync-hd.sh possui somente um parametro
    echo o parametro é para executar em background
    echo parametro: b
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


pastahd=$(echo "$enderecoHD" | grep -oP '[0-9a-f-]+$')

echo ============================================================================================
echo Endereço físico da partição:"$enderecoFisico"
echo Endereço da pasta a ser montada a partição local:"$enderecoHD"
echo Nome da pasta montada a partição local:"$pastahd"
echo Configuração acesso rclone para google drive:"$servidorRclone"
echo Pasta montada o google drive:"$enderecoDriver"
echo ============================================================================================

echo ===========================================================================================
echo Deseja sincronizar o HD e Google Drive.
echo Caso deseje digite: s
read input
echo ===========================================================================================

sincroHD=0

if [ "$input" = "s" ]; then
    sincroHD=1
    echo Sincronização será iniciada após o completo carregamento do sync-hd iniciada.
else
    echo Vocẽ escolheu não sincronir no momento. 
fi

if [ ! -e $enderecoHD ]; then
    sudo mkdir -p $enderecoHD
    
    if [ ! -e $enderecoHD ]; then
        echo A pasta "$enderecoHD" não existe, e não foi possível criá-la.
        echo Tente novamente.
        exit 1
    fi
    
    echo Pasta criada!
fi

sudo echo

sudo -v


if [ ! $? -eq 0 ]; then
    
    echo "Senha do sudo incorreta. tente novamente."
    exit 1
fi



sudo mount -o rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2 "$enderecoFisico" "$enderecoHD" &

sleep 5

if [ -n "$(ls -A $enderecoHD)" ]; then
    echo "Partição local montada com sucesso"
else
    echo "Erro ao montar partição local, não podemos continuar o processo de montar o google drive e ativar o monitoramento!"
    echo "Tente novamente"
    exit 1
fi



let cont=0
while [ "a"=="a" ]
do
    rclone mount --vfs-cache-mode full "$servidorRclone": "$enderecoDriver" > /dev/null 2>&1 &
    
    sleep 10
    
    if [ "$(ls -A $enderecoDriver)" ]; then
        echo "Google drive Montado com sucesso!"
        break
    else
        echo "Erro ao montar GOOGLE DRIVE"
        
        if [ "$(ls -A ~/.cache/rclone)" ]; then
            rm -r ~/.cache/rclone/*
        fi
    fi
    
    if [ "$cont" -eq 5 ]; then
        echo "não podemos continuar o processo de montar o google drive e ativar o monitoramento!"
        echo "Desmontando o drive LOCAL $enderecoHD"
        sudo umount $enderecoHD
        echo Tente novamente mais tarde.
        exit 1
    fi
    
    let cont++
done

sleep 5



if [ "$sincroHD" -eq 1 ]; then
    sincronizarHD &

fi



if [ "$parametro" = "b" ]; then
    bash sync-hd-monitor.sh > /dev/null 2>&1 &
else
    bash sync-hd-monitor.sh
fi


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
