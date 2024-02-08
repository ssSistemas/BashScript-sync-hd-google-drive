#!/bin/bash

if [ -f "/etc/sync-hd/monitor.conf" ]; then
    echo Você já possui um arquivo de configuração
    echo "========================================"
    cat /etc/sync-hd/monitor.conf
    echo "========================================"
    echo "Você deseja modifica-lo?"
    echo "Caso queira digite: s"
    read input
    if [ ! "$input" = "s" ];then
        exit 1
    fi
else
    sudo mkdir -p /etc/sync-hd
fi 

sudo -v

if [ $? -eq 0 ]; then

    echo "***********************************"
    echo Configurando o servidor do rclone
    echo "***********************************"

    rcloneNome=$(rclone listremotes | cut -d ":" -f1)
    echo deseja usar o servidor rclone: 
    echo "$rcloneNome" 
    echo ? 
    echo Para confirmar digite: s
    read input

    if [ ! "$input" = "s" ];then
        echo Então digite o nome do servidor desejado
        read input
        rcloneNome="$input"
        echo Confirmado utilizando o servidor "$rcloneNome"
        
    else    
        echo Confirmado utilizando o servidor "$rcloneNome"
        
    fi

    sudo bash -c "echo servidorRclone="$rcloneNome" > /etc/sync-hd/monitor.conf"


    echo "***********************************"
    echo Configurar a pasta para montar diretorio remoto
    echo "***********************************"
    echo "Entre com o endereço completo da pasta para montar diretorio remoto"
    echo "=============================================="
    echo "exemplo: /home/rodrigo/driver"
    echo "=============================================="
    read input
    sudo bash -c "echo enderecoDriver=\"$input\" >> /etc/sync-hd/monitor.conf"
    echo "***********************************"
    echo Configurando o endereço fisico da sua partição
    echo "***********************************"

    echo segue a tabela de partição para consulta.
    echo "********************************************************"
    sudo fdisk -l | more
    echo "********************************************************"
    var1=$(echo -n $RANDOM | sha256sum | cut -c1-16)

    echo "Entre com o endereço físico da sua partição local"
    echo "=============================================="
    echo "exemplo: /dev/sda3"
    echo "=============================================="
    read input
    sudo bash -c "echo enderecoFisico=\"$input\" >> /etc/sync-hd/monitor.conf"
    echo "******************************************************************"
    echo "Entre com endereço de pasta que deseja montar sua partição."
    echo "=============================================="
    echo "exemplo: /media/meuhd"
    echo "=============================================="
    read input
    input="$input"/"$var1"
    sudo bash -c "echo enderecoHD=\"$input\" >> /etc/sync-hd/monitor.conf"
    echo "=============================================="
    echo "Sua partição interna será montada em $input"
    echo "=============================================="
    echo "***************************************************"
    echo Programa instalado e configurado
    echo
    echo Arquivo de configuração ficou assim:
    echo "=============================================="
    cat /etc/sync-hd/monitor.conf
    echo "=============================================="
    echo Caso necessário reconfigurar use: bash sync-config.sh
    echo
    echo "==> Apara iniciar o monitoramento execute: bash sync-hd.sh"
    echo "==> Apara iniciar o monitoramento em background execute: bash sync-hd.sh b"
    exit 1
else
    echo "Senha do sudo incorreta. Por favor, tente novamente."
    exit 1
fi
