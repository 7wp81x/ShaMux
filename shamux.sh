#!/bin/bash
# Author: 7wp81x
# Github: https://github.com/7wp81x

banner() {
    clear
    echo -e "\033[1;97m    __ _"
    echo -e "\033[1;97m   / _\\ |__   __ _ \e[1;92m /\\/\\  _   ___  __"
    echo -e "\033[1;97m   \\ \\| '_ \\ / _\` |\033[1;92m/    \\| | | \\ \\/ /"
    echo -e "\033[1;97m   _\\ \\ | | | (_| \\e[1;92m/ /\\/\\ \\ |_| |>  <"
    echo -e "\033[1;97m   \\__/_| |_|\\__,_\\e[1;92m\\/    \\/\\__,_/_/\\_\\ \033[1;93mv1.0\n"
    echo -e " \033[1;37;42m Termux Anonimizer by: 7wp81x (Github) \033[0m"
    echo -e "\033[0m"
}

check_requirements() {
	bin="$PREFIX/bin"
	mising="0"
	if [ ! -f "${bin}/tor" ];then
	    echo -e "\033[1;92m[\033[1;97m!\033[1;92m] '\033[1;93mtor\033[1;92m' is not installed...\033[0m"
	    missing="1"
	fi

        if [ ! -f "${bin}/nc" ];then
	    echo -e "\033[1;92m[\033[1;97m!\033[1;92m] '\033[1;93mnetcat\033[1;92m' is not installed...\033[0m"
	    missing="1"
	fi
 
	if [ ! -f "${bin}/torsocks" ];then
	    echo -e "\033[1;92m[\033[1;97m!\033[1;92m] '\033[1;93mtorsocks\033[1;92m' is not installed...\033[0m"
	    missing="1"
        fi

	if [ ! -f "${bin}/obfs4proxy" ];then
            echo -e "\033[1;92m[\033[1;97m!\033[1;92m] '\033[1;93mobfs4proxy\033[1;92m' is not installed...\033[0m"
	    missing="1"
        fi

	if [ ! -f "${bin}/sv" ]; then
	    echo -e "\033[1;92m[\033[1;97m!\033[1;92m] '\033[1;93mtermux-services\033[1;92m' is not installed...\033[0m"
	    missing="1"
	fi

	if [[ $missing == "1" ]];then
	    echo -e "\n\033[1;92m[\033[1;97m*\033[1;92m] execute \033[1;93minstall.sh\033[1;92m to install missing packages... \033[0m "
	    exit
	fi

}

main() {
    torrc_path="$PREFIX/etc/tor"

    if [ ! -f "config" ];then
        touch config
    else
        rm config
    fi

    printf "\033[1;92m[\033[1;97m*\033[1;92m] Change IP timeout seconds (\033[1;97mdefault: 600\033[1;92m): \033[1;97m"
    read mtimeout

    if [[ $mtimeout == "" ]];then
        mtimeout="600"
    elif [[ ! $mtimeout =~ ^[0-9]+$ ]];then
        mtimeout="600"
    fi

    printf "\033[1;92m[\033[1;97m*\033[1;92m] Tor ctrl port password (\033[1;97mdefault: random\033[1;92m): \033[1;97m"
    read tor_password
    
    characters="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxzy"
    if [[ $tor_password == "" ]];then
	tor_password=$(tr -dc "$characters" < /dev/urandom | head -c 20)
    fi
    
    hashed_password=$(tor --quiet --hash-password "$tor_password")
    printf "\033[1;92m[\033[1;97m*\033[1;92m] Generated password: \033[1;97m$tor_password\033[0m"
    echo "ControlPort 9051" >> "config"
    echo "CookieAuthentication 1" >> "config"
    echo "HTTPTunnelPort 8118" >> "config"
    echo "CircuitBuildTimeout 30" >> "config"
    echo "LearnCircuitBuildTimeout 0" >> "config"
    echo "MaxCircuitDirtiness $mtimeout" >> "config"
    echo "ClientTransportPlugin obfs4 exec $PREFIX/bin/obfs4proxy -obfs4-distBias" >> "config"
    echo "HashedControlPassword $hashed_password" >> "config"

    cat ip_changer| sed "s+CTRL_PORT_PASSWORD+$tor_password+g" > changeip

    if [ -f "$torrc_path/torrc" ]; then
        mv "$torrc_path/torrc" "$torrc_path/"$(date +"torrc.%b_%d_%Y_%H-%M-%S.bk")
    fi
    mv config "$torrc_path/torrc"
    mv changeip $PREFIX/bin/
    termux-reload-settings
    sv-enable tor
    sv up tor 
    chmod +x "$PREFIX/bin/changeip"
    echo -e "\n\n\033[1;92m[\033[1;97m+\033[1;92m] run '\033[1;97m. torsocks on\033[1;92m' to on Tor mode.\033[0m"
    echo -e "\033[1;92m[\033[1;97m+\033[1;92m] run '\033[1;97m. torsocks off\033[1;92m' to off Tor mode.\033[0m"
    echo -e "\033[1;92m[\033[1;97m+\033[1;92m] run '\033[1;97mchangeip\033[1;92m' to change identity.\033[0m"

}

banner
check_requirements
main
