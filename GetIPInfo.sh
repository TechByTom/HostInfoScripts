#!/bin/bash

#In case you don't want colors, pipe through this:
#sed -r "s/\x1B\[([0-9];)?([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"

#Check that we have geoiplookup available
command -v geoiplookup >/dev/null 2>&1 || { echo >&2 "Please install geoiplookup first!. (apt-get install geoip-bin)."; exit 1; }

function IPLookup(){
	ISP="$(whois $1|grep OrgName | cut -d " " -f9- | sed -n -e 'H;${x;s/\n/, /g;s/^,//;p;}')"
	geoIP="$(geoiplookup $publicIP | grep "GeoIP City Edition" | cut -d"," -f4,5)"

	if [ "$strHostname" ]; then #if we have a known Hostname
		echo -e "Hostname    : $(tput setaf 3)$strHostname$(tput sgr 0)"
	fi
        if [ "$strRevHostname" ]; then #if we have a known Reverse Hostname
                echo -e "RevHostname : $(tput setaf 3)$strRevHostname$(tput sgr 0)"
        fi
#	if [ -n "$(curl --silent https://www.abuseipdb.com/check/$publicIP | grep "was found in our database")" ] #if this IP is in the Abuse IP DB
#	then
#		echo "$publicIP appears in Abuse IP DB"
#	fi
        echo -e "IP Looked up: $(tput setaf 3)$1$(tput sgr 0)"
        echo -e "Located in  :$(tput setaf 3)$geoIP$(tput sgr 0)"
        echo -e "The ISP is  :$(tput setaf 3)$ISP$(tput sgr 0)"
	if false; then #to add - accept a flag to check for abuseipdb listing of this IP
		if [ -n "$(curl --silent https://www.abuseipdb.com/check/$1 | grep "was found in our database")" ]; then echo "$1" " appears in Abuse IP DB"; fi
	fi
	echo
}


#Check if we have a host as an argument
if [ "$#" -eq 0 ] #If we don't have an argument provided
then
	publicIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
	IPLookup "$publicIP"
else
	if [ -z "$(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"<<< "$1")" ] #If it doesn't match an IP regex...
	then
		if [ -z "$(grep -E "^[a-zA-Z0-9]+([-.]?[a-zA-Z0-9]+)*\.[a-zA-Z]+$"<<< "$1")" ] #and if it doesn't match a hostname regex...
		then
			echo "\"$1\" doesn't look like an IP or hostname, please try again."
		else #It's a hostname
			dig +short $1|
			while IFS= read -r line
			do
				strHostname="$1"
				if [ "$(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"<<< "$line")" ]; then
					#strRevHostname=$(dig +short -x $line | tr -d '\n' | sed 's/\.,/ /g'|sed 's/\ /, /g')
					strRevHostname="$(dig +short -x $line | tr '\n' ' ')"
					publicIP="$line"
					IPLookup "$publicIP"
					unset strRevHostname
                                	unset strHostname
				fi
			done
		fi
	else #Then it was an IP
		publicIP="$1"
		strRevHostname="$(dig +short -x $publicIP | tr '\n' ' ')"
		IPLookup "$publicIP"
		unset strRevHostname
	fi
fi
