#ilomng

Bash script for managing the hardware using out of band management (ilo/ilom/drac) in a multi datacenter site.

##Prerequesites
>curl package should be installed on the system where you are executing the script

```
Linux:
rpm -ihv curl
```

>populate ilo/ilom/drac config files for each datacenter in your home directory. Sample config files below

```
mkdir -p ~/.ilomng ; chmod 700 ~/.ilomng
touch ~/.ilomng/dc1.cfg ; 
touch ~/.ilomng/dc2.cfg ; 
```
