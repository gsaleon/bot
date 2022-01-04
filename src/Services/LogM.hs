module Services.LogM where

import           Data.Time.Clock        (getCurrentTime)
import           Data.Time.LocalTime    (getCurrentTimeZone, utcToLocalTime)

import           App.Types.Log

makeLogMessage :: (LogLevel, FilePath) -> String -> String -> IO String
makeLogMessage logLevel progName mess = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = take 19 $ show $ utcToLocalTime timezone time
  return (timeNow ++ " " ++ progName ++ " " ++ mess ++ "\n")

makeLogMessageN :: (LogLevel, FilePath) -> String -> String -> IO String
makeLogMessageN logLevel progName mess = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = take 19 $ show $ utcToLocalTime timezone time
  let logLevelPrint = if (length (show $ fst logLevel) < 7)
      then (show . fst) logLevel ++ take (7 - length (show $ fst logLevel)) "    "
      else show $ fst logLevel
  return (timeNow ++ " " ++ progName ++ " " ++ logLevelPrint ++ " " ++ mess ++ "\n")

parseLogLevel :: String -> LogLevel
parseLogLevel l = case l of
      "debug"   -> Debug
      "info"    -> Info
      "warning" -> Warning
      "error"   -> Error

logM :: HandleLog -> (LogLevel, FilePath) -> String -> IO ()
logM handleLog logLevel message = writeLog handleLog logLevel message

-- logM :: HandleLog -> (LogLevel, FilePath) -> String -> IO ()
-- logM handleLogN logLevel message = writeLogN handleLogN logLevel message