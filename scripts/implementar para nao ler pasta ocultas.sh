#!/bin/bash

# Extrai cada componente do caminho e verifica se algum é uma pasta oculta
check_hidden_folder() {
    local path=$1
    IFS='/' # Define o separador como '/'
    read -ra ADDR <<< "$path" # Converte string para array
    for i in "${ADDR[@]}"; do # Acessa cada item do array
        if [[ $i == .* ]]; then
            echo "Encontrada pasta oculta no caminho: $i"
            return 0
        fi
    done
    echo "Nenhuma pasta oculta encontrada no caminho."
    return 1
}

# Caminho de exemplo
path="/media/rodrigo/332335c75615ca6e/sistema informacao/bashLinux/gitRemoto/BashScript-sync-hd-google-drive/.git/logs/refs/remotes/origin/master"

# Chama a função e passa o caminho como argumento
check_hidden_folder "$path"
