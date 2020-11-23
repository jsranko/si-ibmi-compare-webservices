**FREE
/if defined(HTTPP)
  /eof
/endif

/define HTTPP

dcl-c cHTTP_GET const('GET');
dcl-s tPath varchar(100) template;
dcl-s tHTTP_Method varchar(20) template;
dcl-s tHTTP_Query varchar(1000) template;
dcl-s tHTTP_Header varchar(900) template;
dcl-s tHTTP_Body varchar(2000000) template;
dcl-s tHTTP_ParamValue varchar(900) template;
dcl-s tHTTP_ParamName varchar(100) template;
dcl-s tHTTP_Status int(10) template;
