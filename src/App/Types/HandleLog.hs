module App.Types.HandleLog where

data LogLevel = Debug | Info | Warning | Error
  deriving (Eq, Ord, Show)

data LogHandle m = LogHandle
                 { writeLog :: String -> m ()
                 }
