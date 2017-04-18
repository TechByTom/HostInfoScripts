#!/bin/bash

HIGHLIGHT='\033[0;33m'
NC='\033[0m' # No Color

#Check that we have geoiplookup available
command -v geoiplookup >/dev/null 2>&1 || { echo >&2 "Please install geoiplookup first!. (apt-get install geoip-bin)."; exit 1; }

function IPLookup(){
        ISP=$(whois $1|grep OrgName | cut -d " " -f9- | sed -n -e 'H;${x;s/\n/, /g;s/^,//;p;}')
        geoIP=$(geoiplookup $1 | grep "GeoIP City Edition" | cut -d"," -f4,5)

        if [ "$strHostname" ]; then
                printf "Hostname  : ${HIGHLIGHT}$strHostname${NC}\n"
        fi
        printf "Look up IP: ${HIGHLIGHT}$1${NC}\n"
        printf "Located in:${HIGHLIGHT}$geoIP${NC}\n"
        printf "The ISP is:${HIGHLIGHT}$ISP${NC}\n"
        echo
}


#Check if we have a host as an argument
if [ $# -eq 0 ] #If we don't have an argument provided
then
        publicIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
        IPLookup $publicIP
else
        if [ -z $(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"<<< "$1") ] #If it doesn't match an IP regex...
        then
                if [ -z $(grep -E "^[a-zA-Z0-9]+([-.]?[a-zA-Z0-9]+)*\.[a-zA-Z]+$"<<< "$1") ] #and if it doesn't match a hostname regex...
                then
                        echo "\"$1\" doesn't look like an IP or hostname, please try again."
                else #It's a hostname
                        dig +short $1|
                        while IFS= read -r line
                        do
                                strHostname=$1
                                if [ $(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"<<< "$line") ]; then
                                        IPLookup "$line"
                                fi
                                unset strHostname
                        done
                fi
        else
                publicIP=$1
                IPLookup $publicIP
        fi
fi
