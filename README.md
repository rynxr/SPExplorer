# SPExplorer
A source code analysis tool to explore Sensitive Pointers(SP) for Code Pointer Integrity(CPI) instrumentations in ARCE architecture.

## Introduction

### Definition
```
VP: (void *)
DC: Direct Code Pointer(e.g. function pointer, return address)
IC: Indirect Code Pointer(e.g. function pointer table, pointer to function pointer)
SP :=   DC
      | IC
      | VP
      | SP
```

### Description

This tool will analyze a single source file and print all `SP` with location information to user.

## Environment

+ OS: CentOS release 6.10
+ OCaml: 4.01.0
+ CIL: 1.7.3

## Install

1. Build CIL
```{bash}
cd <your_SPExplorer_cloned_client>
wget https://github.com/cil-project/cil/archive/cil-1.7.3.zip
unzip cil-1.7.3.zip && mv cil-cil-1.7.3 cil
cd cil
./configure
make
```

2. Build and Test SPExplorer
```
cd <your_SPExplorer_cloned_client>
make && make test
```

### Limitations

1. Only support single file at one time.
2. If the file has types defined seperately, user has to copy the definition to this file to let the tool move forware.

jlrao <ary.xsnow@gmail.com>

### Links

1. CIL: https://github.com/cil-project/cil
2. CPI: https://dslab.epfl.ch/pubs/cpi.pdf
