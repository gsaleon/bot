module Services.LogM where

import           Data.Time.Clock        (getCurrentTime)
import           Data.Time.LocalTime    (getCurrentTimeZone, utcToLocalTime)
import           Data.Time.Format       (formatTime, defaultTimeLocale)


import           App.Types.Log

makeLogMessage :: String -> String -> IO String
makeLogMessage progName mess = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = filter (/='"') $ show $ formatTime defaultTimeLocale  "%Y-%m-%d %H:%M:%S" $ utcToLocalTime timezone time
  -- let timeNow = take 19 $ show $ utcToLocalTime timezone time
  return ("\n" ++ timeNow ++ " " ++ progName ++ " " ++ mess)

{-
logM :: HandleLog -> (LogLevel, FilePath) -> String -> IO ()
logM handleLog logLevel message = writeLog handleLog logLevel message-}

logError :: HandleLog -> String -> [(String, FilePath)] -> String -> IO ()
logError handleLogError logLevel logLevelInfo message = writeLog handleLogError logLevel logLevelInfo message

logWarning :: HandleLog -> String -> [(String, FilePath)] -> String -> IO ()
logWarning handleLogWarning logLevel logLevelInfo message = writeLog handleLogWarning logLevel logLevelInfo message

logInfo :: HandleLog -> String -> [(String, FilePath)] -> String -> IO ()
logInfo handleLogInfo logLevel logLevelInfo message = writeLog handleLogInfo logLevel logLevelInfo message

logDebug :: HandleLog -> String -> [(String, FilePath)] -> String -> IO ()
logDebug handleLogDebug logLevel logLevelInfo message = writeLog handleLogDebug logLevel logLevelInfo message