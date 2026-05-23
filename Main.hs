{-# LANGUAGE Haskell2010
  , BangPatterns
  , MagicHash
  , PatternSynonyms
  , UnboxedTuples
#-}

{-# OPTIONS_GHC -Wall #-}

module Main
  ( main
  ) where

import GHC.Exts
  ( Addr#
  , State#
  , RealWorld
  , copyAddrToAddrNonOverlapping#
  , cstringLength#
  , unpackCString#
  )

import GHC.Base
  ( pattern IO )

import AllocBytes
  ( mallocBytes#
  , free#
  )

import Process
  ( process )

{- | Given an 'Addr#' understood as a CString,
    returns the 'State#' action
    printing its contents
#-}
putStrLn# :: Addr# -> State# RealWorld -> State# RealWorld
putStrLn# = \ str s0 ->
  case putStrLn (unpackCString# str) of
    IO x -> case x s0 of
      (# s1, _ #) -> s1

{- | Given an 'Addr#' understood as a CString,
    returns the 'State#' action
    allocating a copy thereof on the foreign heap,
    printing the contents of the copy,
    applying 'process' to the copy,
    printing the contents of the copy once more,
    and finally freeing the copy
-}
test# :: Addr# -> State# RealWorld -> State# RealWorld
test# = \ str s0 ->
  let len = cstringLength# str
      !(# s1, str' #) = mallocBytes# len s0
      s2 = copyAddrToAddrNonOverlapping# str str' len s1
      s3 = putStrLn# str' s2
      s4 = process str' s3
      s5 = putStrLn# str' s4
      s6 = free# str' s5
  in  s6

{- | Executes 'test#' sequentially on three inputs -}
main :: IO ()
main = IO (\ s0 ->
  let s1 = test# "Hello, world!"# s0
      s2 = test# ""# s1
      s3 = test# " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"# s2
  in  (# s3, () #)
 )
