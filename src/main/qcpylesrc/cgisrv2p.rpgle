**FREE
/if not defined(CGISRV2P)
 /define CGISRV2P
/else
 /eof
/endif

//==========================================================================================
// Templates
//==========================================================================================


dcl-s tJSON char(1024) template;
dcl-s tHttpStatus int(10) template;
dcl-s tHttpHeaderEntry char(100) template;

/if defined(CGISRV2)
  /eof
/endif

//==========================================================================================
// Prototypes
//==========================================================================================

dcl-pr cgisrv2;
end-pr;
