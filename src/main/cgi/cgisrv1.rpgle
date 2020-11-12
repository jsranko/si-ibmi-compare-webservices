**FREE

ctl-opt bnddir('SICOMIIWS/SICOMIIWS') actgrp(*new) usrprf(*owner);

dcl-pr readStdIn extproc('QtmhRdStin');
  Data      pointer value;
  Datalen   int(10) const;
  Avail     int(10) const;
  Error     likeds(tApierror);
end-pr;

dcl-pr wrtStdOut extproc('QtmhWrStout');
  Data      pointer value;
  Datalen   int(10) const;
  Error     likeds(tApierror);
end-pr;

dcl-pr getenv pointer extproc(*dclcase);
  Envvar    pointer value options(*string);
  Error     likeds(tApierror) const options(*nopass);
end-pr;

dcl-ds tApierror qualified template;        // API-Error
  BytesProv  int(10) inz(%size(tApierror)); // Bytes Provided
  BytesAvail int(10) inz(*zeros);           // Bytes Avail
  MsgId      char(07) inz(*allx'00');       // ErrorMessageId
  *n         char(01) inz(*allx'00');
  ErrData    char(256) inz(*allx'00');      // ErrorData
end-ds;
dcl-s tHTTP_Method varchar(20) template;
dcl-s tHTTP_Query varchar(1000) template;
dcl-s tHTTP_Header varchar(900) template;
dcl-s tHTTP_Body varchar(10000) template;
dcl-s tHTTP_ParamValue varchar(900) template;
dcl-s tHTTP_ParamName varchar(100) template;

dcl-s method like(tHTTP_Method);
dcl-s query like(tHTTP_Query);
dcl-s paramValue like(tHTTP_ParamValue);
dcl-ds dsApiError likeds(tApierror) inz(*likeds);
dcl-s body like(tHTTP_Body) ccsid(*utf8);
dcl-s linefeed char(2) inz(x'0D25');

  monitor;
    //method  = %str(getenv('REQUEST_METHOD':dsApiError));
    //query  = %str(getenv('QUERY_STRING':dsApiError));
  on-error;
  endmon;

  writeHeader();

  reset dsApiError;
  body = '{"error" : "Filesize not found."}' + linefeed;
  wrtStdOut(%addr(body:*data):%len(body):dsApiError);

  select;
  when method = 'GET';
    paramValue = getParamValue(query:'fileSize');

  endsl;

  return;

// ------------------------------------------------------------------------

dcl-proc getParamValue;
dcl-pi getParamValue like(tHTTP_ParamValue);
  Query like(tHTTP_Query);
  ParamName like(tHTTP_ParamName) const;
end-pi;

return '';
end-proc;

// ------------------------------------------------------------------------

dcl-proc writeHeader;
dcl-pi writeHeader ind;
end-pi;
dcl-s linefeed char(2) inz(x'0D25');
dcl-s property like(tHTTP_Header);

  property = 'Content-type: application/json';
  property = property + linefeed + linefeed;

  wrtStdOut(%addr(property:*data):%len(property):dsApiError);

return *on;
end-proc;
