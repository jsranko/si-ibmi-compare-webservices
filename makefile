DBGVIEW=*SOURCE
LIBRARY:=$(shell jq '.library.compareWebServices' -r ./config.json)
ILEASTIC_LIB:=$(shell jq '.library.ileastic' -r ./config.json)
ILEASTIC_HEADERS:=$(shell jq '.headers.ileastic' -r ./config.json)
ILEASTIC_PORT:=$(shell jq '.port.ileastic' -r ./config.json)
IWS_PORT:=$(shell jq '.port.iws' -r ./config.json)
CGI_PORT:=$(shell jq '.port.cgi' -r ./config.json)
CGI_ROOT:=$(shell jq '.headers.cgi' -r ./config.json)
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DIR_SRC=src/main
DIR_RPG=$(DIR_SRC)/qrpglesrc
DIR_CPY=$(DIR_SRC)/qcpylesrc
DIR_IWSS=$(DIR_SRC)/qiwsssrc
DIR_CGI=$(DIR_SRC)/QATMHINSTC
EXT_RPG=rpgle
EXT_CPY=rpgle
EXT_IWSS=iwss
EXT_IWSSCONF=iwssconf
JAR_SINGLE=$(ROOT_DIR)/Apps/si-iws-builder/IWSBuilder/target/si-iws-builder-jar-with-dependencies.jar
JAR_CLASSNAME=de.sranko_informatik.ibmi.iwsbuilder.App

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
	$(patsubst %.rpgle,%.pgm,$(shell grep -il "$(CGI_LIB)" $(DIR_RPG)/*.$(EXT_RPG)))

CGI_CONF=\
	$(patsubst %.conf,%.httpd,$(wildcard $(DIR_CGI)/*.conf)) \
	$(patsubst %.srv,%.cgisrv,$(wildcard $(DIR_CGI)/*.srv))
	
# SHELL=/QOpenSys/usr/bin/qsh

# Ensure that intermediate files created by rules chains don't get
# automatically deleted
.PRECIOUS: %.clps %.lib %.pgm %.command %.srcpf

all: core \
	build-ileastic \
	build-cgi \
	build-iws

core: $(LIBRARY).lib \
	create-srcfiles \
	copy

create-srcfiles: $(SRCFILES)

copy: $(CPYS)

build-ileastic: core \
	$(ILEASTIC_PGMS)

build-cgi: core \
	$(CGI_CONF)

build-iws: core \
	$(IWS_PGMS) \
	$(IWSS)

run-ileastic:
	liblist -a $(ILEASTIC_LIB); liblist -a $(LIBRARY); \
	system -Kp "SBMJOB CMD(CALL PGM($(LIBRARY)/ILEASRV1)) JOB(COMWSILEA) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)"

display-vars: 
	$(info    ILEASTIC_PGMS is $(ILEASTIC_PGMS))
	$(info    SRCFILES_0 is $(SRCFILES_0))
	$(info    SRCFILES is $(SRCFILES))
	$(info    IWS_PGMS is $(IWS_PGMS))
	$(info    IWSS is $(IWSS))
	$(info    CPYS is $(CPYS))
	$(info    CGI_PGMS is $(CGI_PGMS))
	$(info    CGI_CONF is $(CGI_CONF))

%.lib: 
	(system -Kp "CHKOBJ $* *LIB" || system -Kp "CRTLIB $* TEXT('$(LIBRARY_DESC)')") && \
	touch $@

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
	$(call copy_to_srcpf,$(ROOT_DIR)/$@,$(LIBRARY),$(notdir $(DIR_CPY)),$(notdir $*)) && \
	touch $@

%.$(EXT_IWSSCONF): %.$(EXT_IWSS)
	$(call substitute,$*.$(EXT_IWSS),$@)
	# java $(JAVA_DEBUG) -cp $(JAR_SINGLE) $(JAR_CLASSNAME) ./$@ && \
	java -cp $(JAR_SINGLE) $(JAR_CLASSNAME) ./$@ && \
	$(call copy_to_srcpf,$(ROOT_DIR)/$@,$(LIBRARY),$(notdir $(DIR_IWSS)),$(notdir $*))

%.httpd: %.conf
	$(call substitute,$*.conf,$@) && \
	cp $@ /www/$(CGI_ROOT)/conf/$(notdir $<)

%.cgisrv: %.srv
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call substitute,$*.srv,$@)
	-system -Kp "ADDPFM FILE(QUSRSYS/$(notdir $(DIR_CGI))) MBR($(notdir $*))"
	system -Kp "CPYFRMIMPF FROMSTMF('$(ROOT_DIR)/$@') TOFILE(QUSRSYS/$(notdir $(DIR_CGI)) $(notdir $*)) MBROPT(*REPLACE) RCDDLM(*CRLF)"

clean: 
	-rm $(LIBRARY).lib
	-system -Kp 'DLTLIB $(LIBRARY)'
	-rm -f src/main/*.srcpf
	-rm $(DIR_SRC)/$(notdir $(DIR_RPG))/*.pgm
	-rm $(DIR_SRC)/$(notdir $(DIR_IWSS))/*.$(EXT_IWSSCONF)
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.cgisrv
	-rm $(DIR_SRC)/$(notdir $(DIR_CGI))/*.httpd
	-rm -r /www/$(CGI_ROOT)

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef

define substitute
	-rm $(2)
	export QIBM_CCSID=$(SHELL_CCSID) && touch $(2) && \
	sed 's/$$(CGI_ROOT)/$(CGI_ROOT)/g; s/$$(CGI_PORT)/$(CGI_PORT)/g; s/$$(LIBRARY)/$(LIBRARY)/g; s/$$(IWS_PORT)/$(IWS_PORT)/g; s/$$(ILEASTIC_LIB)/$(ILEASTIC_LIB)/g; s/$$(ILEASTIC_HEADERS)/$(subst /,\/,$(ILEASTIC_HEADERS))/g; s/$$(ROOT_DIR)/$(subst /,\/,$(ROOT_DIR))/g; s/$$(ILEASTIC_PORT)/$(ILEASTIC_PORT)/g' $(1) >> $(2)
endef	