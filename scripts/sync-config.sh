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
    echo "====================================================================="
    echo "Configurar inicialização automatica"
    echo "====================================================================="
    echo Deseja iniciar o monitoramente automaticamente ao iniciar o linux?
    echo para sim digite s:
    read input
    if [ "$input" = "s" ]; then
        
        sudo bash -c 'echo "[Unit]" > /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "Description=Sync HD Service" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "After=network.target network-online.target graphical.target" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "Wants=network-online.target" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "[Service]" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "User=root" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "ExecStart=/usr/bin/sync-hd.sh b" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "Restart=always" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "RestartSec=3" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "[Install]" >> /etc/systemd/system/sync-hd.service'
        sudo bash -c 'echo "WantedBy=multi-user.target" >> /etc/systemd/system/sync-hd.service'

        sudo systemctl daemon-reload
        sudo systemctl enable sync-hd.service

        #echo Não foi possiveil ainda implementar o autoinicio pois
        #echo pois não consegue montar a pasta remota no inicialização.
    else   
        echo Lembre-se que escolheu por iniciar o serviço sync-hd sempre manualmente.
    fi
    echo "***********************************************"

    
    
    echo Arquivo de configuração ficou assim:
    echo "=============================================="
    cat /etc/sync-hd/monitor.conf
    echo "=============================================="
    echo Caso necessário reconfigurar use: bash sync-config.sh
    echo
     
    echo "==> Apara iniciar o monitoramento execute: bash sync-hd.sh"
    echo "==> Apara iniciar o monitoramento em background execute: bash sync-hd.sh b"

    echo "====================================================================="
    echo Deseja iniciar o monitoramente AGORA?
    echo para sim digite s:
    read input
    if [ "$input" = "s" ]; then
        bash sync-hd.sh b 
    fi
    echo "*********************************************************************"
    
    exit 1

else
    echo "Senha do sudo incorreta. Por favor, tente novamente."
    exit 1
fi
