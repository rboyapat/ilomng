#ilomng

Bash script for managing the hardware using out of band management (ilo/ilom/drac) in a multi datacenter site.

###Prerequesites
curl package should be installed on the system where you are executing the script

```
Linux:
rpm -ihv curl
```

populate ilo/ilom/drac config files for each datacenter in your home directory. Sample config files below

```
mkdir -p ~/.ilomng ; chmod 700 ~/.ilomng
touch ~/.ilomng/dc1.cfg ; 
touch ~/.ilomng/dc2.cfg ; 

**~/.ilomng/dc1.cfg:**

ILO_LOGIN=root

ILO_NETWORK=10.10.10.0
ILO_SUBNET=255.255.255.0
ILO_GW=10.10.10.1

ILO_DNS_SERVER1=10.10.10.2
ILO_DNS_SERVER2=10.10.10.3

ILO_NTP_SERVER1=10.10.10.4
ILO_NTP_SERVER2=10.10.10.5

ILO_SNMP_SERVER1=10.10.10.6
ILO_SNMP_TRAPCOMMUNITY="public"
ILO_SNMP_SYS_CONTACT=hd@ilomng.com
ILO_SNMP_SYS_LOCATION="datacenter1"
ILO_SNMP_SECURITY_NAME=snmpuser
ILO_SNMP_AUTHN_PASSPHRASE=passphrase99
ILO_SNMP_PRIVACY_PASSPHRASE=secret99
VIRTUAL_MEDIA_URL="http:\/\/webserverip\/html\/spp_2015.10.0-SPP2015100.iso"
```
