module App.Handlers.HandleLog where

-- import           System.IO              (openFile, IOMode(ReadWriteMode))

-- import           App.Types.Log          ( HandleLog(..), LogLevel(..))

import            App.Types.Log

handleLog :: HandleLog
handleLog =  HandleLog { writeLog =
    \logLevel message -> do
                           appendFile (snd logLevel) message
                        }
