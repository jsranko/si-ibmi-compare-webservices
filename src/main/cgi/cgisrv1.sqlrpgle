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

dcl-pr strtok like(tSTRTOK_Token) extproc('strtok');
  String pointer value options(*string);
  Delimiter pointer value options(*string);
end-pr;

dcl-s tSTRTOK_Token pointer template;

dcl-ds tApierror qualified template;        // API-Error
  BytesProv  int(10) inz(%size(tApierror)); // Bytes Provided
  BytesAvail int(10) inz(*zeros);           // Bytes Avail
  MsgId      char(07) inz(*allx'00');       // ErrorMessageId
  *n         char(01) inz(*allx'00');
  ErrData    char(256) inz(*allx'00');      // ErrorData
end-ds;
dcl-c cHTTP_GET const('GET');
dcl-s tPath varchar(50) template;
dcl-s tHTTP_Method varchar(20) template;
dcl-s tHTTP_Query varchar(1000) template;
dcl-s tHTTP_Header varchar(900) template;
dcl-s tHTTP_Body varchar(10000) template;
dcl-s tHTTP_ParamValue varchar(900) template;
dcl-s tHTTP_ParamName varchar(100) template;

dcl-s fileSize like(tHTTP_ParamValue);
dcl-ds dsApiError likeds(tApierror) inz(*likeds);
dcl-s body like(tHTTP_Body) ccsid(*utf8);
dcl-s method like(tHTTP_Method);
dcl-s linefeed char(2) inz(x'0D25');

  exec sql set option commit = *chg;

  monitor;
    method  = %str(getenv('REQUEST_METHOD':dsApiError));
  on-error;
  endmon;

  select;
  when method = cHTTP_GET;
    fileSize = getParamValue('fileSize');
  endsl;

  writeHeader();

  reset dsApiError;
  body = getBody(fileSize);
  wrtStdOut(%addr(body:*data):%len(body):dsApiError);

  return;

// ------------------------------------------------------------------------

dcl-proc getParamValue;
dcl-pi getParamValue like(tHTTP_ParamValue);
  ParamName like(tHTTP_ParamName) const;
end-pi;
dcl-s query like(tHTTP_Query);
dcl-s token like(tSTRTOK_Token);
dcl-s ParamValue like(tHTTP_ParamValue);
dcl-c delimiter const('&');

  monitor;
    query  = %str(getenv('QUERY_STRING':dsApiError));
  on-error;
    return '';
  endmon;

   token = strtok(query:delimiter);
   if token = *null;
     return '';
   endif;

   dow not %shtdn(); // endlose Schleife
     if %scan(ParamName:%str(token)) > 0;
       ParamValue = %subst(%str(token):%scan('=':%str(token))+1);
       leave;
     endif;

     token = strtok(*null: delimiter);
     if token = *null;
       return '';
     endif;
   enddo;

return ParamValue;
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

// ------------------------------------------------------------------------

dcl-proc getMethod;
dcl-pi getMethod like(tHTTP_Method);
end-pi;
dcl-s method like(tHTTP_Method);

  monitor;
    method  = %str(getenv('REQUEST_METHOD':dsApiError));
  on-error;
  endmon;

return *on;
end-proc;

// ------------------------------------------------------------------------

dcl-proc getBody;
dcl-pi getBody like(tHTTP_Body);
  fileSize like(tHTTP_ParamValue) options(*nopass:*omit);
end-pi;
dcl-s body like(tHTTP_Body);
dcl-s configData sqltype(CLOB:1000);

  configData = getConfigData('config.json');

  body = '{"error" : "Filesize not found."}' + linefeed;

return body;
end-proc;

// ------------------------------------------------------------------------

dcl-proc getConfigData;
dcl-pi getConfigData sqltype(CLOB:1000);
  configFile like(tPath);
end-pi;
dcl-s configData sqltype(CLOB:1000);

  exec sql set :configData = GET_CLOB_FROM_FILE(:configFile, 1);

return configData;
end-proc;
