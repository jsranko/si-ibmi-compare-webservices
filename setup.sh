#!/bin/bash

OPENSRC_DIR=/QOpenSys/pkgs/bin	
ILEASTIC_LIB=$(jq '.library.ileastic' -r ./config.json)
CGI_ROOT=$(jq '.headers.cgi' -r ./config.json)

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
#       install_dependencies
#


install_dependencies()

{	
		yum -y install 'git' 'make-gnu' 'jq'  'curl' 		
}

#
#       install_ileastic
#


install_ileastic()

{
		# clone project
		mkdir ILEastic && cd ILEastic
		git -c http.sslVerify=false clone --recurse-submodules https://github.com/sitemule/ILEastic.git		
		cd ILEastic				

		# build noxdb
		cd noxdb && gmake BIN_LIB=${ILEASTIC_LIB} && cd ..			
			
		# build ILEfastCGI
		cd ILEfastCGI && gmake BIN_LIB=${ILEASTIC_LIB} && cd ..		
		
		# build ILEastic		
		gmake BIN_LIB=${ILEASTIC_LIB} env 		
		cd src && gmake && cd ..		
		gmake BIN_LIB=${ILEASTIC_LIB} bind

		# build Compare for ILEastic
		cd && cd si-ibmi-compare-webservices			
		gmake build-ileastic
}

#
#       run_ileastic
#


run_ileastic()

{	
		gmake run-ileastic
}


#
#       install_iws
#


install_iws()

{		
		# clone and build project
		git -c http.sslVerify=false clone https://github.com/jsranko/si-iws-builder.git		
		cd si-iws-builder/IWSBuilder		
		mvn clean verify assembly:single		

		# build Compare for ILEastic
		cd && cd si-ibmi-compare-webservices			
		gmake build-iws

}

#
#		install_cgi
#


install_cgi()

{	
		mkdir /www/${CGI_ROOT}; mkdir /www/${CGI_ROOT}/conf; mkdir /www/${CGI_ROOT}/htdocs; mkdir /www/${CGI_ROOT}/logs		

		# build Compare for CGI und run CGI server
		cd && cd si-ibmi-compare-webservices			
		gmake build-cgi && system -Kp "STRTCPSVR SERVER(*HTTP) HTTPSVR(${CGI_ROOT}) "
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
install_dependencies

cd Apps

echo -e "\e[32m install ILEastic into lib: ${ILEASTIC_LIB} ...\e[0m"
# install_ileastic

echo -e "\e[32m run ILEastic server ...\e[0m"
# run_ileastic

cd Apps

echo -e "\e[32m install and run IWS ...\e[0m"
# install_iws

cd Apps

echo -e "\e[32m install and run CGI ...\e[0m"
install_cgi


echo -e "\e[32mDone. \e[0m"

