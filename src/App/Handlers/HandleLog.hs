module App.Handlers.HandleLog where

import            App.Types.Log

handleLog :: HandleLog
handleLog =  HandleLog { writeLog =
    \logLevel message -> do
                           appendFile (snd logLevel) message
                        }
