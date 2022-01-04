module App.Types.Log where

data LogLevel = Debug | Info | Warning | Error
  deriving (Eq, Ord, Show)

data HandleLog = HandleLog
    { writeLog :: (LogLevel, FilePath) -> String -> IO () }

data HandleLogN = HandleLogN
    { writeLogN :: (LogLevel, FilePath) -> String -> IO () }
