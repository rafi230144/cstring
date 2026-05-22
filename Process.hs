{-# LANGUAGE Haskell2010
  , BangPatterns
  , ExtendedLiterals
  , MagicHash
  , PatternSynonyms
  , ScopedTypeVariables
  , UnboxedTuples
#-}

{-# OPTIONS_GHC -Wall #-}

module Process
  ( process
  ) where

import GHC.Exts
  ( Int8#
  , leInt8#
  , gtInt8#
  , subInt8#
  , Int#
  , andI#
  , (+#)
  , pattern I#
  , Addr#
  , readInt8OffAddr#
  , writeInt8OffAddr#
  , State#
  )

toUpper :: Int8# -> Int8#
toUpper = \ c ->
  case (97#Int8 `leInt8#` c) `andI#` (123#Int8 `gtInt8#` c) of
    0# -> c
    _  -> c `subInt8#` 32#Int8

strLen :: forall s. Addr# -> State# s -> (# State# s, Int# #)
strLen =
  let strLen_go = \ str i s0 ->
        let !(# s1, c #) = readInt8OffAddr# str i s0
        in  case c of
              0#Int8 -> (# s1, i #)
              _      -> strLen_go str (i +# 1#) s1
  in  \ str s -> strLen_go str 0# s

process :: forall s. Addr# -> State# s -> State# s
process = \ str s0 ->
  let !(# s1, len #) = strLen str s0
      s2 = foldr ( \ (I# i) k s0' ->
        let !(# s1', c #) = readInt8OffAddr# str i s0'
            c' = toUpper c
            s2' = writeInt8OffAddr# str i c' s1'
        in  k s2'
       ) (\ s -> s) [ 0 .. I# len - 1 ] s1
  in  s2
