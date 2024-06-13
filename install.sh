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
    
    
    if ! dpkg -l | grep -qw rclone ; then
        echo "rclone não está instalado. Tentando instalar..."
        
        
        curl https://rclone.org/install.sh | sudo bash
        
        
        if dpkg -l | grep -qw rclone ; then
            echo "rclone instalado com sucesso."
        else
            echo "Não foi possível encontrar o pacote rclone."
            echo "Instale manualmente, e depois volte na instalação do sync-hd"
            exit 1
        fi
    fi

     if ! dpkg -l | grep -qw inotify-tools ; then
        echo "inotifywait não está instalado. Tentando instalar..."
        
        
        sudo apt-get update
        
        
        if sudo apt-get install -y inotify-tools; then
            echo "inotify-tools instalado com sucesso."
        else
            echo "Não foi possível encontrar o pacote inotify-tools nos repositórios padrão."
            echo "Você pode tentar instalar 'inotify-tools' como uma alternativa ou procurar um pacote '.deb' do pdftk online."
        fi
    fi


    
    if ! dpkg -l | grep -qw cpulimit; then
        echo "cpulimit não está instalado. Tentando instalar..."
        
        
        sudo apt-get update
        
        
        if sudo apt-get install -y cpulimit; then
            echo "cpulimit instalado com sucesso."
        else
            echo "Não foi possível encontrar o pacote cpulimit nos repositórios padrão."
            echo "Você pode tentar instalar 'cpulimit' como uma alternativa ou procurar um pacote '.deb' do pdftk online."
        fi
    fi
    
    echo Deseja iniciar o script de configuração?
    echo para sim digite: s
    read input
    
    if [ "$input" = "s" ];then
        bash sync-config.sh
    else
        echo Para iniciar o script de configuração em um outro momento execute:
        echo bash sync-config.sh
    fi
else
    echo "Senha do sudo incorreta. Instalação cancelada."
fi


