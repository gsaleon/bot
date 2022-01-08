module App.Types.Log where

data LogLevel = Debug | Info | Warning | Error
  deriving (Eq, Ord, Show)

data HandleLog = HandleLog
    { writeLog :: String -> [(String, FilePath)] -> String -> IO () }

