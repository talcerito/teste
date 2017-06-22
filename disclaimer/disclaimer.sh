#!/bin/bash -x

################################################################################################
################################# DI-GINP
############## 18/08/2016
## Script para validar se usuario eh nominal ou de servico atraves da configuracao do ldap.conf
################################################################################################


############# VARIAVEIS ###################
## Parse do arquivo ldap.conf para os servidores do ldap e OU
LDPSRV=$(cat /etc/ldap.conf | grep ^uri | tr ' ' '\n' | grep -v uri | awk -F '/' '{print $3}' | cut -d ':' -f1)
OU=$(cat /etc/ldap.conf | grep ^base | awk -F '=' '{print $2}' | cut -d ',' -f1)
DC=$(cat /etc/ldap.conf | grep ^base | awk -F '=' '{print $3}' | cut -d ',' -f1)
DC2=$(cat /etc/ldap.conf | grep ^base | awk -F '=' '{print $4}' | cut -d ',' -f1)

##### VALIDACAO PACOTE LDAPSEARCH

rpm -qa | grep openldap-clients &> /dev/null
if [ $? -eq 0 ]
then
    #### VALIDACAO DO USUARIO -  SE E NOMINAL OU DE SERVICO
    for k in $(echo $LDPSRV)
    do
      timeout 2 ldapsearch -x -l 2 -H ldaps://$k:636 -b "uid=$(whoami),ou=Users,ou=$OU,dc=$DC,dc=$DC2" &> /dev/null
      if [ $? -eq 0 ]
        then
        echo -ne "\n === ACESSO A AMBIENTE CONTROLADO E MONITORADO ===
  Este ambiente e controlado, pode conter informacoes confidenciais e/ou privilegiadas e deve ser acessado somente por pessoas expressamente autorizadas. Se voce nao for expressamente autorizado a acessa-lo, devera desconectar-se imediatamente e contatar a area de seguranca da informacao. Todos os acessos poderao ser monitorados. Ao acessar este ambiente voce concorda com todas as normas e politicas de acesso e seguranca da informacao da BM&FBOVESPA.\n\n"
        break
        fi
done
fi
