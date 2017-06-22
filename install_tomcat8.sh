#!/bin/bash

##Diretorio temporario para armazenamento da versao do tomcat
DEP_TOMCAT=/tmp/install_tomcat
#Diretorio padrao de instalacao TOMCAT
PATH_TOMCAT=/opt/apache-tomcat
##Servidor web com pacote/binarios de instalacao
DEP_HTTPD="joncor00101p-adm.intraservice.corp/middleware"
#JAVA_HOME
JAVA_HOME="/usr/java/jdk1.8.0_77"
#Diretorio com nome da versao a ser instalada seguir o padrao X.X.XX
TOMCAT_VERSION="8.0.36"

#CRIACAO DO DIRETORIO PARA INSTALACAO DO APACHE
echo "CRIACAO DO DIRETORIO PARA INSTALACAO DO APACHE"
mkdir -p $PATH_TOMCAT

#BAIXANDO PACOTE DE INSTALACAO DO TOMCAT 

wget http://$DEP_HTTPD/apache-tomcat-$TOMCAT_VERSION.zip -P $DEP_TOMCAT

#DESCOMPACTANDO ARQUIVO DE INSTALACAO
echo "DESCOMPACTANDO ARQUIVO DE INSTALACAO"
unzip $DEP_TOMCAT/apache-tomcat-$TOMCAT_VERSION.zip -d $PATH_TOMCAT

#MUDANDO O NOME DO DIRETORIO DESCOMPACTADO PARA O NUMERO DA VERSAO
echo "MUDANDO O NOME DO DIRETORIO DESCOMPACTADO PARA O NUMERO DA VERSAO"
mv $PATH_TOMCAT/apache-tomcat-$TOMCAT_VERSION $PATH_TOMCAT/$TOMCAT_VERSION 

#PERMISSAO DE EXECUCAO PARA OS SCRIPTS DE INICIALIZACAO DO TOMCAT:
echo "PERMISSAO DE EXECUCAO PARA OS SCRIPTS DE INICIALIZACAO DO TOMCAT"
chmod +x $PATH_TOMCAT/$TOMCAT_VERSION/bin/*.sh 

#Adicionando JAVA_HOME no script de configuracao do TOMCAT

sed -i "/#   JAVA_HOME/i JAVA_HOME=$JAVA_HOME" /opt/apache-tomcat/$TOMCAT_VERSION/bin/catalina.sh && echo "instalacao realizada com sucesso"


#STARTANDO O APACHE
#echo "PARA INICIALIZAR O APACHE EXECUTE O SEGUINTE COMANDO:"
#echo " "
#echo "$PATH_TOMCAT/$TOMCAT_VERSION/bin/catalina.sh start"

#$PATH_TOMCAT/$TOMCAT_VERSION/bin/catalina.sh start

#REMOVENDO DIRETORIO DE INSTALACAO

#rm -rf $DEP_TOMCAT

