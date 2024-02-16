#!/bin/bash
clear
cd scripts
sudo cp * /usr/bin/



sudo -v


if [ $? -eq 0 ]; then
    sudo chmod +x /usr/bin/sync-atualizarTodoDriver.sh
    sudo chmod +x /usr/bin/sync-copiarTodoDriver.sh
    sudo chmod +x /usr/bin/sync-hd-monitor.sh
    sudo chmod +x /usr/bin/sync-hd.sh
    sudo chmod +x /usr/bin/sync-config.sh
    bash sync-config.sh
else
    echo "Senha do sudo incorreta. Instalação cancelada."
fi


