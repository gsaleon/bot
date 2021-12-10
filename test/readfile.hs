{-# LANGUAGE ScopedTypeVariables #-}

import System.IO
import Control.Exception

main = do
    handle (\(e :: IOException) -> print e >> return Nothing) $ do
      h <- openFile "/home/gsaleon/MyProject/bot/test/Spec_.hs" ReadMode
      print h
      return (Just h)
