# Scripts de Monitoramento e Sincronização de Arquivos

Este conjunto de scripts em Bash permite monitorar, sincronizar e realizar operações de cópia entre uma pasta local e um diretório no Google Drive utilizando o Rclone. Os scripts são projetados para serem executados em sistemas Linux.

## Requisitos

Antes de executar os scripts, verifique se você tem os seguintes requisitos:

- Bash 5.2 ou superior
- Rclone configurado corretamente para acessar sua conta do Google Drive
- inotify-tools instalado no sistema (`sudo apt install inotify-tools`)

## Uso

1. Clone este repositório em seu sistema:

   ```bash
   git clone https://github.com/ssSistemas/BashScript-sync-hd-google-drive
   cd sync-monitor-script
   
Configure o arquivo monitor.conf com as variáveis necessárias, como descrito abaixo.

###  Execute o script 
`` bash sync-hd.sh ``

#### Descrição dos Scripts

##### sync-hd.sh: Este script monta a partição local e o Google Drive especificados no arquivo de configuração monitor.conf. Ele também inicia o monitoramento da pasta local.

##### sync-hd-monitor.sh: Este script monitora a pasta local e sincroniza automaticamente os arquivos com o Google Drive. Ele também move os arquivos excluídos localmente para uma pasta de lixo no Google Drive.

##### sync-copiarTodoDriver.sh: Este script realiza uma cópia do servidor Google Drive para a pasta local.

##### sync-atualizarTodoDriver.sh: Este script realiza uma cópia de todos os arquivos da pasta local para o servidor Google Drive.

##### sync-config.sh: Este script auxilia na geração do arquivo de configuração monitor.conf

### Arquivo de Configuração (monitor.conf)
##### monitor.conf contém as seguintes variáveis de configuração:

Deve estar localizado em /etc/sync-hd/monitor.conf

1) enderecoFisico: Endereço físico da partição local.

2) enderecoHD: Endereço da pasta a ser montada como a partição local.

3) servidorRclone: Configuração de acesso Rclone para o Google Drive.

4) enderecoDriver: Pasta montada do Google Drive.

##### Exemplo Arquivo de Configuração

``
enderecoFisico=/dev/sda3
enderecoHD=/media/rodrigo/b37ebd40-869f-47a8-a068-84cb5ca89d68
servidorRclone=googledrive
enderecoDriver=/home/rodrigo/driver
``

# Contribuindo

Se você deseja contribuir com este projeto, siga estas etapas:

Faça um fork do projeto.
Crie uma nova branch (git checkout -b feature/nova-funcionalidade).
Faça commit das suas alterações (git commit -am 'Adicionando uma nova funcionalidade').
Faça push para a branch (git push origin feature/nova-funcionalidade).
Abra um Pull Request.
Licença
Este projeto está licenciado sob a Licença MIT.

Contato
Se você tiver alguma dúvida ou sugestão, entre em contato:

Seu Nome - rodrigodominguessilva@gmail.com