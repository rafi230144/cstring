#!/bin/sh

set -e

if ! test -d dump; then mkdir dump; fi
ghc -fforce-recomp Process -O2 -ddump-to-file -ddump-file-prefix="dump/Process" -ddump-simpl -dno-typeable-binds -dsuppress-module-prefixes -ddump-asm 1>/dev/null

ghc -fforce-recomp AllocBytesPrimOps.cmm AllocBytes Process Main -O2 1>/dev/null
./Main
