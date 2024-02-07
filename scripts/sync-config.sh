#!/bin/bash
echo "***********************************"
Echo Configurando o servidor do rclone
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

exit 1

var1=$(echo -n $RANDOM | sha256sum | cut -c1-16)
sudo mkdir -p /etc/sync-hd
echo "Entre com o endereço físico da sua partição local"
echo "=============================================="
echo "exemplo: /dev/sda3"
echo "=============================================="
read input
sudo bash -c "echo enderecoFisico=\"$input\" > /etc/sync-hd/monitor.conf"
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
