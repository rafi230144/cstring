#!/bin/sh

set -e

# CHANGE TO 'false' IF GHC'S LLVM BACKEND NOT CONFIGURED
llvm=true

if ! test -d "build"; then mkdir "build"; fi
if ! test -d "dump"; then mkdir "dump"; fi

if "${llvm}"; then
  ghc "-fforce-recomp" "Process" "-O2" \
    "-hidir=build" "-odir=build" \
    "-dumpdir=dump" "-ddump-to-file" "-ddump-simpl" "-dno-typeable-binds" "-keep-s-files" \
    "-fllvm" "-optlo-passes=default<O3>" "-optlc-O3" "-optlc-mcpu=native" \
    1>"/dev/null"
else
  ghc "-fforce-recomp" "Process" "-O2" \
    "-hidir=build" "-odir=build" \
    "-dumpdir=dump" "-ddump-to-file" "-ddump-simpl" "-dno-typeable-binds" "-keep-s-files" \
    1>"/dev/null"
fi
mv "Process.s" "dump/Process.s"

if "${llvm}"; then
  ghc "-fforce-recomp" "AllocBytesPrimOps.cmm" "AllocBytes" "Process" "Main" "-O2" \
    "-hidir=build" "-odir=build" \
    "-fllvm" "-optlo-passes=default<O3>" "-optlc-O3" "-optlc-mcpu=native" \
    1>"/dev/null"
else
  ghc "-fforce-recomp" "AllocBytesPrimOps.cmm" "AllocBytes" "Process" "Main" "-O2" \
    "-hidir=build" "-odir=build" \
    1>"/dev/null"
fi
."/Main"
