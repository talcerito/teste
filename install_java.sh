#!/bin/bash

#Diretorio temporario para armazenamento da versao da JDK
DEP_JAVA=/tmp/install_java
#Diretorio padrao de instalacao JAVA
PATH_JAVA=/usr/java
#Servidor web com pacote/binarios de instalacao
DEP_HTTPD="joncor00101p-adm.intraservice.corp/middleware"
#Diretorio como nome da JDK instalada seguir o padrao jdk1.X.X_XX
DIR_JAVA="jdk1.8.0_102"
#JAVA_HOME
JAVA_HOME=$PATH_JAVA/$DIR_JAVA
#Pacote de instalacao
PACK_JAVA="jdk-8u102-linux-x64.gz"


#CRIACAO DO DIRETORIO PARA INSTALACAO DO JAVA
echo "CRIACAO DO DIRETORIO PARA INSTALACAO DO JAVA"
mkdir -p $DEP_JAVA

#BAIXANDO PACOTE DE INSTALACAO DO JAVA 

wget http://$DEP_HTTPD/$PACK_JAVA -P $DEP_JAVA

#DESCOMPACTANDO ARQUIVO DE INSTALACAO
echo "DESCOMPACTANDO ARQUIVO DE INSTALACAO"
tar xvf  $DEP_JAVA/$PACK_JAVA -C $PATH_JAVA

#VALIDANDO INSTALACAO
echo "VALIDANDO INSTALACAO"
$JAVA_HOME/bin/java -version

#EXCLUINDO ARQUIVOS DE INSTALACAO

rm -rf $DEP_JAVA 
