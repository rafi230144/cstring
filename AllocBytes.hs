{-# LANGUAGE Haskell2010
  , GHCForeignImportPrim
  , MagicHash
  , ScopedTypeVariables
  , UnboxedTuples
  , UnliftedFFITypes
#-}

{-# OPTIONS_GHC -Wall #-}

module AllocBytes
  ( mallocBytes#
  , free#
  ) where

import GHC.Exts
  ( State#
  , Int#
  , Addr#
  )

foreign import prim "mallocPrimOp"
    mallocBytes# :: forall s. Int# -> State# s -> (# State# s, Addr# #)

foreign import prim "freePrimOp"
    free# :: forall s. Addr# -> State# s -> State# s
