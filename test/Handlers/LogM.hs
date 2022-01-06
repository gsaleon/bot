module Services.LogM where

import           Data.Time.Clock        (getCurrentTime)
import           Data.Time.LocalTime    (getCurrentTimeZone, utcToLocalTime)

import           App.Types.Log

-- Вместо файлов печатает в консоль, выводя дополнительно LogLevel
makeLogMessage :: (LogLevel, FilePath) -> String -> String -> IO String
makeLogMessage logLevel progName mess = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = take 19 $ show $ utcToLocalTime timezone time
  let logLevelPrint = if (length (show $ fst logLevel) < 7)
      then (show . fst) logLevel ++ take (7 - length (show $ fst logLevel)) "    "
      else show $ fst logLevel
  return (timeNow ++ " " ++ progName ++ " " ++ logLevelPrint ++ " " ++ mess ++ "\n")

logM :: HandleLog -> (LogLevel, FilePath) -> String -> IO ()
logM handleLog logLevel message = writeLog handleLog logLevel message