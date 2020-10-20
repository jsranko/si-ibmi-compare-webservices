DBGVIEW=*SOURCE
LIBRARY:=$(shell jq '.library.compareWebServices' -r ./config.json)
ILEASTIC_LIB:=$(shell jq '.library.ileastic' -r ./config.json)
ILEASTIC_HEADERS:=$(shell jq '.headers.ileastic' -r ./config.json)
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DIR_SRC=src/main
DIR_RPG=$(DIR_SRC)/qrpglesrc
EXT_RPG=RPGLE

SRCFILES_0=\
	$(DIR_RPG)

SRCFILES=\
	$(SRCFILES_0:=.srcpf)

ILEASTIC_PGMS=\
	$(patsubst %.rpgle,%.pgm,$(shell grep -il "$(ILEASTIC_LIB)" $(DIR_RPG)/*.rpgle))

SHELL=/QOpenSys/usr/bin/qsh

# Ensure that intermediate files created by rules chains don't get
# automatically deleted
.PRECIOUS: %.clps %.lib %.pgm %.command %.srcpf

all: build	

build: $(LIBRARY).lib \
		create-srcfiles \
		build-for-ileastic

create-srcfiles: $(SRCFILES)

build-for-ileastic: $(ILEASTIC_PGMS)

display-vars: 
	$(info    ILEASTIC_PGMS is $(ILEASTIC_PGMS))
	$(info    SRCFILES_0 is $(SRCFILES_0))
	$(info    SRCFILES is $(SRCFILES))

%.lib: 
	(system -Kp "CHKOBJ $* *LIB" || system -Kp "CRTLIB $* TEXT('$(LIBRARY_DESC)')") && \
	touch $@

%.srcpf: $(LIBRARY).lib
	system -Kp "CRTSRCPF FILE($(LIBRARY)/$(notdir $*)) RCDLEN(240) MBR(*NONE) TEXT('just for read-only')" && \
	touch $@

%.pgm: %.rpgle
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call substitute,$*.$(EXT_RPG),$@)
	liblist -a $(ILEASTIC_LIB);\ && \
	system -Kp "CRTBNDRPG PGM($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$@') DFTACTGRP(*NO) ACTGRP(*NEW) DBGVIEW($(DBGVIEW)) REPLACE(*YES) INCDIR('$(ROOT_DIR)/$(DIR_SRC)') TGTCCSID(*JOB) OUTPUT(*NONE)" && \
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(notdir $(DIR_RPG)),$(notdir $*)) || \
	-rm $@	

clean: clean-ileastic

clean-ileastic:
	rm $(LIBRARY).lib
	system -Kp 'DLTLIB $(LIBRARY)'
	rm -f src/main/*.srcpf
	rm $(DIR_SRC)/$(notdir $(DIR_RPG))/*.pgm

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef

define substitute
	-rm $(2)
	export QIBM_CCSID=$(SHELL_CCSID) && touch $(2) && \
	sed 's/$$(ILEASTIC_LIB)/$(ILEASTIC_LIB)/g; s/$$(ILEASTIC_HEADERS)/$(subst /,\/,$(ILEASTIC_HEADERS))/g; s/$$(ROOT_DIR)/$(subst /,\/,$(ROOT_DIR))/g' $(1) >> $(2)
endef	