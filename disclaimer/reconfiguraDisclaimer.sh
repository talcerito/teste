#!/bin/sh
#
#SCRIPT:      reconfiguraDisclaimer.sh
#AUTHOR:      Fabio Mendes
#DATE:        2016-09-12
#REV:         0.0.P
#VER:         1.0
#PLATAFORM:   RHEL (5.x, 6.x e 7.x)
#
#PURPOSE:     Remove a configuracao do Disclaimer antigo e implementa solucao por script que valida somente contas nominais
#
#
#PARAMETERS:  SERVER_LIST - Lista de servidores
#
#
#USAGE:       ./reconfiguraDisclaimer.sh ./listaServidores.txt >> reconfiguraDisclaimer.log 2>&1
#
#EXIT STAUS:
# 0 - Configuracao alterada com sucesso
# 1 - Lista de servidores (parametro SERVER_LIST) nao informado
# 2 - Script finalizado com sinal de Trapped
#
#REV. LIST:
#
#
set -x #Uncomment to debug this script
#set -n #Uncomment to debug without any command execution


###################################################################
############# DEFINED CUSTOM CODE COLORS###########################
###################################################################

RED="\033[0;31m"
GREEN="\033[1;32m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
END="\033[0m"


###################################################################
############### USER DEFINED VARIABLES ############################
###################################################################
SCRIPT_NAME=`basename $0`
SERVER_LIST=$1
BASE_DIR="/root/scripts"
WORK_DIR="/etc"
SSH_TIMEOUT=10

###################################################################
############### USER DEFINED FUNCTIONS ############################
###################################################################

function usage
{
  echo -e "\n"
  echo -e "[`date`] - $GREEN INFO: $END USAGE - $SCRIPT_NAME {HOST LIST FILE}"
  echo -e "[`date`] - $GREEN INFO: $END EXAMPLE - $GREEN $BASE_DIR/$SCRIPT_NAME $END $CYAN /tmp/serverList.txt $END"
  echo -e "[`date`] - $GREEN INFO: $END Please, review parameters and try again..."
  echo -e "[`date`] - $GREEN INFO: $END Exiting with RC=1.\n"
  exit 1
}

function exit_trap
{
  echo -e "[`date`] - $RED ERROR: $END ...EXITING on trapped signal. RC=2...\n"
}


function reconfigura_disclaimer
{
SERVER=$1

  #Efetua backup, remove o parametro "Banner" do arquivo /etc/ssh/sshd_config e instala o pacote openldap-clients
  ssh -o ConnectTimeout=$SSH_TIMEOUT -n root@$SERVER "mkdir /root/bkpcfg/; cp -aprf $WORK_DIR/ssh/sshd_config /root/bkpcfg/sshd_config_disclaimer.bkp; sed -i '/Banner/d' $WORK_DIR/ssh/sshd_config; yum install -y openldap-clients.x86_64; chmod +x /usr/share/doc/bash-3.2/scripts/timeout && ln -s /usr/share/doc/bash-3.2/scripts/timeout /usr/bin/timeout"

  #Copia o script de disclaimer para o servidor
  scp /root/scripts/disclaimer/disclaimer.sh $SERVER:/etc/profile.d

  ssh -o ConnectTimeout=$SSH_TIMEOUT -n root@$SERVER "service sshd reload"

}

##################################################################
#################### START OF MAIN ###############################
##################################################################

trap 'exit_trap; exit 2' 1 2 3 15

#First check for the correct number of arguments
if (($# !=1))
then
  usage
fi


for server in $(cat $SERVER_LIST)
do
  echo -e "[`date`] - $YELLOW INFO: $END Iniciando o processamento do servidor: $server..."
  reconfigura_disclaimer $server
done


