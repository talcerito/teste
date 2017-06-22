#!/bin/bash

DEP_ORACLE="joncor00101p-adm.intraservice.corp/middleware"
HOST_DNS=`ifconfig | grep 10.8.80 | awk '{print $2}' | cut -f2 -d":"`


#VALIDANDO RESOLUCAO DE NOME

ping -c1 $HOSTNAME >> /dev/null

        if [ $? -eq 0 ]; then
                echo "Resolucao de nome OK";
        else
                echo "Ajustanto resolucao de nome";
                echo "$HOSTNAME $HOST_DNS" >> /etc/hosts;
                cat /etc/hosts;
        fi

ping -c1 $HOSTNAME >> /dev/null

        if [ $? -eq 0 ]; then
                echo "Resolucao de nome OK";
         fi


#PERMITINDO ESCRITA NO /TMP:
echo "PERMITINDO ESCRITA NO /TMP"
chmod 1777 /tmp

#REMOVENDO POSSIVEIS ARQUIVOS DE OUTRAS INSTALACOES:
echo "REMOVENDO POSSIVEIS ARQUIVOS DE OUTRAS INSTALACOES"
rm -rf /tmp/*ora*
rm -rf /tmp/*Ora*
rm -rf /export/11.2.0
rm -rf /export/oraclient-11.2.0.3.0.tar.gz
rm -rf /export/install_oracle_client

#VERIFICANDO A EXISTENCIA DO USUARIO ORACLE:
echo "VERIFICANDO A EXISTENCIA DO USUARIO ORACLE"
id oracle | grep dba ||  id oracle ||  adduser oracle && groupadd dba ; usermod -G dba oracle && id oracle
id oracle | grep dba || echo "PROBLEMAS COM USUARIO ORACLE" && 
echo "USUARIO ORACLE OK"


#LENDO VARIAVEIS DO SCRIPT POST_INSTALL DO SERVIDOR:
#echo "LENDO VARIAVEIS DO SCRIPT POST_INSTALL DO SERVIDOR"
#. /etc/scripts/ks_post_* || echo "PROBLEMAS PARA LEITURA DO ARQUIVO DE DEPSRV /etc/scripts/ks_post_*" &&
#echo "VARIAVEL DEPSRV OK"

#BAIXANDO SCRIPT DE INSTALACAO DO ORACLE CLIENT:
echo "BAIXANDO SCRIPT DE INSTALACAO DO ORACLE CLIENT"
wget -O /export/install_oracle_client http://$DEP_ORACLE/scripts/install_oracle_client || echo "PROBLEMAS PARA BAIXAR O SCRIPT DE INSTALACAO DO ORACLE CLIENT" && echo "SCRIPT ORACLE CLIENT BAIXADO COM SUCESSO" 


#BAIXANDO PACOTE DO ORACLE CLIENT:
echo "BAIXANDO PACOTE DE INTALACAO DO ORACLE CLIENT"
wget -O /export/oraclient-11.2.0.3.0.tar.gz http://$DEP_ORACLE/oraclient-11.2.0.3.0.tar.gz || echo "PROBLEMAS PARA BAIXAR O PACOTE DE INSTALACAO DO ORACLE CLIENT" && echo "PACOTE ORACLE CLIENT BAIXADO COM SUCESSO"

#ADICIONANDO PERMISSAO DE EXECUCAO AO SCRIPT DE INSTALACAO:
echo "ADICIONANDO PERMISSAO DE EXECUCAO AO SCRIPT DE INSTALACAO"
chmod 750 /export/install_oracle_client || echo "PROBLEMAS DE PERMISSIONAMENTO NO ARQUIVO /export/install_oracle_client" && 
echo "PERMISSAO DE EXECUCAO OK"

#DESCOMPACTANDO ARQUIVO DE INSTALACAO:
echo "DESCOMPACTANDO ARQUIVO DE INSTALACAO"
tar -zxpf /export/oraclient-11.2.0.3.0.tar.gz -C /export || echo "PROBLEMAS NA DESCOMPACTACAO DO PACOTE /export/oraclient-11.2.0.3.0.tar.gz" && echo "DESCOMPACTACAO OK"

#EXECUTANDO SCRIPT DE INSTALACAO DO ORACLE CLIENT:
echo "EXECUTANDO SCRIPT DE INSTALACAO DO ORACLE CLIENT"
/export/install_oracle_client 11.2.0.3.0 || echo "PROBLEMAS NA EXECUCAO DO SCRIPT DE INSTALACAO" && echo "SCRIPT DE INSTALCAO EXECUTADO COM SUCESSO"

#EXECUTANDO SCRIPTS APOS A INSTALACAO:
echo "EXECUTANDO SCRIPTS orainstRoot.sh e  root.sh  APOS A INSTALACAO DO PACOTE ORACLE CLIENT"
/opt/oracle/oraInventory/11.2.0/3.0_client/orainstRoot.sh || echo PROBLEMAS NA EXECUCAO DO SCRIPT "/opt/oracle/oraInventory/11.2.0/3.0_client/orainstRoot.sh"  && /opt/oracle/product/11.2.0/3.0_client/root.sh || echo "PROBLEMAS NA EXECUCAO DO SCRIPT /opt/oracle/product/11.2.0/3.0_client/root.sh" && echo "EXECUCAO DE SCRIPTS OK"

#REMOVENDO SUJEIRAS DA INSTALACAO:
rm -rf /tmp/*ora*
rm -rf /tmp/*Ora*
rm -rf /export/11.2.0
rm -rf /export/oraclient-11.2.0.3.0.tar.gz
rm -rf /export/install_oracle_client

