module Services.LogM where

import           Data.Time.Clock        (getCurrentTime)
import           Data.Time.LocalTime    (getCurrentTimeZone, utcToLocalTime)
import           Data.Time.Format       (formatTime, defaultTimeLocale)


import           App.Types.Log

makeLogMessage :: (LogLevel, FilePath) -> String -> String -> IO String
makeLogMessage logLevel progName mess = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = filter (/='"') $ show $ formatTime defaultTimeLocale  "%Y-%m-%d %H:%M:%S" $ utcToLocalTime timezone time
  -- let timeNow = take 19 $ show $ utcToLocalTime timezone time
  return (timeNow ++ " " ++ progName ++ " " ++ mess ++ "\n")

parseLogLevel :: String -> LogLevel
parseLogLevel l = case l of
      "debug"   -> Debug
      "info"    -> Info
      "warning" -> Warning
      "error"   -> Error

logM :: HandleLog -> (LogLevel, FilePath) -> String -> IO ()
logM handleLog logLevel message = writeLog handleLog logLevel message

