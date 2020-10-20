#!/bin/bash

OPENSRC_DIR=/QOpenSys/pkgs/bin

################################################################################
#
#                               Procedures.
#
################################################################################

#       exist_directory dest
#
#       dest is an directory to check
#
#       exit 1 (succeeds) directort exist, else 0.

exist_directory()

{	
        [ -d "${1}" ] && return 0  || return 1      

}

#
#       install_yum_dependencies
#


install_yum_dependencies()

{	
		yum -y install 'git' 'make-gnu' 'jq'    
}

#
#       install_ileastic
#


install_ileastic()

{
		mkdir ILEastic && cd ILEastic
		git -c http.sslVerify=false clone --recurse-submodules https://github.com/sitemule/ILEastic.git		
		cd ILEastic && gmake BIN_LIB=ILEASTIC		
		cd noxdb && gmake BIN_LIB=ILEASTIC		
		cd && cd si-ibmi-compare-webservices		
		gmake build-for-ileastic
}


################################################################################
#
#                               Main
#
################################################################################


if exist_directory "${OPENSRC_DIR}";  then
    echo "5733-OPS product is installed ...\e[0m"
else 
    echo -e "\e[32mPlease install 5733-OPS product first.\e[0m"
fi

# set path to OpenSource
echo -e "\e[32msetting path to OpenSource ...\e[0m"
export PATH=${OPENSRC_DIR}:$PATH

echo -e "\e[32minstalling dependencies for si-ibmi-compare-webservices ...\e[0m"
install_yum_dependencies

cd Apps

echo -e "\e[32m install ILEastic ...\e[0m"
install_ileastic


echo -e "\e[32mDone. \e[0m"

