**FREE

// -----------------------------------------------------------------------------
// This example runs a simple servlet using ILEastic
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO01)) JOB(ILEASTIC) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
// -----------------------------------------------------------------------------
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main) actgrp(*new);
ctl-opt debug(*yes) bndDir('$(ILEASTIC_LIB)/ILEASTIC':'$(ILEASTIC_LIB)/NOXDB');
ctl-opt thread(*CONCURRENT);
/include $(ROOT_DIR)/$(ILEASTIC_HEADERS)/ileastic.rpgle
/include $(ILEASTIC_LIB)/qrpgleRef,jsonparser
// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);

    config.port = $(ILEASTIC_PORT);
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));

end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    dcl-s pJson Pointer;
    dcl-s pFileData Pointer;
    dcl-s fileName varchar(50);
    dcl-s fileSize varchar(50) inz('1k');
    dcl-s output varchar(32000);

    //pJson = json_ParseFile ('/home/CECUSER/si-ibmi-compare-webservices/config.json');
    //fileSize  = il_getParmStr(request : 'fileSize');
    //fileName = json_GetStr(pJson: fileSize);
    //pFileData = json_ParseFile ('/home/CECUSER/si-ibmi-compare-webservices/'+fileName);
    //output = json_AsText(pFileData);

    il_responseWrite(response:output);

end-proc;
