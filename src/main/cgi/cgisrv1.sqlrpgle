**FREE

ctl-opt bnddir('SICOMIIWS/SICOMIIWS') actgrp(*new) usrprf(*owner);

/include qcpylesrc/httpp.rpgle

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
dcl-s output like(tHTTP_Body);
dcl-s fileName like(tPath);

  output = '{"error" : "Filesize not found."}' + linefeed;
  fileName = getFileName('/home/CECUSER/si-ibmi-compare-webservices/config.json': fileSize);
  if fileName <> *blanks;
    output = getFileData('/home/CECUSER/si-ibmi-compare-webservices/'+fileName);
  endif;

return output;
end-proc;

// ------------------------------------------------------------------------

dcl-proc getFileName;
dcl-pi getFileName like(tPath);
  configFile like(tPath) const;
  fileSize like(tHTTP_ParamValue) const;
end-pi;
dcl-s configData sqltype(CLOB:32000);
dcl-s fileName like(tPath);
dcl-s jPath varchar(50);

  exec sql set :configData = GET_CLOB_FROM_FILE(:configFile, 1);
  jPath =  '$.files.' + fileSize;
  exec sql set :fileName = JSON_Value(:configData, :jPath
           Returning Varchar(100) Null On Empty);

return fileName;
end-proc;

// ------------------------------------------------------------------------

dcl-proc getFileData;
dcl-pi getFileData like(tHTTP_Body);
  fileName like(tPath) const;
end-pi;
dcl-s fileData sqltype(CLOB:2000000);

  exec sql set :fileData = GET_CLOB_FROM_FILE(:fileName, 1);

return %trim(fileData_Data);
end-proc;
