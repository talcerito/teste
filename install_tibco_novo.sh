#!/bin/bash
#
DEP_TIBCO=/tmp/install_tibco
PATH_TIBCO=/opt/tibco/rv/bin
DEP_HTTPD="joncor00101p-adm.intraservice.corp/middleware"
#VERSAO=8.4.1

#PERMITINDO ESCRITA NO /TMP:
echo "PERMITINDO ESCRITA NO /TMP"
chmod 1777 /tmp

# Criando DEP_TIBCO
mkdir -p $DEP_TIBCO

# Baixando pacote de instalacao

wget http://$DEP_HTTPD/tibco_bvmf.tar.gz -P $DEP_TIBCO

# Baixando arquivos de params do tibco

wget http://$DEP_HTTPD/arquivos_params.tar -P $DEP_TIBCO

# Verificando processos RVD's ativos e parando os mesmos

#/bin/echo "parando processo rvd"

#/bin/ps -ef | /bin/grep -i rvd | /bin/grep  -v grep | /bin/awk '{print $2}' | /usr/bin/xargs kill -9

# Copiando arquivos de configuracao das versoes anterioresi

#/bin/echo " Copiando arquivos de configuracao das versoes anteriores"
#/bin/cp -r $PATH_TIBCO/rvd_* $DEP_TIBCO
#/bin/cp -r $PATH_TIBCO/tibrv.tkt $DEP_TIBCO

# Descompactando pacote e instalando Tibco 8.4.1

/bin/echo "Descompactando e instalando Tibco 8.4.1"

/bin/tar -zxvf $DEP_TIBCO/tibco_bvmf.tar.gz -C /opt/

/bin/echo " "

# Copiado arquivos de configuracao

/bin/echo "Copiado arquivos de configuracao"

/bin/tar xf $DEP_TIBCO/arquivos_params.tar -C $PATH_TIBCO

/bin/echo " "

#/bin/mv $DEP_TIBCO/rvd_* $PATH_TIBCO/; /bin/mv  $DEP_TIBCO/tibrv.tkt $PATH_TIBCO/

# Renomeando arquivos RVRD

/bin/echo "Renomeando arquivos RVRD"

/bin/mv $PATH_TIBCO/rvrd $PATH_TIBCO/rvrd32; /bin/mv $PATH_TIBCO/rvrd64 $PATH_TIBCO/rvrd

/bin/echo " "

# Realizando o Recycle Tibco 8.4.1

#echo "Realizando o Recycle Tibco 8.4.1"

#/opt/tibco/rv/bin/recycletibco


# Criando diretorio de backup Tibco

#/bin/echo "Criando diretorio para rollback"

#/bin/mkdir -p /opt/tibco/old

# Movendo versoes anteriores do tibco para o diretorio old

#/bin/echo "Movendo versoes anteriores para diretorio de rollback"

#/bin/mv /opt/tibco/rv8.2.* /opt/tibco/old/ 2>> /dev/null; /bin/mv /opt/tibco/rv8.3.* /opt/tibco/old/  2>> /dev/null


#echo  > $DEP_TIBCO/lista_change
#echo  > $DEP_TIBCO/lista_libs
#echo  > $DEP_TIBCO/lista_3pr


# Criando lista de diretorios de libs

#find /apps/pumausr/ -type d | grep lib >> $DEP_TIBCO/lista_libs

# Criando lista de libs que contem arquivos 3pr

#for i in $(cat $DEP_TIBCO/lista_libs);do find $i -type f | grep rv | grep .3pr >> $DEP_TIBCO/lista_3pr; if [ $? -eq 0 ];then echo $i; fi; done >> $DEP_TIBCO/lista_change


#for i in $(cat $DEP_TIBCO/lista_libs);do find $i -type f | grep rv | grep .3pr >> $DEP_TIBCO/lista_3pr

#if [ $? -eq 0 ];then
#echo $i;
#fi; done >> lista_change


# Movendo os arquivos 3pr para a versao atualizada do tibco

#for i in $(cat $DEP_TIBCO/lista_change);do cd $i ; mv rv*  rv-8.4.1-x86_64.3pr 2>> /dev/null ;done
#for i in $(cat $DEP_TIBCO/lista_change); do 
#	cd $i
#	for j in $(ls rv* 2> /dev/null); do 
#		#mv $j $(echo $j | sed "s/[0-9]\.[0-9]\.*[0-9]*/$VERSAO/") 
#		NOVO_NOME=$(echo $j | sed "s/[0-9]\.[0-9]\.*[0-9]*/$VERSAO/")
#		NOVISSIMO_NOVO_NOME=$(echo $NOVO_NOME | sed "s/x86\.3pr/x86_64.3pr/")
#		mv $j $NOVISSIMO_NOVO_NOME
#	done
#done


# Rodando script bob para atualizacao do rvtab

#/etc/cron.daily/run_bob.daily



# Coletando evidencia de instalacao

#/bin/echo "# Arvore de diretorio tibco pos instalacao #" >> $DEP_TIBCO/evidencias/process_tibco
#/bin/ls -lha /opt/tibco/ >> $DEP_TIBCO/evidencias/process_tibco


# Listando evidencia de atualizacao

#/bin/echo "# Evidencia  Atualizacao arquivos 3pr #" >> $DEP_TIBCO/evidencias/process_tibco

#for i in $(cat $DEP_TIBCO/lista_change);do echo $i >> $DEP_TIBCO/evidencias/process_tibco ;ls -lha $i >> $DEP_TIBCO/evidencias/process_tibco ; echo "# Evidencia  Atualizacao arquivos 3pr #" >> $DEP_TIBCO/evidencias/process_tibco ;done

#echo " " >> $DEP_TIBCO/evidencias/process_tibco
#echo "Arquivo /etc/apps/software/rvtab " >> $DEP_TIBCO/evidencias/process_tibco
#cat /etc/apps/software/rvtab >> $DEP_TIBCO/evidencias/process_tibco

# Listando evidencia de atualizacao

#echo $HOSTNAME

#for i in $(cat $DEP_TIBCO/lista_change);do ls -lha $i >> $DEP_TIBCO/evidencias/process_tibco ;done



# Listando processos RVD

#/bin/echo "# Processo RVD tibco pos instalacao #" >> $DEP_TIBCO/evidencias/process_tibco
#ps aux | grep rvd | grep -v grep >> $DEP_TIBCO/evidencias/process_tibco


# Realizando o Recycle Tibco 8.4.1

/bin/echo "Realizando o Recycle Tibco 8.4.1"

/opt/tibco/rv/bin/recycletibco

/bin/echo " "

# Listando processos RVD

/bin/echo "# Processo RVD tibco pos instalacao #"
ps aux | grep rvd | grep -v grep 

/bin/echo " "

# Removendo script e pacote de instalacao

/bin/echo "Removendo pacote de instalacao"

/bin/rm -rf $DEP_TIBCO



