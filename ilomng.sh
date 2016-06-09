#!/bin/bash

# Written by Ravi Kumar Boyapati <rboyapat@gmail.com>

# Environmental variables

case $(uname -s) in
        Darwin)
                PATH=/opt/local/bin:/usr/local/bin:/bin:/usr/bin:/opt/local/sbin:/usr/local/sbin:/usr/sbin:/sbin
                ping="ping -t 1"
                ;;
        SunOS)
                PATH=/usr/local/sbin:/usr/local/bin:/usr/sfw/bin:/opt/sfw/bin:/sbin:/bin:/usr/sbin:/usr/bin
                ping="ping"
                ;;
        Linux)
                PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
                ping="ping -w 1"
                ;;
        *)
                echo "Unsupported platform"
                exit 1
                ;;
esac

umask 022

#Command variables

echo="echo -e"
curl="curl -s"
wget="wget"
egrep="egrep"


# Error Variables

: ${E_USAGE:=60}
: ${E_NOofArgs:=61}
: ${E_HELP:=62}
: ${E_NOACTION:=63}
: ${E_NORESPONSE:=64}
: ${E_NODC:=65}
: ${E_NOCONFIGFILE:=66}

# Exit Variables

: ${USAGE:=80}
: ${HELP:=81}


# STATIC Variables

MYPATH=$(dirname $0)
MYNAME=$(basename $0)

# Functions

# Formatting - Line function definition

Line()
{
	for (( COUNT=0 ; COUNT<$1; COUNT++ )); do
  		$echo
 	done
}

# Usage function definition

Usage() 
{
	Line 3 
	$echo "usage:\t$0 [-dhv]  [-a <ACTION> ]  [ -c <DATACENTER> ] [ -p ADMINPW ] ILOIP"
	Line 1
	$echo "\t\t-h help"
	$echo "\t\t-v Run in verbose mode"
	$echo "\t\t-d Run in debug mode"        
	$echo "\t\t-a Specify the type of action like getiloinfo | gethostinfo etc."        
	$echo "\t\t-c Specify the data center " 
	Line 1
	$echo "\tEg1 - To get info about the HP Ilo: $0 -a getiloinfo -c dc1 -p password 192.10.0.0 "
	Line 3 
	exit ${1:-$USAGE}
}

PingTest ()
{

	IP=$1

	: {$IP?"echo no ip; exit1"}

	$ping $IP 2>&1 > /dev/null

	if  [ $? != 0 ] ; then
		$echo "Server with Ilom/Alom IP - $IP is not responding for Ping test" 
		$echo "Check if the Server is configured and in network.............." 
		exit $E_NORESPONSE
	fi
}

LoadConfigs ()
{
	source ~/.ilomng/$1.ilocfg
	if [ $? != 0 ]; then
		$echo "Datacenter config file missing..."
		exit $E_NOCONFIGFILE
	fi
}

GetIloInfo () 
{
	$curl --insecure "https://${HPILOIP}/xmldata?item=all"
}

ResetIlo ()
{
	SRCXML=${MYPATH}/make/hp/ribcl/Reset_RIB.xml
        TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/g" -e "s/ADMINPW/${ADMINPW}/g" ${SRCXML} )
        $curl --insecure -X POST -d "${TGTXML}" "https://${HPILOIP}/ribcl"
}

ResetSys()
{
	SRCXML=${MYPATH}/make/hp/ribcl/Reset_Server.xml
        TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/g" -e "s/ADMINPW/${ADMINPW}/g" ${SRCXML} )
        $curl --insecure -X POST -d "${TGTXML}" "https://${HPILOIP}/ribcl"
}

BootMedia()
{
	case $ACTION in
		bootnet)
			BOOT_MEDIA=network
			;;
		bootcdrom)
			BOOT_MEDIA=cdrom
			;;
		boothd)
			BOOT_MEDIA=hdd
			;;
		bootfloppy)
			BOOT_MEDIA=floppy
			;;
		bootbios)
			BOOT_MEDIA=RBSU
			;;
		bootusb)
			BOOT_MEDIA=USB
			;;
		bootuefi)
			BOOT_MEDIA=UEFI_Shell
			;;
		bootnormal)
			BOOT_MEDIA=normal
			;;
		*)
			echo "Wrong boot media specified"
			Usage ${E_NOACTION}
			;;
	esac
	

	SRCXML=${MYPATH}/make/hp/ribcl/Boot_Media.xml
        TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/g" -e "s/ADMINPW/${ADMINPW}/g" -e "s/BOOT_MEDIA/${BOOT_MEDIA}/g" ${SRCXML} )
        $curl --insecure -X POST -d "${TGTXML}" "https://${HPILOIP}/ribcl"
	ResetSys
}

GetDataOP ()
{
	case $ACTION in
		getilosnmp)
			SRCXML=${MYPATH}/make/hp/ribcl/Get_SNMP_IM.xml
			;;
		gethostinfo)
			SRCXML=${MYPATH}/make/hp/ribcl/Get_Host_Data.xml
			;;
		getvm)
                        SRCXML=${MYPATH}/make/hp/ribcl/Get_VM_Status.xml
                        ;;	
		*)
			$echo "Check the Server action..."
                        Usage ${E_NOACTION}
                        ;;
	esac

	TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/g" -e "s/ADMINPW/${ADMINPW}/g" ${SRCXML} )
	$curl --insecure -X POST -d "${TGTXML}" "https://${HPILOIP}/ribcl"
}

SetDataOP ()
{
	case $ACTION in
		setilosnmp)
			SRCXML=${MYPATH}/make/hp/ribcl/Mod_SNMP_IM_Settings.xml
			TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/" -e "s/ADMINPW/${ADMINPW}/" -e "s/ILO_SNMP_SERVER1/${ILO_SNMP_SERVER1}/" \
				-e "s/ILO_SNMP_TRAPCOMMUNITY/${ILO_SNMP_TRAPCOMMUNITY}/" -e "s/ILO_SNMP_SYS_CONTACT/${ILO_SNMP_SYS_CONTACT}/" \
				-e "s/ILO_SNMP_SYS_LOCATION/${ILO_SNMP_SYS_LOCATION}/" -e "s/ILO_SNMP_SECURITY_NAME/${ILO_SNMP_SECURITY_NAME}/" \
				-e "s/ILO_SNMP_AUTHN_PASSPHRASE/${ILO_SNMP_AUTHN_PASSPHRASE}/" -e "s/ILO_SNMP_PRIVACY_PASSPHRASE/${ILO_SNMP_PRIVACY_PASSPHRASE}/" ${SRCXML} )
			;;
		setvm)
			SRCXML=${MYPATH}/make/hp/ribcl/Set_VM_Status.xml
			TGTXML=$(sed -e "s/ILO_LOGIN/${ILO_LOGIN}/" -e "s/ADMINPW/${ADMINPW}/" -e "s/VIRTUAL_MEDIA_URL/${VIRTUAL_MEDIA_URL}/" ${SRCXML} )
			;;
		*)
			$echo "Check the Server action..."
                        Usage ${E_NOACTION}
                        ;;
	esac
	
	$curl --insecure -X POST -d "${TGTXML}" "https://${HPILOIP}/ribcl"
}

#-------Main Proogram------------#

while getopts "hvda:c:p:" CHOICE
do
	case $CHOICE in
		h)  
			Usage ${HELP} 
			;;
		v) 
			$echo "Running in verbose mode"
			set -v 
			;;
		d) 
			$echo "Running in debug mode"
			set -x 
			;;
		a)  
			ACTION="$OPTARG"
			;;
		c)
			DATACENTER="$OPTARG"
			;;
		p)
			ADMINPW="$OPTARG"
			;;
		*) 
			$echo " Wrong no of arguments..."
			Usage ${E_NOofArgs}
			;;
	esac
done

shift $((OPTIND-1))

LoadConfigs $DATACENTER


for HPILOIP in $@
do
	$echo -n "${HPILOIP}:"

	PingTest ${HPILOIP}

	case $ACTION in
		getiloinfo)
			GetIloInfo
			;;
		resetilo)
			ResetIlo
			;;
		resetsys)
			ResetSys
			;;
		boot*)
			BootMedia
			;;
		get*)
			GetDataOP
			;;
		set*)
			SetDataOP
			;;
		* )   
			$echo "Check the Server action..."
			Usage ${E_NOACTION}
			;;
	esac

done

exit 0
