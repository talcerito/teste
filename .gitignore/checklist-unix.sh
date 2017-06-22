#!/bin/sh
#
# checklist-unix.sh
# checklist-unix
#
# Created 02-10-2012
# 
##############################################################################
#
# GLOBAL VARIABLES
CHKU_PATH=/opt/checklist-unix
CHKU_MODULES=$CHKU_PATH/modulos
CHKU_FILES=$CHKU_PATH/files
CHKU_LOGS=$CHKU_PATH/logs
CHKU_SO=`uname`
CHKU_FILE_CHECKLIST="`hostname`.`date +"%d%m%Y.%H%M"`.checklist"
CHKU_VERSION="1.1"


# GLOBAL ERRORS
# exit 2 = Modulo para o sistema operacional nao existe
# exit 3 = Formato de data não está correto
# exit 4 = Arquivo com a data não existe
# exit 5 = Executado com usuário diferente do root


# INICIO
##############################################################################

# Pre-checagens
# Verifica se o Sistema Operacional estao disponivel
if [ ! -f $CHKU_MODULES/mod_$CHKU_SO.sh ]; then

	echo "Modulo para o Sistema Operacional nao existe!"
	echo $CHKU_SO
	exit 2

fi

# Verifica se o script esta sendo executado pelo root
if [ `whoami` != "root" ]; then
	echo "Necessita executar como root"
	exit 5
fi 

echo "Usando modulo $CHKU_MODULES/mod_$CHKU_SO.sh ."
# carrega modulo do sistema operacional
. $CHKU_MODULES/mod_$CHKU_SO.sh


# Funcoes globais
# Funcao de titulo, para ser utilizado no modulo
nome_arquivo ()
{
	FILE=$*
	CHKU_GFILE=$CHKU_FILES/$FILE.$CHKU_FILE_CHECKLIST
	echo "-------------------------------------------------------------------"
	echo $FILE | sed 's/_/ /g'
}

# Funcao de comparar checklists
comparacheck ()
{
	case $1 in

		-cd)

		# Compara checklists utilizando datas especificas
		#
		# Verifica se o parametro -cd foi especificado
		for CHECKLIST in $FILES_NAMES;
		do
		   ls -la $CHKU_FILES/$CHECKLIST.*.checklist >> /dev/null 2>&1
		   RC=$?
		   if [ $RC -eq 0 ]; then
                        LAST=` date +"%d%m%Y"`;
			CHECK_ITEM_LAST=`ls -ltr $CHKU_FILES/$CHECKLIST.*.$LAST.*.checklist|awk '{print $9}'|tail -1`
			CHECK_ITEM_DATA=`ls -ltr $CHKU_FILES/$CHECKLIST.*.$2.checklist|awk '{print $9}'|tail -1`

			diff $CHECK_ITEM_LAST $CHECK_ITEM_DATA >/dev/null 2>&1
			RC=$?

			if [ $RC -ne 0 ] ;then
				echo -e "`echo $CHECKLIST | sed 's/_/ /g'` !!**!! \033[1;31mNOK\033[0m"
				diff $CHECK_ITEM_LAST $CHECK_ITEM_DATA |egrep -e "^<|^>"
			else
				echo -e "`echo $CHECKLIST | sed 's/_/ /g'` ** \033[1;32m OK \033[0m"
			fi
			sleep 1
			echo '--------------------------------------------------------------------'
		   fi
		done
		;;

		-ht)
                
		if [ -z $CHKU_SO ]; then
                echo "nao e linux"
                elif [ $CHKU_SO == "Linux" ]; then
                /opt/checklist-unix/modulos/linux_html/html-linux
                fi
;;	
		
		-c)
		
		# Compara checklists utilizando datas especificas
		for CHECKLIST in $FILES_NAMES;
		do
		   ls -la $CHKU_FILES/$CHECKLIST.*.checklist >> /dev/null 2>&1
                   RC=$?
                   if [ $RC -eq 0 ]; then
			CHECK_ITEM=`ls -ltr $CHKU_FILES/$CHECKLIST.*.checklist|awk '{print $9}'|tail -2`


			diff $CHECK_ITEM >/dev/null 2>&1
			RC=$?

			if [ $RC -ne 0 ] ;then
				echo -e "`echo $CHECKLIST | sed 's/_/ /g'` !!**!! STATUS: \033[1;31mNOK\033[0m"
				diff $CHECK_ITEM |egrep -e "^<|^>"
			else
				echo -e "`echo $CHECKLIST | sed 's/_/ /g'` ** STATUS: \033[1;32m OK \033[0m "
			fi
			echo '--------------------------------------------------------------------'
	    	   fi
			sleep 1
		done
		;;

	esac
}

# inicia parametros do checklist-unix


case $1 in
	
	-g)
		
		# gera checklist do SO
		echo ""
		echo "Gerando do checklist do Sistema Operacional - $CHKU_SO"
		geracheck
		echo ""
		echo "Finalizado."
		
	;;

	-c)

		# compara os dois ultimos checklists
		echo ""
		echo "Inciando comparacao do checklist (dois ultimos)"
		echo ""
		comparacheck $1
		echo ""
		echo "Finalizado"
		

	;;
	
	-cd)
	
		# Verifica se a veriavel DDMMAAAA foi preenchida
		if [ ! -n "$2" ]; then
			echo ""
			echo "ERRO 3: Parametro do -cd deve conter uma data no formato DDMMAAAA.hhmm"
			echo "Exemplo: checklist-unix.sh -cd 10062010.1030"
			echo "Voce pode verificar as datas existentes, utilize: $0 -cl"
			echo "Para maior visualizacao entre na pasta files"
			echo ""
			exit 3
		fi
		
		# Verifica se o arquivo com a data existe
		if [ ! -f $CHKU_FILES/*.`hostname`.$2.checklist ]; then
			echo ""
			echo "ERRO 4: Arquivo para a data $2 nao existe"
			echo "Voce pode verificar as datas existentes, utilize: $0 -cl"
			echo ""
			exit 4
		fi
		
		# Compara com a data especificada ($2 se torna $1 no modulo)
		echo ""
		echo "Iniciando comparação do checklist - Ultimo com o do dia $2"
		echo ""
		comparacheck $1 $2
		echo "Finalizado"
		echo ""
	
		
	;;
	
	-cl)
		
		# lista datas do arquivos disponiveis
		echo ""
		echo "Lista de datas existentes de checklist"
		echo ""
		ls -la $CHKU_FILES | grep -v .gz |awk -F. '{ print $3"."$4 }' | sort | uniq	
		echo "Finalizado"
		echo ""
	
	;;
	
	-e)
		echo "Sera implementada esta funcao no futuro."	
	;;
	
	-pe)
		echo "Sera implementada esta funcao no futuro."	
	;;

	-ped)

		echo "Sera implementada esta funcao no futuro."		
	;;
	
	-r)

		# rotaciona os arquivos

		# arquivos com mais de 60 dias serao comprimidos
		echo "Rotacionando arquivos ($CHKU_FILES/*) com mais de 60 dias."
		find $CHKU_FILES/ -type f -atime +60 -exec compress {} ';'

		# arquivos com mais de 90 dias serao removidos
		echo "Removendo arquivos ($CHKU_FILES/*) com mais de 90 dias."
		find $CHKU_FILES/ -type f -atime +90 -exec rm {} ';'


	;;
	
	-s)

		echo "Sera implementada esta funcao no futuro."
	;;

	-v)

		echo "checklist-unix version $CHKU_VERSION" 
	
	;;
        
	h|*)
		echo "
		Usage:
         -h       : exibe este help
	 -v	  : versao do checklist
         -c       : Compara checklist
         -g       : Gera checklist
         -cd      : Compara checklist de uma data especifica (DDMMAAAA.hhmm)
         -cl      : Lista arquivos com datas disponiveis
         -ht	  : Gera um arquivo HTML	
	 -e       : Coleta arquivos de logs e armazena no diretorio especifico
         -pe      : Informa os logs do Ultimo dia
         -ped     : Imprime os logs do dia especificado (DDMMAAAA)
         -r       : Realiza rotate dos logs:
                    logs com 90 dias ou mais são excluidos
		"
	;;
esac

case $1 in

 -ht)

                if [ -z $CHKU_SO ]; then
                echo "nao e linux"
                elif [ $CHKU_SO == "Linux" ]; then
                /opt/checklist-unix/modulos/mod_html/html-linux
                elif [ $CHKU_SO == "AIX" ]; then
		/opt/checklist-unix/modulos/mod_html/html-aix_281.sh
		fi
;;
esac
