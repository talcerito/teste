#!/bin/sh

CHKU_SO=`uname`

# Ler variavel uname

if [ -z $CHKU_SO ]; then
   echo "nao e linux"
elif [ $CHKU_SO == "Linux" ]; then
   echo "e um linux"
fi
