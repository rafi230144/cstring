#!/bin/sh

set -e

ghc -fforce-recomp AllocBytesPrimOps.cmm AllocBytes Process Main -O2 1>/dev/null
./Main
