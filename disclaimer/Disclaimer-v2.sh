#!/bin/sh

#
#Disclaimer.sh
#Tiago Alcerito
#Criado 28-09-2016
#Atualizado 01-10-2016

#INSTALACAO PACOTE OPENLDAP
echo " INSTALACAO DO PACOTE "
yum install -y openldap-clients.x86_64 

# IDENTIFICA A ARQUITETURA DO SISTEMA OPERACIONAL

do_rhel6() {
echo " RHEL 6 - NENHUM COMANDO ADICIONAL A SER EXECUTADO "
}

do_rhel5() {
# COMANDO EXCLUSIVE PARA RH 5
echo " RHEL 5 - COMANDO ADICIONAL EXECUTADO "
chmod +x /usr/share/doc/bash-3.2/scripts/timeout && ln -s /usr/share/doc/bash-3.2/scripts/timeout /usr/bin/timeout
}

# INSERE O ARQUIVO DISCLAIMER
cd /etc/profile.d/
wget http://dplcor70201p/files/disclaimer/disclaimer

#RENOMEIA O ARQUIVO PARA .SH
mv /etc/profile.d/disclaimer /etc/profile.d/disclaimer.sh


if /bin/grep el5 /proc/version ; then
   echo "Detectado: RHEL5"
   do_rhel5;

elif /bin/grep el6 /proc/version ; then
   echo "Detectado: RHEL6"
   do_rhel6;

else
   echo "SO diferente de RHEL5 e RHEL6"
fi

echo "BACKUP DO BANNER ANTIGO"
cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config_bkp

echo "ALTERANDO O BANNER ANTIGO"
echo > /etc/ssh/sshd_config
sed '/Banner/s/Banner/#Banner/g' /etc/ssh/sshd_config_bkp >> /etc/ssh/sshd_config

echo "RELOAD DO SSHD"
service sshd reload