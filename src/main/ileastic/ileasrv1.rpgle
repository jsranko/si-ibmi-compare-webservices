**FREE

// -----------------------------------------------------------------------------
// This example runs a simple servlet using ILEastic
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO01)) JOB(ILEASTIC) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
// -----------------------------------------------------------------------------
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('$(ILEASTIC_LIB)/ILEASTIC');
ctl-opt thread(*CONCURRENT);
/include $(ROOT_DIR)/$(ILEASTIC_HEADERS)/ileastic.rpgle
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

    il_responseWrite(response:'Hello world');

end-proc;
