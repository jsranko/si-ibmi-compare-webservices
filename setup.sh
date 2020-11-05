#!/bin/bash

APPS_DIR=$PWD/Apps/
OPENSRC_DIR=/QOpenSys/pkgs/bin
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
PHP_REPO=/QOpenSys/etc/yum/repos.d/repos.zend.com_ibmiphp.repo
MONO_REPO=/QOpenSys/etc/yum/repos.d/qsecofr.repo
ICEBREAK_PORT=$(jq '.iceBreak.port' -r ./config.json)
ICEBREAK_DIR=$(jq '.iceBreak.dir' -r ./config.json)
ICEBREAK_URL=$(jq '.iceBreak.url' -r ./config.json)
ICEBREAK_EXE=$(jq '.iceBreak.exeFile' -r ./config.json)
ICEBREAK_SAVF=$(jq '.iceBreak.savfFile' -r ./config.json)

################################################################################
#
#                               Procedures.
#
################################################################################

go_home()

{	
        cd && cd si-ibmi-compare-webservices    
}

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
		# Get PHP Repository
		if [ -f "${PHP_REPO}" ]; then
			echo "${PHP_REPO} exists."    		
		else
			touch ${PHP_REPO}	
			echo "[repos.zend.com_ibmiphp]" >> ${PHP_REPO}
			echo "name=added from: http://repos.zend.com/ibmiphp" >> ${PHP_REPO}
			echo "baseurl=http://repos.zend.com/ibmiphp" >> ${PHP_REPO}	
			echo "enabled=1" >> ${PHP_REPO}
			yum repolist
		fi
		
		# Get Mono Repository
		if [ -f "${MONO_REPO}" ]; then
			echo "${MONO_REPO} exists."    		
		else
			curl --insecure https://repo.qseco.fr/qsecofr.repo > ${MONO_REPO}
			yum repolist
		fi

		yum -y install 'git' 'make-gnu' 'jq'  'curl' 'unzip' 'maven' 'nodejs12'	'python3' 'python3-pip'	'php-common' 'php-cli' 'mono-core'		
}

#
#       install_ileastic
#


install_ileastic()

{
		echo -e "\e[32m install ILEastic into lib: ${ILEASTIC_LIB} ...\e[0m"
		cd ${APPS_DIR}
		if ! exist_directory "${ILEASTIC_DIR}";  then
			# clone project
			mkdir -m 775 ${ILEASTIC_DIR} && cd ${ILEASTIC_DIR}
			git -c http.sslVerify=false clone --recurse-submodules https://github.com/sitemule/ILEastic.git			
		fi
		cd ${ILEASTIC_DIR}	

		# build noxdb
		cd noxdb && gmake BIN_LIB=${ILEASTIC_LIB} && cd ..			
			
		# build ILEfastCGI
		cd ILEfastCGI && gmake BIN_LIB=${ILEASTIC_LIB} && cd ..		
		
		# build ILEastic		
		gmake BIN_LIB=${ILEASTIC_LIB} env 		
		cd src && gmake && cd ..		
		gmake BIN_LIB=${ILEASTIC_LIB} bind

		# build Compare for ILEastic
		go_home			
		gmake build-ileastic
		gmake run-ileastic &
}


#
#       install_iws
#


install_iws()

{		
		echo -e "\e[32m install and run IWS ...\e[0m"
		cd ${APPS_DIR}
		if ! exist_directory "${IWS_ROOT}";  then
			# clone and build project
			git -c http.sslVerify=false clone https://github.com/jsranko/si-iws-builder.git		
			cd /${IWS_DIR}	
			mvn clean verify assembly:single	
		fi	

		# build Compare for IWS Builder
		go_home			
		gmake build-iws

}

#
#		install_cgi
#


install_cgi()

{	
		echo -e "\e[32m install and run CGI ...\e[0m"
		cd ${APPS_DIR}
		# mkdir -m 775 ${CGI_ROOT}; mkdir -m 775 ${CGI_ROOT}/conf; mkdir -m 775 ${CGI_ROOT}/htdocs; mkdir -m 775 ${CGI_ROOT}/logs		
		# mkdir -m 775 ${CGI_ROOT}; mkdir -m 775 ${CGI_ROOT}/conf		

		# build Compare for CGI und run CGI server
		go_home			
		gmake build-cgi && gmake run-cgi 
}

#
#		install_nodejs
#


install_nodejs()

{	
		echo -e "\e[32m install nodejs ...\e[0m"			
		npm install -g pm2		
}

#
#		install_php
#


install_php()

{			
		echo -e "\e[32m install PHP ...\e[0m"
		# build Compare for CGI und run CGI server
		go_home		
		gmake build-php		
		gmake run-php &
}

#
#		install_python
#


install_python()

{	
		echo -e "\e[32m install PYTHON ...\e[0m"
		pip3 install bottle		
	
		# build Compare for CGI und run CGI server
		go_home			
		gmake build-python		
		gmake run-python &
}

#
#		install_mono
#


install_mono()

{	
		echo -e "\e[32m install MONO for C# ...\e[0m"
		# build Compare for CGI und run CGI server
		go_home			
		gmake build-mono		
		gmake run-mono &

}

#
#		install_spring
#


install_spring()

{	
		echo -e "\e[32m install Java Spring Boot ...\e[0m"
		go_home		
		gmake build-spring		
		gmake run-spring &
}

#
#install_icebreak
#


install_icebreak()

{	
		echo -e "\e[32m install IceBreak ...\e[0m"
		cd ${APPS_DIR}
		if ! [ -d "${ICEBREAK_DIR}" ]; then
			mkdir ${ICEBREAK_DIR} && cd ${ICEBREAK_DIR}
		fi

		if ! [ -f "${ICEBREAK_SAVF}" ]; then
			echo -e "\e[32m${ICEBREAK_SAVF} not found. It will be downloaded ...\e[0m"
			wget --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0" ${ICEBREAK_URL} &&\
			unzip ${ICEBREAK_EXE} -x LoadRun.exe && rm ${ICEBREAK_EXE}
		fi
		go_home
		gmake build-icebreak
		gmake run-icebreak &
		echo -e "\e[32m install done.\e[0m"
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

if ! exist_directory "Apps";  then
	mkdir ${APPS_DIR}
fi

# set path to OpenSource
echo -e "\e[32msetting path to OpenSource ...\e[0m"
export PATH=${PTH}:$PATH

echo -e "\e[32minstalling dependencies for si-ibmi-compare-webservices ...\e[0m"
install_dependencies

if [[ $# -eq 0 ]]; then 
	set -- --ileastic --iws --cgi --nodejs --php --python --mono --spring --icebreak
fi

# Transform long options to short ones
for arg in "$@"; do
	shift
	case "$arg" in
		"--icebreak") install_icebreak ;;
  		"--spring")   install_spring ;;
   		"--mono")     install_mono ;;
   		"--python")   install_python ;;
   		"--php")      install_php ;;
   		"--nodejs")   install_nodejs ;;
   		"--cgi")      install_cgi ;;
   		"--iws")      install_iws ;;
   		"--ileastic") install_ileastic ;;
	esac
done

echo -e "\e[32mSetup is done. \e[0m"

