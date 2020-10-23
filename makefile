ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DBGVIEW=*SOURCE
LIBRARY:=$(shell jq '.library' -r ./config.json)
IP:=$(shell jq '.ip' -r ./config.json)
SHELL_CCSID:=$(shell jq '.paseCCSID' -r ./config.json)
ILEASTIC_LIB:=$(shell jq '.ileastic.library' -r ./config.json)
ILEASTIC_DIR:=$(shell jq '.ileastic.dir' -r ./config.json)
ILEASTIC_HEADERS:=$(shell jq '.ileastic.includeDir' -r ./config.json)
ILEASTIC_PORT:=$(shell jq '.ileastic.port' -r ./config.json)
ILEASTIC_JOB:=$(shell jq '.ileastic.jobName' -r ./config.json)
ILEASTIC_ROOT=$(ROOT_DIR)/$(ILEASTIC_DIR)
IWS_PORT:=$(shell jq '.iws.port' -r ./config.json)
CGI_PORT:=$(shell jq '.cgi.port' -r ./config.json)
CGI_DIR:=$(shell jq '.cgi.dir' -r ./config.json)
CGI_SERVER:=$(shell jq '.cgi.server' -r ./config.json)
CGI_ROOT=$(CGI_DIR)
NODEJS_PORT:=$(shell jq '.nodejs.port' -r ./config.json)
PHP_PORT:=$(shell jq '.php.port' -r ./config.json)
PYTHON_PORT:=$(shell jq '.python.port' -r ./config.json)
MONO_PORT:=$(shell jq '.mono.port' -r ./config.json)
SPRING_PORT:=$(shell jq '.springBoot.port' -r ./config.json)
SPRING_JAR:=$(shell jq '.springBoot.jarWithDependencies' -r ./config.json)
DIR_SRC=src/main
DIR_RPG=$(DIR_SRC)/qrpglesrc
DIR_CPY=$(DIR_SRC)/qcpylesrc
DIR_IWSS=$(DIR_SRC)/qiwsssrc
DIR_CGI=$(DIR_SRC)/cgi
DIR_NODEJS=$(DIR_SRC)/js
DIR_PHP=$(DIR_SRC)/php
DIR_PYTHON=$(DIR_SRC)/python
DIR_MONO=$(DIR_SRC)/mono
DIR_SPRING=$(DIR_SRC)/java/hello-spring-boot
EXT_RPG=rpgle
EXT_CPY=rpgle
EXT_IWSS=iwss
EXT_IWSSCONF=iwssconf
IWSBUILDER_CP=$(ROOT_DIR)/Apps/si-iws-builder/IWSBuilder/target/si-iws-builder-jar-with-dependencies.jar
IWSBUILDER_CLASSNAME=de.sranko_informatik.ibmi.iwsbuilder.App
SPRING_CP=$(DIR_SPRING)/target/$(SPRING_JAR)

SRCFILES_0=\
	$(DIR_RPG) \
	$(DIR_IWSS) \
	$(DIR_CPY)

SRCFILES=\
	$(SRCFILES_0:=.srcpf)

ILEASTIC_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(shell grep -il "$(ILEASTIC_LIB)" $(DIR_RPG)/*.$(EXT_RPG)))

IWS_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(shell grep -il " pgminfo" $(DIR_RPG)/*.$(EXT_RPG)))

CPYS:=\
	$(patsubst %.$(EXT_CPY),%.cpysrc,$(wildcard $(DIR_CPY)/*.$(EXT_CPY)))

IWSS=\
	$(patsubst %.$(EXT_IWSS),%.$(EXT_IWSSCONF),$(wildcard $(DIR_IWSS)/*.$(EXT_IWSS)))

CGI_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(shell grep -il "cgi" $(DIR_RPG)/*.$(EXT_RPG)))

CGI_CONF=\
	$(patsubst %.confsrc,%.httpd,$(wildcard $(DIR_CGI)/*.confsrc)) \
	$(patsubst %.cgisrc,%.cgi,$(wildcard $(DIR_CGI)/*.cgisrc))

NODEJS_PGMS=\
	$(patsubst %.jssrc,%.js,$(wildcard $(DIR_NODEJS)/*.jssrc))

PHP_PGMS=\
	$(patsubst %.phpsrc,%.php,$(wildcard $(DIR_PHP)/*.phpsrc))

PYTHON_PGMS=\
	$(patsubst %.pysrc,%.py,$(wildcard $(DIR_PYTHON)/*.pysrc))

MONO_PGMS=\
	$(patsubst %.cssrc,%.cs,$(wildcard $(DIR_MONO)/*.cssrc))
	
# SHELL=/QOpenSys/usr/bin/qsh

# Ensure that intermediate files created by rules chains don't get
# automatically deleted
.PRECIOUS: %.clps %.lib %.pgm %.command %.srcpf

all: core \
	build-ileastic \
	build-cgi \
	build-nodejs \
	build-php \
	build-python \
	build-mono \
	build-iws

core: $(LIBRARY).lib \
	$(LIBRARY).bnddir \
	create-srcfiles \
	copy

create-srcfiles: $(SRCFILES)

copy: $(CPYS)

build-ileastic: core \
	$(ILEASTIC_PGMS)

build-cgi: core \
	$(CGI_PGMS) \
	$(CGI_CONF)

build-iws: core \
	$(IWS_PGMS) \
	$(IWSS)

build-nodejs: core \
	$(NODEJS_PGMS)

build-php: core \
	$(PHP_PGMS)

build-python: core \
	$(PYTHON_PGMS)

build-mono: core \
	$(MONO_PGMS)

build-spring: \
	$(shell mvn -f $(DIR_SPRING)/pom.xml clean assembly:single)

run-ileastic:
	liblist -a $(ILEASTIC_LIB); liblist -a $(LIBRARY); \
	system -Kp "SBMJOB CMD(CALL PGM($(LIBRARY)/ILEASRV1)) JOB($(ILEASTIC_JOB)) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)"

run-cgi:
	echo "Run CGI Server manually!"
	# liblist -a $(LIBRARY); \
	# system -Kp "STRTCPSVR SERVER(*HTTP) HTTPSVR($(CGI_SERVER))"

run-nodejs:
	$(shell pm2 start $(NODEJS_PGMS))

run-php:
	echo "PHP is running $(IP):$(PHP_PORT) -t $(DIR_PHP)"
	$(shell sh -c "php -S $(IP):${PHP_PORT} -t ${PHP_DIR}")

run-python:
	echo "PYTHON is running $(IP):$(PYTHON_PORT)/$(PYTHON_PGMS)"
	$(shell sh -c "python3 $(PYTHON_PGMS)")

run-mono:
	echo "MONO is running $(IP):$(MONO_PORT)/$(MONO_PGMS)"
	$(shell sh -c "mono $(MONO_PGMS)")

run-spring:
	echo "Spring Boot is running $(IP):$(SPRING_PORT)"
	$(shell java -jar $(SPRING_CP) --server.port=$(SPRING_PORT))

display-vars: 
	$(info    LIBRARY is $(LIBRARY))
	$(info    ILEASTIC_LIB is $(ILEASTIC_LIB))
	$(info    ILEASTIC_HEADERS is $(ILEASTIC_HEADERS))
	$(info    ILEASTIC_PORT is $(ILEASTIC_PORT))
	$(info    IWS_PORT is $(IWS_PORT))
	$(info    CGI_PORT is $(CGI_PORT))
	$(info    CGI_DIR is $(CGI_DIR))
	$(info    ROOT_DIR is $(ROOT_DIR))
	$(info    CGI_ROOT is $(CGI_ROOT))
	$(info    ILEASTIC_PGMS is $(ILEASTIC_PGMS))
	$(info    SRCFILES_0 is $(SRCFILES_0))
	$(info    SRCFILES is $(SRCFILES))
	$(info    IWS_PGMS is $(IWS_PGMS))
	$(info    IWSS is $(IWSS))
	$(info    CPYS is $(CPYS))
	$(info    CGI_PGMS is $(CGI_PGMS))
	$(info    CGI_CONF is $(CGI_CONF))
	$(info    NODEJS_PGMS is $(NODEJS_PGMS))
	$(info    PHP_PGMS is $(PHP_PGMS))
	$(info    PYTHON_PGMS is $(PYTHON_PGMS))
	$(info    MONO_PGMS is $(MONO_PGMS))

%.lib: 
	(system -Kp "CHKOBJ $* *LIB" || system -Kp "CRTLIB $* TEXT('$(LIBRARY_DESC)')") && \
	touch $@

%.bnddir: $(LIBRARY).lib 
	(system -Kp "CHKOBJ OBJ($(LIBRARY)/$*) OBJTYPE(*BNDDIR)" || system -iKp "CRTBNDDIR BNDDIR($(LIBRARY)/$*) TEXT($(OBJECT_DESC))") && \
	touch $@	
	system -Kp "ADDBNDDIRE BNDDIR($(LIBRARY)/$(LIBRARY)) OBJ((qhttpsvr/qzhbcgi *SRVPGM *IMMED))"

%.srcpf: $(LIBRARY).lib
	system -Kp "CRTSRCPF FILE($(LIBRARY)/$(notdir $*)) RCDLEN(240) MBR(*NONE) TEXT('just for read-only')" && \
	touch $@

%.pgm: %.rpgle
	$(call substitute,$*.$(EXT_RPG),$@)
	liblist -a $(ILEASTIC_LIB); \
	system -Kp "CRTBNDRPG PGM($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$@') DFTACTGRP(*NO) ACTGRP(*NEW) DBGVIEW($(DBGVIEW)) REPLACE(*YES) INCDIR('$(ROOT_DIR)/$(DIR_SRC)') TGTCCSID(*JOB) OUTPUT(*NONE)" && \
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(notdir $(DIR_RPG)),$(notdir $*)) || \
	-rm $@	

%.cpysrc: %.$(EXT_CPY) $(DIR_CPY).srcpf
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(notdir $(DIR_CPY)),$(notdir $*)) && \
	touch $@

%.$(EXT_IWSSCONF): %.$(EXT_IWSS)
	$(call substitute,$*.$(EXT_IWSS),$@)
	# java $(JAVA_DEBUG) -cp $(IWSBUILDER_CP) $(IWSBUILDER_CLASSNAME) ./$@ && \
	java -cp $(IWSBUILDER_CP) $(IWSBUILDER_CLASSNAME) ./$@ && \
	$(call copy_to_srcpf,$(ROOT_DIR)/$@,$(LIBRARY),$(notdir $(DIR_IWSS)),$(notdir $*))

%.httpd: %.conf
	$(call substitute,$*.conf,$@) 
	cat $@
	# cp $@ $(CGI_ROOT)/conf/$(notdir $<) && chmod 775 $(CGI_ROOT)/conf/$(notdir $<)

%.cgisrv: %.srv
	$(call substitute,$*.srv,$@)
	-system -Kp "ADDPFM FILE(QUSRSYS/$(notdir $(DIR_CGI))) MBR($(notdir $*))"
	system -Kp "CPYFRMIMPF FROMSTMF('$(ROOT_DIR)/$@') TOFILE(QUSRSYS/$(notdir $(DIR_CGI)) $(notdir $*)) MBROPT(*REPLACE) RCDDLM(*CRLF)"

%.js: %.jssrc
	$(call substitute,$*.js,$@)

%.php: %.phpsrc
	$(call substitute,$*.phpsrc,$@)

%.py: %.pysrc
	$(call substitute,$*.pysrc,$@)

%.cs: %.cssrc
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call substitute,$*.cssrc,$@)

clean: 
	-rm $(LIBRARY).lib
	-rm $(LIBRARY).bnddir
	-system -Kp 'DLTLIB $(LIBRARY)'
	-rm -f src/main/*.srcpf
	-rm $(DIR_SRC)/$(notdir $(DIR_RPG))/*.pgm
	-rm $(DIR_SRC)/$(notdir $(DIR_IWSS))/*.$(EXT_IWSSCONF)
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.cgisrv
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.httpd
	-rm $(DIR_SRC)/$(notdir $(DIR_NODEJS))/*.nodejs
	-rm $(DIR_SRC)/$(notdir $(PHP_PGMS))/*.php
	-rm $(DIR_SRC)/$(notdir $(PYTHON_PGMS))/*.py
	-rm $(DIR_SRC)/$(notdir $(MONO_PGMS))/*.cs
	#-rm -r $(CGI_ROOT)
	-rm -r $(ILEASTIC_ROOT)

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef

define substitute
	-rm $(2)
	export QIBM_CCSID=$(SHELL_CCSID) && touch $(2) && \
	sed 's/$$(MONO_PORT)/$(MONO_PORT)/g; s/$$(IP)/$(IP)/g; s/$$(PYTHON_PORT)/$(PYTHON_PORT)/g; s/$$(NODEJS_PORT)/$(NODEJS_PORT)/g; s/$$(CGI_ROOT)/$(subst /,\/,$(CGI_ROOT))/g; s/$$(CGI_PORT)/$(CGI_PORT)/g; s/$$(LIBRARY)/$(LIBRARY)/g; s/$$(IWS_PORT)/$(IWS_PORT)/g; s/$$(ILEASTIC_LIB)/$(ILEASTIC_LIB)/g; s/$$(ILEASTIC_HEADERS)/$(subst /,\/,$(ILEASTIC_HEADERS))/g; s/$$(ROOT_DIR)/$(subst /,\/,$(ROOT_DIR))/g; s/$$(ILEASTIC_PORT)/$(ILEASTIC_PORT)/g' $(1) >> $(2)
endef	