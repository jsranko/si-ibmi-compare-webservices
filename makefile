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
ICEBREAK_LIB:=$(shell jq '.iceBreak.library' -r ./config.json)
ICEBREAK_PORT:=$(shell jq '.iceBreak.port' -r ./config.json)
RUBY_PORT:=$(shell jq '.ruby.port' -r ./config.json)
DIR_SRC=src/main
DIR_RPG=$(DIR_SRC)/ileastic
DIR_RPG=$(DIR_SRC)/qrpglesrc
DIR_CPY=$(DIR_SRC)/qcpylesrc
DIR_IWSS=$(DIR_SRC)/iws
DIR_CGI=$(DIR_SRC)/cgi
DIR_NODEJS=$(DIR_SRC)/js
DIR_PHP=$(DIR_SRC)/php
DIR_PYTHON=$(DIR_SRC)/python
DIR_MONO=$(DIR_SRC)/mono
DIR_SPRING=$(DIR_SRC)/java/hello-spring-boot
DIR_RUBY=$(DIR_SRC)/ruby
EXT_CLLE=clle
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
	$(patsubst %.rpgle,%.pgm,$(wildcard $(DIR_ILEASTIC)/*.$(EXT_RPG))) \
	$(patsubst %.clle,%.clpgm,$(wildcard $(DIR_ILEASTIC)/*.$(EXT_CLLE)))

IWS_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(wildcard $(DIR_IWS)/*.$(EXT_RPG)))

CPYS:=\
	$(patsubst %.$(EXT_CPY),%.cpysrc,$(wildcard $(DIR_CPY)/*.$(EXT_CPY)))

IWSS=\
	$(patsubst %.$(EXT_IWSS),%.$(EXT_IWSSCONF),$(wildcard $(DIR_IWSS)/*.$(EXT_IWSS)))

CGI_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(wildcard $(DIR_CGI)/*.$(EXT_RPG)))

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

SPRING_CFGS=\
	$(patsubst %.propertiessrc,%.properties,$(wildcard $(DIR_SPRING)/*.propertiessrc))

RUBY_PGMS=\
	$(patsubst %.rbsrc,%.rb,$(wildcard $(DIR_RUBY)/*.rbsrc))

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
	build-spring \
	build-icebreak \
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
	$(SPRING_CFGS) \
	$(shell mvn -f $(DIR_SPRING)/pom.xml clean verify assembly:single)

build-icebreak: \
	

build-ruby: \
	$(RUBY_PGMS)

run-ileastic:
	liblist -a $(ILEASTIC_LIB); liblist -a $(LIBRARY); \
	system -Kp "SBMJOB CMD(CALL PGM($(LIBRARY)/ILEASRV1)) JOB($(ILEASTIC_JOB)) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)"

run-cgi:
	echo "Run CGI Server manually!"
	# liblist -a $(LIBRARY); \
	# system -Kp "STRTCPSVR SERVER(*HTTP) HTTPSVR($(CGI_SERVER))"

run-nodejs:
	echo "$(shell /QOpenSys/pkgs/lib/nodejs12/bin/pm2 start $(NODEJS_PGMS))"

run-php:
	echo "PHP is running $(IP):$(PHP_PORT) -t $(DIR_PHP)"
	echo "$(shell php -S $(IP):${PHP_PORT} -t ${PHP_DIR})"

run-python:
	echo "PYTHON is running $(IP):$(PYTHON_PORT)/$(PYTHON_PGMS)"
	echo "$(shell python3 $(PYTHON_PGMS))"

run-mono:
	echo "MONO is running $(IP):$(MONO_PORT)/$(MONO_PGMS)"
	echo "$(shell mono $(MONO_PGMS))"

run-spring:
	echo "Spring Boot is running $(IP):$(SPRING_PORT)"
	echo "$(shell java -jar $(SPRING_CP) --server.port=$(SPRING_PORT))"

run-icebreak:
	

run-ruby:
	echo "$(shell /PowerRuby/prV2R4/bin/ruby $(RUBY_PGMS))"

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
	$(info    SPRING_CFGS is $(SPRING_CFGS))
	$(info    SPRING_PORT is $(SPRING_PORT))
	$(info    SPRING_CP is $(SPRING_CP))
	$(info    DIR_RUBY is $(DIR_RUBY))
	$(info    RUBY_PGMS is $(RUBY_PGMS))

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
	$(call substitute,$*.jssrc,$@)

%.php: %.phpsrc
	$(call substitute,$*.phpsrc,$@)

%.py: %.pysrc
	$(call substitute,$*.pysrc,$@)

%.cs: %.cssrc
	$(call substitute,$*.cssrc,$@)

%.properties: %.propertiessrc
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call substitute,$*.propertiessrc,$@)

%.rb: %.rbsrc
	$(call substitute,$*.rbsrc,$@)
	
clean: 
	-rm $(LIBRARY).lib
	-rm $(LIBRARY).bnddir
	-system -Kp 'DLTLIB $(LIBRARY)'
	-system -Kp 'DLTLIB $(ILEASTIC_LIB)'
	-system -Kp 'DLTLIB $(ICEBREAK_LIB)'
	-rm -f src/main/*.srcpf
	-rm $(DIR_SRC)/$(notdir $(DIR_RPG))/*.pgm
	-rm $(DIR_SRC)/$(notdir $(DIR_IWSS))/*.$(EXT_IWSSCONF)
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.cgisrv
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.httpd
	-rm $(DIR_SRC)/$(notdir $(DIR_NODEJS))/*.nodejs
	-rm $(DIR_SRC)/$(notdir $(PHP_PGMS))/*.php
	-rm $(DIR_SRC)/$(notdir $(PYTHON_PGMS))/*.py
	-rm $(DIR_SRC)/$(notdir $(MONO_PGMS))/*.cs
	-rm $(DIR_SRC)/$(notdir $(DIR_RUBY))/*.rb
	#-rm -r $(CGI_ROOT)
	-rm -r $(ILEASTIC_ROOT)

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef

define substitute
	-rm $(2)
	export QIBM_CCSID=$(SHELL_CCSID) && touch $(2) && \
	sed 's/$$(RUBY_PORT)/$(RUBY_PORT)/g; s/$$(SPRING_PORT)/$(SRPING_PORT)/g; s/$$(MONO_PORT)/$(MONO_PORT)/g; s/$$(IP)/$(IP)/g; s/$$(PYTHON_PORT)/$(PYTHON_PORT)/g; s/$$(NODEJS_PORT)/$(NODEJS_PORT)/g; s/$$(CGI_ROOT)/$(subst /,\/,$(CGI_ROOT))/g; s/$$(CGI_PORT)/$(CGI_PORT)/g; s/$$(LIBRARY)/$(LIBRARY)/g; s/$$(IWS_PORT)/$(IWS_PORT)/g; s/$$(ILEASTIC_LIB)/$(ILEASTIC_LIB)/g; s/$$(ILEASTIC_HEADERS)/$(subst /,\/,$(ILEASTIC_HEADERS))/g; s/$$(ROOT_DIR)/$(subst /,\/,$(ROOT_DIR))/g; s/$$(ILEASTIC_PORT)/$(ILEASTIC_PORT)/g' $(1) >> $(2)
endef	