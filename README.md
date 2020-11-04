# si-ibmi-compare-webservices (Compare Webservice on IBM i)
Compare Webservices

## Install

### Set PATH variable

Extend the environment variable PATH, so that the OpenSource packages do not have to enter qualified:

```
export PATH=/QOpenSys/pkgs/bin:$PATH
```

### Install git

Opensource package **git** must be installed. For installation execute the following command:
```
yum install git
```

### Clone project
A local copy of the project must be created:
```
git -c http.sslVerify=false clone https://github.com/jsranko/si-ibmi-compare-webservices.git
```

### Build project

```
cd si-ibmi-compare-webservices
bash setup.sh
```
