#!/bin/bash
############################################################################
## This is an unofficial nym-mixnode installer, which downloads, configures
## and runs the Nym mixnode in less than 1 minute.
## It creates a nym user which runs the node with a little help of
## a systemd. It automates even the systemd.service creation, so
## everytime you change your node config, simply just do it with this script
## to make sure your Nym-mixnode is running and mixin' packets!
## -------------------------------------------------------------------------
## All credits go to the Nym team, creators of BASH, other FOSS used
## and some random people on stackoverflow.com.
## There might be some bugs in this script ... !
## So you'd better run this piece with caution.
## I will be not responsible if you fuck up your own machine with this.
##
## turn_on_tune_in_drop_out
############################################################################


function display_usage() {
	#printf "%b\n\n\n" "${WHITE}This script must be run with super-user privileges."
	#echo -e "\nUsage:\n__g5_token5eefd24a11c4a [arguments] \n"


      cat 1>&2 <<EOF
nym_install.sh 0.8.1 (2020-28-09)
The installer and launcher for Nym mixnode

USAGE:
    ./nym_install.sh [FLAGS]

FLAGS:
    -i  --install            Full installation and setup
    -c  --config             Run only the init command without installation
    -r, --run               Start the node without installation
    -h, --help              Prints help information
    -V, --version           Prints version information
    -s  --status            Prints status of the running node
    -f  --firewall          Firewall setup
    -p  --print             Create nym-mixnode.service for systemd
    -l  --print-local       Create nym-mixnode.service for systemd LOCALLY in the current directory

EOF
}


## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT

## required packages list
install_essentials='curl ufw sudo git pkg-config build-essential libssl-dev'
## Checks if all required packages are installed
## If not then it installs them with apt-get
if
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
   printf "%b\n\n\n" "${WHITE} Checking requirements ..."
   dpkg-query -l 'curl' 'ufw' 'sudo' 'git' 'pkg-config' 'build-essential' 'libssl-dev' > /dev/null 2>&1
  then
   printf "%b\n\n\n" "${WHITE} You have all the required packages for this installation ..."
   printf "%b\n\n\n" "${LGREEN} Continuing ..."
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
  else
   printf "%b\n\n\n" "${WHITE} Some required packages for this script are not installed"
   printf "%b\n\n\n" "${WHITE} Installing them for you"
   apt-get install ${install_essentials} -y > /dev/null 2>&1
   printf "%b\n\n\n" "${WHITE} Now you have all the required packages for this installation ..."
   printf "%b\n\n\n" "${LGREEN} Continuing ... "
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
fi





#while true; do
#printf "${RED}LOVE\n\n${YELLOW}IS\n\n${LBLUE}ALL\n\n${WHITE}YOU\n\n${LGREEN}\nNEED\n\n ${RED}========${YELLOW}========${LBLUE}========${WHITE}========${LGREEN}========\n\n"
#sleep 1
#done


## Prints the Nym banner to stdout from hex
printf "%b\n" "0D0A0D0A0D0A2020202020205F205F5F20205F2020205F205F205F5F205F5F5F0D0A20202020207C20275F205C7C207C207C207C20275F205C205F205C0D0A20202020207C207C207C207C207C5F7C207C207C207C207C207C207C0D0A20202020207C5F7C207C5F7C5C5F5F2C207C5F7C207C5F7C207C5F7C0D0A2020202020202020202020207C5F5F5F2F0D0A0D0A2020202020202020202020202028696E7374616C6C6572202D2076657273696F6E20302E392E31290D0A" | xxd -p -r

## Checks if essential packages are installed
## if not then it installs them
#dpkg-query -l 'curl' 'ufw' 'sudo' 'git' 'pkg-config' 'build-essential' 'libssl-dev' 'asdasd' > /dev/null 2>&1 || apt
# creates a user nym with home directory
function nym_usercreation() {
  useradd -U -m -s /sbin/nologin nym
  printf "%b\n\n\n"
  printf "%b\n\n\n" "${YELLOW} Creating ${WHITE} nym user\n\n"
  if ls -a /home/ | grep nym > /dev/null 2>&1
  then
    printf "%b\n\n\n" "${WHITE} User ${YELLOW} nym ${LGREEN} created ${WHITE} with a home directory at ${YELLOW} /home/nym/"

  else
    printf "%b\n\n\n" "${WHITE} Something went ${RED} wrong ${WHITE} and the user ${YELLOW} nym ${WHITE}was ${RED} not created."

  fi
}

## Checks if nym user exists and then download the latest nym-mixnode binaries to nym home directory
function nym_download() {
 if
   cat /etc/passwd | grep nym > /dev/null 2>&1
 then
    printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
    printf "%b\n\n\n" "${YELLOW} Downloading ${WHITE} nym-mixnode binaries for the nym user ..."
    cd /home/nym && curl -LO https://github.com/nymtech/nym/releases/download/v0.9.2/nym-mixnode_linux_x86_64
    printf "%b\n\n\n"
    printf "%b\n\n\n" "${WHITE} nym-mixnode binaries ${LGREEN} successfully downloaded ${WHITE}!"
 else
    printf "%b\n\n\n"
    printf "%b\n\n\n" "${WHITE} Download ${RED} failed..."
 fi
}


## checks for the binaries and then makes them executable
function nym_chmod() {

 if ls -la /home/nym/ | grep nym-mixnode_linux_x86_64 > /dev/null 2>&1
 then
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
   printf "%b\n\n\n" "${WHITE} Making the nym binary ${YELLOW} executable ..."
   chmod 755 /home/nym/nym-mixnode_linux_x86_64
   printf "%b\n\n\n" "${LGREEN} Successfully ${WHITE} made the file ${YELLOW} executable !"
 else
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
   printf "%b\n\n\n" "${WHITE} Something went ${RED} wrong, wrong path..?"
 fi
}

## change ownerships of all files within nym home directory / they were downloaded as root so now we return them back to nym
function nym_chown() {
 chown -R nym:nym /home/nym/
 printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
 printf "%b\n\n\n" "${WHITE} Changed ownership of all conentes in ${YELLOW}/home/nym/ ${WHITE} to ${YELLOW}nym:nym"
}

## Get server ipv4
ip_addr=`curl -sS v4.icanhazip.com`



## Check if ufw is enabled or not and allows 1789/tcp and 22/tcp
function nym_ufw {
printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
printf "%b\n\n\n" "${WHITE} Setting up the ${YELLOW} firewall ${WHITE}: "
ufw status | grep -i in && inactive="1" || is_active="1" > /dev/null 2>&1


if [ "${inactive}" == 1 ]
then
    printf '\n\n\n'
    printf "%b\n\n\n" "${YELLOW} ufw ${WHITE} (Firewall) is ${RED} inactive"
    sleep 1
    ufw allow 1789/tcp > /dev/null 2>&1 && printf "%b\n\n\n" "${YELLOW} port ${LBLUE} 1789 ${WHITE} was ${LGREEN}allowed ${WHITE} in ufw settings"
## Allow ssh just in case
## To avoid locking the user from the server
    ufw allow 22/tcp && ufw limit 22/tcp
    sudo ufw --force enable
    ufw status
else [ "$is_active" == 1 ]

    printf '\n\n\n'
    printf "%b\n\n\n" "${YELLOW} ufw ${WHITE} (Firewall) is ${LGREEN} active"
    sleep 1
    ufw allow 1789/tcp > /dev/null 2>&1 && printf "%b\n\n\n" "${YELLOW} port ${LBLUE} 1789 ${WHITE} was ${LGREEN}allowed ${WHITE} in ufw settings"
    ufw status


fi
}


## This creates systemd.service script
## It looks for multiple files in the /home/nym/.nym/mixnodes directory
## and prompts user for input
## which it then uses to properly print the ExecStart part in the file.
## Useful if you have multiple configs and want to quickly change the node for systemd
function nym_systemd_print() {
  printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
  printf "%b\n\n\n" "${YELLOW} Creating ${WHITE} a systemd service file to run nym-mixnode in the background: "
  directory='NymMixNode'
                #id=$(echo "$i" | rev | cut -d/ -f1 | rev)
                printf '%s\n' "[Unit]" > /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "Description=Nym Mixnode (0.9.2)" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "[Service]" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "User=nym" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "ExecStart=/home/nym/nym-mixnode_linux_x86_64 run --id NymMixNode" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "KillSignal=SIGINT" >> /etc/systemd/system/nym-mixnode.service				
                printf '%s\n' "Restart=on-failure" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "RestartSec=30" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitInterval=350" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitBurst=10" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "LimitNOFILE=65535" >> /etc/systemd/system/nym-mixnode.service			
                printf '%s\n' "" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "[Install]" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "WantedBy=multi-user.target" >> /etc/systemd/system/nym-mixnode.service
  if [ -e /etc/systemd/system/nym-mixnode.service ]
    then
      printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
      printf "%b\n\n\n" "${WHITE} Your node with id ${YELLOW} $directory ${WHITE} was ${LGREEN} successfully written ${WHITE} to the systemd.service file \n\n\n"
      printf "%b\n\n\n" " ${LGREEN} Enabling ${WHITE} it for you"
      systemctl enable nym-mixnode
      printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
      printf "%b\n\n\n" "${WHITE}   nym-mixnode.service ${LGREEN} enabled!"
    else
      printf "%b\n\n\n" "${WHITE} something went wrong"
      exit 2
  fi
}

## For printing the systemd.service to the current folder
## and not to /etc/systemd/system/ directory
function nym_systemd_print_local() {
  directory='NymMixNode'

                #id=$(echo "$i" | rev | cut -d/ -f1 | rev)
                printf '%s\n' "[Unit]" > /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "Description=Nym Mixnode (0.9.2)" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "[Service]" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "User=nym" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "ExecStart=/home/nym/nym-mixnode_linux_x86_64 run --id NymMixNode" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "KillSignal=SIGINT" >> /etc/systemd/system/nym-mixnode.service				
                printf '%s\n' "Restart=on-failure" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "RestartSec=30" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitInterval=350" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitBurst=10" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "LimitNOFILE=65535" >> /etc/systemd/system/nym-mixnode.service				
                printf '%s\n' "" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "[Install]" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "WantedBy=multi-user.target" >> /etc/systemd/system/nym-mixnode.service
    current_path=$(pwd)
    if
      [ -e ${current_path}/nym-mixnode.service ]
    then
      printf "%b\n\n\n" "${WHITE} Your systemd script with id $directory was ${LGREEN} successfully written ${WHITE} to the current directory"
      printf "%b\n" "${YELLOW} $(pwd)"
    else
      printf "%b\n\n\n" "${WHITE} Printing of the systemd script to the current folder ${RED} failed. ${WHITE} Do you have ${YELLOW} permissions ${WHITE} to ${YELLOW} write ${WHITE} in ${pwd} ${YELLOW}  directory ??? "
    fi
}

## Checks if the path is correct and then prompts user for input to get $id and optional $location.
## Then runs the binary with the given input from user and builds config.
function nym_init() {
 #get server's ipv4 address
 ip_addr=`curl -sS v4.icanhazip.com`
 printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
 printf "%b\n\n\n" "${YELLOW} Configuration ${WHITE} file and keys: "
 if
   pwd | grep /home/nym > /dev/null 2>&1
 then
   printf "%b\n\n\n" "${WHITE} Your node name will be ${YELLOW} 'NymMixNode'. ${WHITE} Use it nextime if you restart your server or the node is not running"
   printf "%b\n\n\n"
   sleep 2
   location=(Nuremberg Helsinki CapeTown Dubai Iowa Frankfurt Toronto Netherlands Berlin Bayern London Toulouse Amsterdam Nuremberg Virginia Montreal Miami Stockholm Tokyo Barcelona Singapore)
   rand=$[$RANDOM % ${#location[@]}]
   location1=${location[$rand]}
   printf "%b\n\n\n" "${WHITE} Location: ${YELLOW} ${location1} "
   sleep 1     
   layer=(1 2 3)   
   rand1=$[$RANDOM % ${#layer[@]}]
   layer1=${layer[$rand1]}
   printf "%b\n\n\n" "${WHITE} Layer: ${YELLOW} ${layer1} "
   sleep 1    
   walletx=(VJL8gRgW5v6L3bRX8ThVcLF8EKSCmSqD2Hw8yYzqWDsxKwLdgzCiWgcvzFrDbiGR6ATnpF6PKDhKpaqo VJLGAmrAAVwjF22qw22pPawufwaKQG5MBUSLcu14dSDt5JgpwYUkNfG6uYFQxDpXSXpAhZgVPEJ5DqZs VJL7SBh3jMRJUvEswRU8smUdKkHLpeZg7ZyjFqaih97pPDt6JH9NtkNvjD8H7YnNUqpeJVhVZxJGY9qS VJL7cybWGfvRBYneeGYjrqLaydq3YJFjgJg1AVXEFMA8PPLWgdUCmd3P1BweX1Za9iScG6fMAtWGXJwF VJLK4LZZqooM6x94thRvQFvqMbodYBTNxhD9ewvoM8DE1hLUhgafrQ8f1AnAXYmj8F7x6kDBh68AxoFQ VJLHEsv7kUDdpPy8qLDJrBiiDZxpoMSjNsKbR4GPr1g6KGWe4iizvus61soKz7mN1nyio9BGhyeLLxYw VJLG3sPnuJd7kKGiG49r4G6a784tGkqAMfyg8kkvkHAsskPzi27m3K87Y7xmHxnzzs1Wv4SwAtc1418g VJLB4rXc78ZmQ2QieY25fzpZEjju5tWtjNxxdjcGdHc3BhFUcxKnSV6skjZgYEC48yrGF731J82WN5ve)
   rand2=$[$RANDOM % ${#walletx[@]}]
   walletx1=${layer[$rand2]}
   printf "%b\n\n\n" "${WHITE} Address for the incentives rewards will be ${YELLOW} ${walletx1} "
   sleep 1  
   read -p  $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;37m] Listening host ? \e[1;92mYes - (Yy) \e[1;37m or  \e[1;91mNo - (Nn)  ?? :  \e[0m' yn
   printf '\n\n\n'
   case $yn in
       [Yy]*) printf "%b\n\n\n" "${WHITE} Set listening host for ip $ip_addr ..."
       	  read ahost
	  printf "%b\n\n\n" "${WHITE}  Host $ahost ... "
          sudo -u nym -H ./nym-mixnode_linux_x86_64 init --id 'NymMixNode' --location $location1 --incentives-address $walletx1 --host $ahost --announce-host $ip_addr  --layer $layer1
          ;;
       [Nn]* )
          sudo -u nym -H ./nym-mixnode_linux_x86_64 init --id 'NymMixNode' --location $location1 --incentives-address $walletx1 --host $ip_addr  --layer $layer1
	  ;;
    esac  
   printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
   # borrows a shell for nym user to initialize the node config.
   printf "%b\n\n\n"
   printf "%b\n\n\n" "${WHITE}  Your node has id ${YELLOW} 'NymMixNode' ${WHITE} located in ${LBLUE} $location1 ${WHITE} with ip ${YELLOW} $ip_addr ${WHITE}... "
   printf "%b\n\n\n" "${WHITE} Config was ${LGREEN} built successfully ${WHITE}!"
 else
   printf "%b\n\n\n" "${WHITE} Something went ${RED} wrong {WHITE}..."
   exit 2
 #set +x
 fi
}
function nym_systemd_run() {
    directory="NymMixNode"
    service_id=$(cat /etc/systemd/system/nym-mixnode.service | grep id | cut -c 55-)


   ## Check if user chose a valid node written in the systemd.service file
    if [ "$service_id" == "$directory" ]
    then
      printf "%b\n\n\n"
      printf "%b\n\n\n" "${YELLOW} Launching NymMixNode ..."
      systemctl start nym-mixnode.service
    else
      printf "%b\n\n\n" "${WHITE} The node you selected is ${RED} not ${WHITE} in the  ${YELLOW} nym-mixnode.service ${WHITE} file. Create a new systemd.service file with ${LBLUE} sudo ./nym-install.sh -p"
      exit 1
    fi

   ## Check if the node is running successfully
    if
      systemctl status nym-mixnode | grep -e "active (running)" > /dev/null 2>&1
    then
      printf "%b\n\n\n"
      printf "%b\n\n\n" "${WHITE} Your node ${YELLOW} ${service_id} ${WHITE} is ${LGREEN} up ${WHITE} and ${LGREEN} running!!!!"
    else
      printf "%b\n\n\n" "${WHITE} Node is ${RED} not running ${WHITE} for some reason ...check it ${LBLUE} ./nym-install.sh -s [--status]"
    fi
  }



## Print the status nym-mixnode.service
function nym_status() {
  systemctl status nym-mixnode | more
  if
      systemctl status nym-mixnode | grep -e "active (running)" > /dev/null 2>&1
    then
      printf "%b\n\n\n"
      printf "%b\n\n\n" "${WHITE} Your ${YELLOW} node ${WHITE} is ${LGREEN} up ${WHITE} and ${LGREEN} running ${WHITE}!"
      printf "%b\n\n\n"
  elif
      systemctl status nym-mixnode | more | grep -i inactive  > /dev/null 2>&1
    then
      printf "%b\n\n\n"
      printf "%b\n\n\n" "${WHITE} Your ${YELLOW} node ${RED}is not running ${WHITE}. Run the script with -r option"
      printf "%b\n\n\n"
  fi
}

## Checks if port 1789 is enabled in firewall settings / ufw


## display usage if the script is not run as root user
	if [[ $USER != "root" ]]
	then
    printf "%b\n\n\n" "${WHITE} This script must be run as ${YELLOW} root ${WHITE} or with ${YELLOW} sudo!"
		exit 1
	fi
## Full install, config and launch of the nym-mixnode
  if [ "$1" = "-i" ]; then
    while [ ! -d /home/nym ] ; do nym_usercreation ; done
    cd /home/nym/ || printf "%b\n\n\n" "${WHITE}failed sorry"
    if [ ! -e /home/nym/nym-mixnode_linux_x86_64 ] ; then nym_download ; fi
    nym_chmod
    nym_chown
    nym_init
    nym_systemd_print
    nym_ufw
    nym_systemd_run
    printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
    printf "%b\n" "${WHITE}                     Make sure to also check the official docs ! "
    printf "%b\n\n\n"
    printf "%b\n" "${LGREEN}                            https://nymtech.net/docs/"
    printf "%b\n\n\n"
    printf "%b\n" "${WHITE}                              Check the dashboard"
    printf "%b\n\n\n"
    printf "%b\n" "${LBLUE}                          https://testnet-explorer.nymtech.net/"
    printf "%b\n\n\n"
    printf "%b\n" "${WHITE}                                       or"
    printf "%b\n\n\n"
    printf "%b\n" "${YELLOW}                           ./nym_install.sh --status"
    printf "%b\n\n\n"
    printf "%b\n" "${WHITE}                              to see how many packets"
    printf "%b\n\n\n"
    printf "%b\n" "${WHITE}                            You have ${YELLOW} mixed ${WHITE} so far ! "
    printf "%b\n\n\n"
    printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
  fi
## Configure the node
  if [[ ("$1" = "--init") ||  "$1" = "-c" ]]
  then
    cd /home/nym/ > /dev/null 2>&1 && nym_init || printf "%b\n" "\n\n\n${YELLOW} /home/nym/ ${RED} does not exist. ${WHITE} Create it with the ${YELLOW} -i ${WHITE} or ${YELLOW} --install ${WHITE} flag first.\n\n\n"
  fi
## Create the systemd.service file
  if [[ ("$1" = "--print") ||  "$1" = "-p" ]]
  then
    cd /home/nym/  > /dev/null 2>&1 && nym_systemd_print || printf "%b\n" "\n\n\n${YELLOW} /home/nym/ ${RED} does not exist. ${WHITE} Create it with the ${YELLOW} -i ${WHITE} or ${YELLOW} --install ${WHITE} flag first.\n\n\n"

  fi
##  Create the systemd.service file locally
  if [[ ("$1" = "--print-local") ||  "$1" = "-l" ]]
  then
  cd /home/nym/  > /dev/null 2>&1 && nym_systemd_print_local || printf "%b\n" "\n\n\n${YELLOW} /home/nym/ ${RED} does not exist. ${WHITE} Create it with the ${YELLOW} -i ${WHITE} or ${YELLOW} --install ${WHITE} flag first.\n\n\n"
    nym_systemd_print_local
  fi
## Run the node
  if [[ ("$1" = "--run") ||  "$1" = "-r" ]]
  then
    cd /home/nym/.nym/mixnodes/ > /dev/null 2>&1  && nym_systemd_run || printf "%b\n" "\n\n\n${RED}no${YELLOW} config ${RED} found ${WHITE} Create it with the ${YELLOW} -c ${WHITE} or ${YELLOW} --init ${WHITE} flag first.\n\n\n"
  fi
## Get status from the systemdaemon file
  if [[ ("$1" = "--status") ||  "$1" = "-s" ]]
  then
    nym_status
  fi

## Setup the firewall
  if [[ ("$1" = "--firewall") ||  "$1" = "-f" ]]
  then
    nym_ufw
  fi
## If no arguments supplied, display usage
  if [ -z "$1" ]
  then
    display_usage
  fi

## Check whether user had supplied -h or --help . If yes display usage
  if [[ ("$1" = "--help") ||  "$1" = "-h" ]]
  then
    display_usage
	exit 0
  fi
## Prints the version of Nym used
  if [[ ("$1" = "--version") ||  "$1" = "-V" ]]
  then
     display_usage
	exit 0
  fi

#nym_usercreation
#nym_download
#nym_chmod
#nym_chown
#nym_init
#nym_run
