#!/bin/bash

# Verificar se o script está sendo executado com o Bash
if [ -z "$BASH" ]; then
    echo "Este script requer o Bash para execução. Por favor, execute com bash."
    echo "Exemplo:"
    echo "bash sync-hd.sh"
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
pasta_origem=$enderecoHD
pasta_destino=$enderecoDriver
lixeira="lixo"
endLixeira="$pasta_destino/$lixeira"
nomePasta=$pastahd

if [ ! -n "$(ls -A $enderecoHD)" ]; then
    echo "Erro partição local não montada, execute primeiramente o script sync-hd.sh"
    echo "tente novamente"
    exit 1
fi

if [ ! "$(ls -A $enderecoDriver)" ]; then
    echo "Erro ao montar GOOGLE DRIVE não montado, execute primeiramente o script sync-hd.sh"
    echo "tente novamente"
    exit 1
fi

# Função para apagar pasta googdrive após ser movido os arquivos para o lixo
ApagarPasta() {
    pasta="$1"
    
    while true; do
        processoRodando=$(ps -aux | grep "rsync" | grep -v grep)
        
        if [ ! -n "$processoRodando" ]; then
            echo "Processo INATIVO"
            
            total=$(find "$pasta" -mindepth 1 -type f | wc -l)
            
            if [ "$total" -eq 0 ]; then
                echo "A pasta e todas as subpastas estão vazias."
            else
                echo "A pasta e as subpasta contém arquivos algum arquivo."
            fi
        else
            echo "Ainda movendo a $pasta, aguarde."
        fi
        sleep 10
    done
}

echo "pasta_origem:$pasta_origem"
echo "pasta_destino:$pasta_destino"
echo "endLixeira:$endLixeira"
echo "Nome da pasta montada a partição local:$nomePasta"


# if ps -aux | grep -q '[r]clone sync --transfers 2 --checkers 3 --checksum'; then
#   echo "O processo rclone está rodando."
# else
#   echo "O processo rclone não está rodando."
# fi



Rodar=1
deletePermanente=0
ativarSimulacao=0

#inotifywait -e move -e modify -e delete -m "$pasta_origem" -r --format "%e %w%f" | while read -r evento arquivo; do
inotifywait -e move -e create -e modify -e delete -m "$pasta_origem" -r --format "%e %w%f" | while read -r evento arquivo; do
    #inotifywait -e modify -e delete -m "$pasta_origem" -r --format "%e %w%f" | while read -r evento arquivo; do
    oculto_arquivo=$(basename "$arquivo")
    
    if [ $Rodar -eq 1 ]; then
        if [[ $oculto_arquivo != .* ]]; then
            if ! echo "$arquivo" | grep -q "\.~" ; then
                if ! echo "$arquivo" | grep -q "Unconfirmed" ; then
                    if echo "$arquivo" | grep -q "\.Trash-1000"; then
                        if [ "$evento" = "MODIFY" ]; then
                            if [ -e "$arquivo" ]; then
                                
                                
                                
                                if ! ps -aux | grep -q '[r]clone copy --transfers 2 --checkers 3 --checksum --update'; then
                                    
                                    
                                    echo "-----------------------------------------------------------------------"
                                    echo "===================================================================="
                                    echo "                 Arquivo enviado para a lixeira!"
                                    echo "Arquivos do google drive são movidos para a pasta: $endLixeira"
                                    echo "===================================================================="
                                    
                                    conteudo=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$(cat "$arquivo" | grep 'Path' | cut -d '=' -f2)'))")
                                    endnoDrive="$pasta_destino/$conteudo"
                                    caminho_lixo="$endLixeira/$conteudo"
                                    
                                    if [ -f "$endnoDrive" ]; then
                                        if [ ! -d "$(dirname "$caminho_lixo")" ]; then
                                            if [ "$ativarSimulacao" -eq 1 ];then
                                                echo mkdir -p "$(dirname "$caminho_lixo")"
                                            else
                                                mkdir -p "$(dirname "$caminho_lixo")"
                                            fi
                                        fi
                                        echo "----------------------------------------------------"
                                        echo "Movendo"
                                        echo "de: $endnoDrive"
                                        echo "pr: $caminho_lixo"
                                        echo "----------------------------------------------------"
                                        
                                        if [ "$ativarSimulacao" -eq 1 ];then
                                            echo rsync -r -a --protect-args --remove-source-files "$endnoDrive" "$caminho_lixo" &
                                        else
                                            rsync -r -a --protect-args --remove-source-files "$endnoDrive" "$caminho_lixo" &
                                        fi
                                        
                                        
                                        
                                        
                                    else
                                        if [ ! -d "$(dirname "$caminho_lixo")" ]; then
                                            
                                            if [ "$ativarSimulacao" -eq 1 ];then
                                                echo mkdir -p "$(dirname "$caminho_lixo")"
                                            else
                                                mkdir -p "$(dirname "$caminho_lixo")"
                                            fi
                                            
                                            
                                        fi
                                        if [[ ! "$endnoDrive" == */ ]]; then
                                            endnoDrive="$endnoDrive/"
                                        fi
                                        echo "----------------------------------------------------"
                                        echo "Movendo"
                                        echo "de: $endnoDrive*"
                                        echo "pr: $caminho_lixo"
                                        echo "----------------------------------------------------"
                                        
                                        if [ "$ativarSimulacao" -eq 1 ];then
                                            echo rsync -a --protect-args --remove-source-files "$endnoDrive"* "$caminho_lixo" &
                                        else
                                            rsync -a --protect-args --remove-source-files "$endnoDrive"* "$caminho_lixo" &
                                        fi
                                        
                                        
                                    fi
                                fi
                            fi
                        fi
                    else
                        if echo "$arquivo" | grep -q ".part"; then
                            arquivo=$(echo "$arquivo" | sed 's/.part/@/g' | cut -d '@' -f1)
                        fi
                        
                        novo_caminho=$(echo "$arquivo" | sed 's/'"$nomePasta"'/@/g' | cut -d '@' -f2)
                        completo_caminho="$pasta_destino""$novo_caminho"
                        
                        if [ "$evento" = "DELETE" ]; then
                            if [ "$deletePermanente" -eq 1 ]; then
                                caminho_lixo="$pasta_destino"/"$lixeira""$novo_caminho"
                                echo "===================================================================="
                                echo "                 Arquivo DELETADOS permanentemente em local"
                                echo "===================================================================="
                                echo "Para sua segurança o arquivo do google drive são movidos para a pasta: $endLixeira"
                                echo "será movido para:$caminho_lixo"
                                
                                if [ ! -d "$(dirname "$caminho_lixo")" ]; then
                                    if [ "$ativarSimulacao" -eq 1 ];then
                                        echo mkdir -p "$(dirname "$caminho_lixo")"
                                    else
                                        mkdir -p "$(dirname "$caminho_lixo")"
                                    fi
                                    
                                    
                                    
                                fi
                                
                                echo "----------------------------------------------------"
                                echo "Movendo"
                                echo "de: $completo_caminho*"
                                echo "pr: $caminho_lixo"
                                echo "----------------------------------------------------"
                                if [ "$ativarSimulacao" -eq 1 ];then
                                    echo rsync -r -a --protect-args --remove-source-files "$completo_caminho" "$caminho_lixo" &
                                else
                                    rsync -r -a --protect-args --remove-source-files "$completo_caminho" "$caminho_lixo" &
                                fi
                                
                                
                                
                            else
                                echo ===========================================================
                                echo Evento acionando:"$evento"
                                echo Função Delete permanente DESATIVADA.
                                echo ============================================================
                            fi
                        else
                            if [ ! -d "$(dirname "$completo_caminho")" ]; then
                                
                                if [ "$ativarSimulacao" -eq 1 ];then
                                    echo mkdir -p "$(dirname "$completo_caminho")"
                                else
                                    mkdir -p "$(dirname "$completo_caminho")"
                                fi
                                
                                
                                
                            fi
                            
                            if [ -f "$arquivo" ]; then
                                echo "----------------------------------------------------"
                                echo "Copiando acionado pelo evento:$evento"
                                echo "de: $arquivo"
                                echo "pr: $completo_caminho"
                                echo "----------------------------------------------------"
                                
                                
                                
                                
                                if [ -e "$arquivo" ]; then
                                    if [ ! -e "$completo_caminho" ];then
                                        
                                        if [ "$ativarSimulacao" -eq 1 ];then
                                            echo rsync -a --protect-args "$arquivo" "$completo_caminho" &
                                        else
                                            rsync -a --protect-args "$arquivo" "$completo_caminho" &
                                        fi
                                        
                                        
                                        echo Arquivo copiado, não existia no destino.
                                    else
                                        #echo Calculando Hashs
                                        hash1=$(md5sum "$arquivo" | awk '{print $1}')
                                        hash2=$(md5sum "$completo_caminho" | awk '{print $1}')
                                        if [ "$hash1" == "$hash2" ]; then
                                            echo Não necessário realizar copia pois os arquivos são iguais, provados pelo md5sum
                                            #   echo "$hash1" = "$hash2"
                                        else
                                            #  echo hash não são iguais, === Arquivo será copiado caso a arquivo de origem for mais recente que destino.
                                            if [ "$arquivo" -nt "$completo_caminho" ]; then
                                                echo Copia necessaria de arquivo, iniciando!!
                                                
                                                if [ "$ativarSimulacao" -eq 1 ];then
                                                    echo rsync -a --protect-args "$arquivo" "$completo_caminho" &
                                                else
                                                    rsync -a --protect-args "$arquivo" "$completo_caminho" &
                                                fi
                                                
                                                
                                                
                                            else
                                                echo Não necessário a copia pois o destino é mais atual!
                                            fi
                                        fi
                                    fi
                                else
                                    echo Precisa verificar não foi encontrado o arquivo na origem: "$arquivo".
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    else
        
        echo "==================================================="
        echo "Evento:$evento"
        echo "Arquivo:$arquivo"
    fi
done
