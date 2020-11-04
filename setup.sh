#!/bin/bash

APPS_DIR=$PWD/Apps/
PTH==$(jq '.path' -r ./config.json)
ILEASTIC_LIB=$(jq '.ileastic.library' -r ./config.json)
ILEASTIC_DIR=$(jq '.ileastic.dir' -r ./config.json)
ILEASTIC_ROOT=${APPS_DIR}/${ILEASTIC_DIR}
IWS_DIR=$(jq '.iws.dir' -r ./config.json)
IWS_ROOT=${APPS_DIR}/${IWS_DIR}

CGI_DIR=$(jq '.cgi.dir' -r ./config.json)
CGI_ROOT=${CGI_DIR}
PHP_PORT=$(jq '.php.port' -r ./config.json)
PHP_DIR=./src/main/php


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
		yum -y install 'git' 'make-gnu' 'jq'  'curl' 'unzip' 'maven' 'nodejs12'	
}

#
#       install_ileastic
#


install_ileastic()

{
		cd ${APPS_DIR}
		# clone project
		mkdir -m 775 ${ILEASTIC_ROOT} && cd ${ILEASTIC_ROOT}
		git -c http.sslVerify=false clone --recurse-submodules https://github.com/sitemule/ILEastic.git		
		cd ${ILEASTIC_ROOT}				

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
		cd ${APPS_DIR}
		# clone and build project
		git -c http.sslVerify=false clone https://github.com/jsranko/si-iws-builder.git		
		cd /${IWS_DIR}	
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
		cd ${APPS_DIR}
		# mkdir -m 775 ${CGI_ROOT}; mkdir -m 775 ${CGI_ROOT}/conf; mkdir -m 775 ${CGI_ROOT}/htdocs; mkdir -m 775 ${CGI_ROOT}/logs		
		# mkdir -m 775 ${CGI_ROOT}; mkdir -m 775 ${CGI_ROOT}/conf		

		# build Compare for CGI und run CGI server
		cd && cd si-ibmi-compare-webservices			
		gmake build-cgi && gmake run-cgi 
}

#
#		install_nodejs
#


install_nodejs()

{				
		npm install -g pm2		
}

#
#		install_php
#


install_php()

{	
		if [ -f "${1}" ]; then
			echo "${1} exists."    		
		else
			touch ${1}	
			echo "[repos.zend.com_ibmiphp]" >> ${1}
			echo "name=added from: http://repos.zend.com/ibmiphp" >> ${1}
			echo "baseurl=http://repos.zend.com/ibmiphp" >> ${1}	
			echo "enabled=1" >> ${1}
			yum repolist
		fi
		yum -y install 'php-common' 'php-cli'			
	
		# build Compare for CGI und run CGI server
		cd && cd si-ibmi-compare-webservices			
		gmake build-php		
		gmake run-php &
}

#
#		install_python
#


install_python()

{	
		yum -y install 'python3' 'python3-pip'	
		pip3 install bottle		
	
		# build Compare for CGI und run CGI server
		cd && cd si-ibmi-compare-webservices			
		gmake build-python		
		gmake run-python &
}

#
#		install_mono
#


install_mono()

{	
		if [ -f "${1}" ]; then
    		echo "${1} exists."    		
		else
			curl --insecure https://repo.qseco.fr/qsecofr.repo > /QOpenSys/etc/yum/repos.d/qsecofr.repo
			yum repolist
		fi
		yum -y install 'mono-core'		

		# build Compare for CGI und run CGI server
		cd && cd si-ibmi-compare-webservices			
		gmake build-mono		
		gmake run-mono &

}

#
#		install_spring
#


install_spring()

{	
		cd && cd si-ibmi-compare-webservices		
		gmake build-spring		
		gmake run-spring &
}

#
#install_icebreak
#


install_icebreak()

{	
		wget --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0" http://webfiles.system-method.com/download/IceBreak/IceBreakSetup0558.exe	
		unzip IceBreakSetup0558.exe -x LoadRun.exe
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

if exist_directory "Apps";  then
	echo "Directory Apps exists."
else 
	mkdir ${APPS_DIR}
fi

# set path to OpenSource
echo -e "\e[32msetting path to OpenSource ...\e[0m"
export PATH=${PTH}:$PATH

echo -e "\e[32minstalling dependencies for si-ibmi-compare-webservices ...\e[0m"
install_dependencies

echo -e "\e[32m install ILEastic into lib: ${ILEASTIC_LIB} ...\e[0m"
if exist_directory "${ILEASTIC_ROOT}";  then
	echo "Directory ${ILEASTIC_ROOT} exists."
else 
	install_ileastic
fi

echo -e "\e[32m run ILEastic server ...\e[0m"
run_ileastic

echo -e "\e[32m install and run IWS ...\e[0m"
if exist_directory "${IWS_ROOT}";  then
	echo "Directory ${IWS_ROOT} exists."
else 
	install_iws
fi

echo -e "\e[32m install and run CGI ...\e[0m"
install_cgi

echo -e "\e[32m install nodejs ...\e[0m"
install_nodejs

echo -e "\e[32m install PHP ...\e[0m"
install_php /QOpenSys/etc/yum/repos.d/repos.zend.com_ibmiphp.repo

echo -e "\e[32m install PYTHON ...\e[0m"
install_python

echo -e "\e[32m install MONO for C# ...\e[0m"
install_mono /QOpenSys/etc/yum/repos.d/qsecofr.repo

echo -e "\e[32m install Java Spring Boot ...\e[0m"
install_spring

echo -e "\e[32m install IceBreak ...\e[0m"
install_icebreak

echo -e "\e[32mDone. \e[0m"

