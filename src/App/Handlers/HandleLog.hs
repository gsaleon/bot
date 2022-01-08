module App.Handlers.HandleLog where

import            Data.List            (find)
import            App.Types.Log
import            Data.Maybe           (fromMaybe)

handleLogError :: HandleLog
handleLogError =  HandleLog { writeLog =
    \logLevel logLevelInfo message -> do
      if (parseLogLevel logLevel) == Error
        then appendFile (snd $ fromMaybe ("","") (find (\x -> fst x == "Error") logLevelInfo)) message
        else putStr ""
                             }

handleLogWarning :: HandleLog
handleLogWarning =  HandleLog { writeLog =
    \logLevel logLevelInfo message -> do
      if (parseLogLevel logLevel) <= Warning
        then appendFile (snd $ fromMaybe ("","") (find (\x -> fst x == "Warning") logLevelInfo)) message
        else putStr ""
                               }

handleLogInfo :: HandleLog
handleLogInfo =  HandleLog { writeLog =
    \logLevel logLevelInfo message -> do
      if (parseLogLevel logLevel) <= Info
        then appendFile (snd $ fromMaybe ("","") (find (\x -> fst x == "Info") logLevelInfo)) message
        else putStr ""
                            }

handleLogDebug :: HandleLog
handleLogDebug =  HandleLog { writeLog =
    \logLevel logLevelInfo message -> do
      if (parseLogLevel logLevel) == Debug
        then appendFile (snd $ fromMaybe ("","") (find (\x -> fst x == "Debug") logLevelInfo)) message
        else putStr ""
                             }

parseLogLevel :: String -> LogLevel
parseLogLevel l = case l of
      "debug"   -> Debug
      "info"    -> Info
      "warning" -> Warning
      "error"   -> Error