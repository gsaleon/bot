module App.Handlers.HandleLog where

import           System.IO              (openFile, IOMode(ReadWriteMode))

import           App.Types.Log          ( HandleLog(..), LogLevel(..)
                                        , HandleLogN(..))

handleLog :: HandleLog
handleLog =  HandleLog { writeLog =
    \logLevel message -> do
                           appendFile (snd logLevel) message
                        }

handleLogN :: HandleLogN
handleLogN = HandleLogN { writeLogN =
    \logLevel message -> putStrLn message
                         }
  