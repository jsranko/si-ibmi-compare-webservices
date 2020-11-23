**FREE

ctl-opt main(helloworld);
ctl-opt pgminfo(*pcml:*module:*dclcase) dftactgrp(*no);

/define IWSSRV1
/include qcpylesrc/iwssrv1p.rpgle

dcl-s linefeed char(2) inz(x'0D25');

dcl-proc HelloWorld ;
dcl-pi HelloWorld;
  FileSize like(tIWSSRV1_FileSize);
  Response like(tHTTP_Body);
  ResponseCode like(tHTTP_Status);
end-pi;


  ResponseCode = 200; // OK
  Response = getBody(FileSize);

  return;
end-proc;

// ------------------------------------------------------------------------

dcl-proc getBody;
dcl-pi getBody like(tHTTP_Body);
  fileSize like(tHTTP_ParamValue) options(*nopass:*omit:*varsize);
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
