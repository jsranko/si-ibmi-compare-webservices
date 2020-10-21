**FREE

ctl-opt main(helloworld);
ctl-opt pgminfo(*pcml:*module:*dclcase);

/define IWSSRV1
/include qcpylesrc/iwssrv1p.rpgle

dcl-proc HelloWorld ;
dcl-pi HelloWorld;
  Response like(tJSON);
  ResponseCode like(tHttpStatus);
end-pi;

  ResponseCode = 200; // OK
  Response = 'Hello World';

  return;
end-proc;
