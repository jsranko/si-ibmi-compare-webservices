**FREE
/if not defined(IWSSRV1P)
 /define IWSSRV1P
/else
 /eof
/endif

//==========================================================================================
// Templates
//==========================================================================================


dcl-s tJSON char(1024) template;
dcl-s tHttpStatus int(10) template;
dcl-s tHttpHeaderEntry char(100) template;

/if defined(IWSSRV1)
  /eof
/endif

//==========================================================================================
// Prototypes
//==========================================================================================

dcl-pr HelloWorld;
  Response like(tJSON);
  ResponseCode like(tHttpStatus);
end-pr;
