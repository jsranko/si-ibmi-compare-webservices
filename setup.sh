#!/bin/bash

APPS_DIR=$PWD/Apps/
OPENSRC_DIR=/QOpenSys/pkgs/bin
PTH=$(jq '.path' -r ./config.json)
LIBRARY=$(jq '.library' -r ./config.json)
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
ICEBREAK_LIB=$(jq '.iceBreak.library' -r ./config.json)
ICEBREAK_URL=$(jq '.iceBreak.url' -r ./config.json)
ICEBREAK_EXE=$(jq '.iceBreak.exeFile' -r ./config.json)
ICEBREAK_SAVF=$(jq '.iceBreak.savfFile' -r ./config.json)
RUBY_DIR=$(jq '.ruby.dir' -r ./config.json)
RUBY_DIR_INSTALL=$(jq '.ruby.installDir' -r ./config.json)
RUBY_DIR_GEMSETS=$(jq '.ruby.gemsets' -r ./config.json)
RUBY_DIR_GEMPATH=$(jq '.ruby.gemPath' -r ./config.json)
YAJL_DIR=$(jq '.yajl.dir' -r ./config.json)
YAJL_URL=$(jq '.yajl.url' -r ./config.json)
YAJL_SAVF=$(jq '.yajl.savfFile' -r ./config.json)
YAJL_ZIP=$(jq '.yajl.zipFile' -r ./config.json)
YAJL_LIB=$(jq '.yajl.library' -r ./config.json)

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

		yum -y install 'git' 'make-gnu' 'curl' 'unzip' 'maven' 'nodejs12'	'python3' 'python3-pip'	'php-common' 'php-cli' 'mono-core'		
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

        echo -e "\e[32m install YAJL ...\e[0m"	
        install_yajl
        
		echo -e "\e[32m install and run IWS ...\e[0m"
		cd ${APPS_DIR}
		if ! exist_directory "${IWS_ROOT}";  then
			# clone and build project
			git -c http.sslVerify=false clone https://github.com/jsranko/si-iws-builder.git		
		fi	
		cd ${IWS_DIR}	
		mvn clean verify assembly:single	

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

		# build Compare for CGI und run CGI server
		gmake build-cgi && gmake run-cgi 
}

#
#		install_nodejs
#


install_nodejs()

{	
		echo -e "\e[32m install nodejs ...\e[0m"			
		npm install -g pm2
		npm install -g express
		
		go_home		
		gmake build-nodejs		
		gmake run-nodejs
		
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
			mkdir ${ICEBREAK_DIR}
		fi
		cd ${ICEBREAK_DIR}

		if ! [ -f "${ICEBREAK_SAVF}" ]; then
			echo -e "\e[32m${ICEBREAK_SAVF} not found. It will be downloaded ...\e[0m"
			wget --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0" ${ICEBREAK_URL} &&\
			unzip ${ICEBREAK_EXE} -x LoadRun.exe && rm ${ICEBREAK_EXE}
		fi
	
		system -Kp "CRTSAVF FILE(${LIBRARY}/ICEBREAK)"
		cp ${ICEBREAK_SAVF} /QSYS.LIB/${LIBRARY}.LIB/ICEBREAK.FILE
		system -Kp "RSTOBJ OBJ(*ALL) SAVLIB(BLUEICE) DEV(*SAVF) SAVF(${LIBRARY}/ICEBREAK) RSTLIB(*SAVF)"
		
		go_home
		# gmake build-icebreak
		# gmake run-icebreak &
		echo -e "\e[32m install done.\e[0m"
}

#
#		install_ruby
#


install_ruby()

{	
		echo -e "\e[32m install and run Ruby ...\e[0m"
		cd ${APPS_DIR}
		if ! [ -d "${RUBY_DIR}" ]; then
			cd && mkdir -p ${RUBY_DIR_GEMSETS}
			cd ${APPS_DIR}
			mkdir ${RUBY_DIR} && cd ${RUBY_DIR}
			system -Kp "CRTSAVF FILE(${LIBRARY}/PRUBY_BASE)"
			curl -L -k -o /QSYS.LIB/${LIBRARY}.LIB/PRUBY_BASE.FILE https://github.com/PowerRuby/DE_train_01/releases/download/V2R0M0/pruby_base.savf
			system -Kp "CRTSAVF FILE(${LIBRARY}/PRUBY_0001)"
			curl -L -k -o /QSYS.LIB/${LIBRARY}.LIB/PRUBY_0001.FILE https://github.com/PowerRuby/DE_train_01/releases/download/V2R0M0/pruby_0001.savf
			system -Kp "CRTSAVF FILE(${LIBRARY}/PRUBY_0006)"
			curl -L -k -o /QSYS.LIB/${LIBRARY}.LIB/PRUBY_0006.FILE https://github.com/PowerRuby/DE_train_01/releases/download/V2R0M0/pruby_0006.savf
			system -kp "RSTLICPGM LICPGM(1PRUBY1) DEV(*SAVF) LNG(2924) SAVF(${LIBRARY}/PRUBY_BASE)"
			system -kp "RSTLICPGM LICPGM(1PRUBY1) DEV(*SAVF) LNG(2924) OPTION(1) SAVF(${LIBRARY}/PRUBY_0001)"
			system -kp "RSTLICPGM LICPGM(1PRUBY1) DEV(*SAVF) LNG(2924) OPTION(6) SAVF(${LIBRARY}/PRUBY_0006)"
			${RUBY_DIR_INSTALL}/gem install sinatra
		fi
		cd ${RUBY_DIR}
		
		go_home		
		gmake build-ruby		
		gmake run-ruby &
}

#
#		set_ruby_path
#


set_ruby_path()

{
	echo -e "\e[32m EnvVar für Ruby werden gesetzt ...\e[0m"
	export GEM_HOME=$HOME/${RUBY_DIR_GEMSETS}
	export GEM_PATH=${RUBY_DIR_GEMPATH}:$GEM_HOME
}

#
#       install yajl
#


install_yajl()

{	
		echo -e "\e[32m install YAJL ...\e[0m"
		cd ${APPS_DIR}
		if ! [ -d "${YAJL_DIR}" ]; then
			mkdir ${YAJL_DIR}
			system -Kp "CRTLIB LIB(${YAJL_LIB})"
		fi
		cd ${YAJL_DIR}

		if ! [ -f "${YAJL_ZIP}" ]; then
			echo -e "\e[32m${YAJL_ZIP} not found. It will be downloaded ...\e[0m"
			wget --no-check-certificate ${YAJL_URL} &&\
			unzip ${YAJL_ZIP} -x README.txt YAJL.zip yajlifs.zip yajllib.savf && rm ${YAJL_ZIP}
		fi
	   
		system -Kp "CRTSAVF FILE(${YAJL_LIB}/YAJL)"
		cp ${YAJL_SAVF} /QSYS.LIB/${YAJL_LIB}.LIB/YAJL.FILE
		system -Kp "RSTOBJ OBJ(*ALL) SAVLIB(QTEMP) DEV(*SAVF) SAVF(${YAJL_LIB}/YAJL) RSTLIB(${YAJL_LIB})"
		
		go_home
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
	set -- --ileastic --iws --cgi --nodejs --php --python --spring --icebreak --ruby
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
   		"--ruby")     install_ruby ;;
   		"--yajl")     install_yajl ;;
	esac
done

set_ruby_path

echo -e "\e[32mSetup is done. \e[0m"

