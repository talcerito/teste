#!/bin/sh
# (c) CME Group. Provided to BVM&F under NDA.
#
# This script installs the version of Oracle client specified as argument.
# -SM-
#

### Sanity-check basic system assumptions ###

# Only for Linux (for now...)
if [ `uname -s` != 'Linux' ]; then
    echo `uname -s` "not supported."
    exit 1
fi

# Only for root
if [ `id -u` != '0' ]; then
    echo "Must be run as root."
    exit 1
fi

# Create oracle homedir if necessary
[ -d /home/oracle ] || install -d /home/oracle -o oracle -g dba

# Script directory needed to find location of installer files
CURRENTDIR=`dirname $0`
if [ ! -d "$CURRENTDIR" ]; then
    echo "Error determining directory in which this script resides."
    exit 1
fi
# Convert relative path to absolute path
[ "`echo $CURRENTDIR |grep '^/'`" ] || CURRENTDIR="${PWD}/${CURRENTDIR}"


### Set some install parameters based on args ###

# Figure out version info from argument
MAJOR_VER=`echo "$1" |sed 's/\(.*\)\.\([0-9][0-9]*\.[0-9][0-9]*\)$/\1/'`
MINOR_VER=`echo "$1" |sed 's/\(.*\)\.\([0-9][0-9]*\.[0-9][0-9]*\)$/\2/'`
if [ -z "$MAJOR_VER" -o -z "$MINOR_VER" ]; then
    echo "Specify full version to install as argument, e.g."
    echo "$0 10.2.0.3.0"
    echo "$0 11.1.0.6.0"
    echo "$0 11.2.0.1.0"
    echo "$0 11.2.0.3.0"
    exit 1
fi

# Installer:
case "`arch`" in
    x86_64) ARCH=x86_64 ;;
    *)      ARCH=x86 ;;
esac
if [ -n "$2" ]; then
	if [ $2 == "x86_64" ] || [ $2 == "x86" ]; then
		ARCH=$2
	fi
fi
INSTALLER_BASE="${CURRENTDIR}/${MAJOR_VER}/${ARCH}"
PROFILE="${INSTALLER_BASE}/files/oraprofile"
ORACLERSP_SRC="${INSTALLER_BASE}/response/client.rsp"
PATCHRSP_SRC="${INSTALLER_BASE}/response/patchset-${MINOR_VER}.rsp"
SQLNETORA_SRC="${INSTALLER_BASE}/files/sqlnet.ora"
TNSNAMESORA_SRC="${INSTALLER_BASE}/files/tnsnames.ora"
ONSCONFIG_SRC="${INSTALLER_BASE}/files/ons.config"
# Point to correct servers for LDAP/ONAMES
#if ( hostname | grep 'a$' >/dev/null ); then
#    LOC=rdc
#elif ( hostname | grep 'c$' >/dev/null ); then
#    LOC=adc
#else
#    LOC=wdc
#fi
#LDAPORA_SRC="${INSTALLER_BASE}/files/ldap-${LOC}.ora"
LDAPORA_SRC="${INSTALLER_BASE}/files/ldap.ora"

# Installation:
PARENT="/opt/oracle"
BASEDIR="${PARENT}/product/${MAJOR_VER}"
INVDIR="${PARENT}/oraInventory/${MAJOR_VER}/${MINOR_VER}_client"
CLIENTDIR="${MINOR_VER}_client"
CLIENTLINK="client"
ORACLE_HOME="${BASEDIR}/${CLIENTDIR}"
ORACLE_HOME_NAME="client_"`echo ${MAJOR_VER}.${MINOR_VER} |tr . _`
ORACLERSP=`mktemp /tmp/oraclersp.XXXXXX`
LDAPORA=${ORACLE_HOME}/network/admin/ldap.ora
SQLNETORA=${ORACLE_HOME}/network/admin/sqlnet.ora
TNSNAMESORA=${ORACLE_HOME}/network/admin/tnsnames.ora
ONSCONFIG=${ORACLE_HOME}/opmn/conf/ons.config
# Some versions don't need a patch set (i.e. the initial release). The initial
# 11.1.0 release is at patch level 6, so 11.1.0.6.0 doesn't need a patch set.
case "${MAJOR_VER}.${MINOR_VER}" in
    # Set PATCHRSP var to blank. We will check if PATCHRSP is blank later,
    # to determine whether the patch installer needs to run
    10.2.0.1.0) PATCHRSP= ;;
    11.1.0.6.0) PATCHRSP= ;;
    11.2.0.1.0) PATCHRSP= ;;
    11.2.0.3.0) PATCHRSP= ;;
    *)          PATCHRSP=`mktemp /tmp/patchrsp.XXXXXX` ;;
esac
[ -z "$PATCHRSP" ] && PATCHRSP_SRC=
# Fix response files. mktemp requires ending to be XXXXXX but Oracle requires
# ending to be .rsp. So we generate file ending in XXXXXX, then rename it now.
mv $ORACLERSP "${ORACLERSP}.rsp"
ORACLERSP="${ORACLERSP}.rsp"
if [ ! -z "$PATCHRSP" ]; then
    mv $PATCHRSP "${PATCHRSP}.rsp"
    PATCHRSP="${PATCHRSP}.rsp"
fi

### Sanity-check above parameters ###

# Installer:
# Make sure source files are readable
for i in "$ORACLERSP_SRC" "$PATCHRSP_SRC" "$LDAPORA_SRC" "$SQLNETORA_SRC" "$ONSCONFIG_SRC" "$PROFILE"; do
    if [ ! -z "$i" -a ! -r "$i" ]; then
        echo "$i not readable."
        echo "Perhaps no install exists yet for Oracle client ${MAJOR_VER}.${MINOR_VER} on ${ARCH}?"
        exit 1
    fi
done

# Installation:
# Error if any version of old-style client is already installed
if [ -e "${BASEDIR}/${CLIENTLINK}" -a ! -L "${BASEDIR}/${CLIENTLINK}" ]; then
    echo "Remove old-style client in $PARENT, e.g."
    echo "mv $PARENT ${PARENT}.old"
    exit 1
fi
# Error if this version of new-style client is already installed
if [ -d "$ORACLE_HOME" ]; then
    echo "Oracle client ${MAJOR_VER}.${MINOR_VER} already installed in $ORACLE_HOME."
    exit 1
fi
# Error if inventory of this version of new-style client is already installed
if [ -d "$INVDIR" ]; then
    echo "Oracle client ${MAJOR_VER}.${MINOR_VER} inventory already in $INVDIR."
    exit 1
fi


### Perform install ###

# Copy response files to /tmp and append install info
cp -p "$ORACLERSP_SRC" $ORACLERSP
# Needed for older versions
if [ "$MAJOR_VER" = '10.2.0' -o "$MAJOR_VER" = '11.1.0' ]; then
    echo "FROM_LOCATION=${INSTALLER_BASE}/client/stage/products.xml" >> $ORACLERSP
    echo "ORACLE_HOME_NAME=$ORACLE_HOME_NAME" >> $ORACLERSP
fi
echo "INVENTORY_LOCATION=$INVDIR" >> $ORACLERSP
echo "ORACLE_BASE=$PARENT" >> $ORACLERSP
echo "ORACLE_HOME=$ORACLE_HOME" >> $ORACLERSP
if [ ! -z "$PATCHRSP" -a ! -z "$PATCHRSP_SRC" ]; then
    cp -p "$PATCHRSP_SRC" $PATCHRSP
    # Needed for older versions
    if [ "$MAJOR_VER" = '10.2.0' -o "$MAJOR_VER" = '11.1.0' ]; then
        echo "FROM_LOCATION=${INSTALLER_BASE}/patch-${MINOR_VER}/stage/products.xml" >> $PATCHRSP
        echo "ORACLE_HOME_NAME=$ORACLE_HOME_NAME" >> $PATCHRSP
    fi
    echo "ORACLE_HOME=$ORACLE_HOME" >> $PATCHRSP
    echo "NEXT_SESSION_RESPONSE=$PATCHRSP" >> $ORACLERSP
fi
# Create oraInst.loc in /tmp
ORAINSTLOC=`mktemp /tmp/oraInstlocXXXXXX`
echo "inventory_loc=$INVDIR" >> $ORAINSTLOC
echo "inst_group=dba" >> $ORAINSTLOC

# Create directory structure owned by oracle:dba
install -d -o oracle -g dba $ORACLE_HOME 2>/dev/null
chown oracle.dba /opt/oracle -R

# Needed for older versions
INVPTRLOCARG=
if ! [ "$MAJOR_VER" = '10.2.0' -o "$MAJOR_VER" = '11.1.0' ]; then
    INVPTRLOCARG="-invPtrLoc $ORAINSTLOC"
fi

# Run oracle installer
( cd $CURRENTDIR && su oracle -c " \
    . $PROFILE; \
    export ORACLE_HOME=$ORACLE_HOME; \
    eval ${INSTALLER_BASE}/client/runInstaller \
        $INVPTRLOCARG \
        -silent \
        -waitforcompletion \
        -ignoresysprereqs \
        -responseFile $ORACLERSP \
" )

# If above fails, bail out here
if ( ! ls -1 $ORACLE_HOME/* >/dev/null 2>&1 ); then
    echo "Installation failed."
    rmdir $ORACLE_HOME
    exit 1
fi

# Copy post-install files
cp -p "$LDAPORA_SRC" $LDAPORA
cp -p "$SQLNETORA_SRC" $SQLNETORA
cp -p "$TNSNAMESORA_SRC" $TNSNAMESORA
cp -p "$ONSCONFIG_SRC" $ONSCONFIG
chown oracle:dba $LDAPORA $SQLNETORA $ONSCONFIG

# Set permissions
echo -e "Setting permissions...\c"
chmod -R a+rx $ORACLE_HOME
chmod -R ugo+w $ORACLE_HOME/opmn/conf
chmod -R ugo+w $ORACLE_HOME/opmn/logs
echo "Done."

# Relink files in ORACLE_HOME
echo -e "Relinking files...\c"
su oracle -c ". $PROFILE; export ORACLE_HOME=$ORACLE_HOME; cd $ORACLE_HOME && ./bin/relink all" >/dev/null 2>&1
echo "Done."

# Change SELinux context on files in $ORACLE_HOME/lib*
GETSEBOOL='/usr/sbin/getsebool'
if [ -x "$GETSEBOOL" ]; then
    case `$GETSEBOOL allow_execmod 2>/dev/null |awk '{print $3}'` in
        off|inactive)
            find ${ORACLE_HOME}/lib* \
                \( -name '*.so' -o -name '*.so.*' \) \
                -type f \
                -exec chcon -t textrel_shlib_t {} \;
            ;;
    esac
fi

# Repoint link to new install, effectively activating this install
[ -L "${BASEDIR}/${CLIENTLINK}" ] && rm -f "${BASEDIR}/${CLIENTLINK}"
ln -s "$CLIENTDIR" "${BASEDIR}/${CLIENTLINK}"

# Update tab files
#BOBWEEKLY=/opt/bob/scripts/run_bob.weekly
#[ -x "$BOBWEEKLY" ] && $BOBWEEKLY

# vim:et:sw=4:ts=4