#!/bin/bash
cd scripts
sudo cp * /usr/bin/
sudo chmod +x /usr/bin/sync-atualizarTodoDriver.sh
sudo chmod +x /usr/bin/sync-copiarTodoDriver.sh
sudo chmod +x /usr/bin/sync-hd-monitor.sh
sudo chmod +x /usr/bin/sync-hd.sh
sudo chmod +x /usr/bin/sync-config.sh
bash sync-config.sh