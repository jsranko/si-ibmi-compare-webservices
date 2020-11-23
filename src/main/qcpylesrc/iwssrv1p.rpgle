**FREE
/if defined(IWSSRV1P)
  /eof
/endif

/define IWSSRV1P

/include qcpylesrc/httpp.rpgle

//==========================================================================================
// Templates
//==========================================================================================

dcl-s tIWSSRV1_FileSize varchar(100) template;

/if defined(IWSSRV1)
  /eof
/endif

//==========================================================================================
// Prototypes
//==========================================================================================

dcl-pr HelloWorld;
  fileSize like(tIWSSRV1_FileSize);
  Response like(tHTTP_Body);
  ResponseCode like(tHttpStatus);
end-pr;
