module App.Types.HandleLog where

import Data.Time
import System.Environment

data LogLevel = Debug | Info | Warning | Error
  deriving (Eq, Ord, Show)

data LogHandle m = LogHandle
                 { writeLog :: String -> m ()
                 }

progName = do
  progName' <- getProgName
  return progName'

firstLogData = do
  time     <- getCurrentTime
  timezone <- getCurrentTimeZone
  let timeNow = take 19 $ show $ utcToLocalTime timezone time
  return $ timeNow ++ " " ++ progName ++ ": "

checkFiles = do
  let sysPathDebugLog   = systemPath ++ "/logs/Debug.log"
  let sysPathErrorLog   = systemPath ++ "/logs/Error.log"
  let sysPathInfoLog    = systemPath ++ "/logs/Info.log"
  let sysPathWarningLog = systemPath ++ "/logs/Warning.log"
  mapM_ (\(x, y) ->
           catch (readFile x >>= (\a -> putStr ""))
                    (\e ->  case e of
                      _  | isAlreadyExistsError e -> error 
                             ("Error: File " ++ y ++ " alredy exists")
                      _  | isDoesNotExistError e  -> putStrLn
                             ("File " ++ y ++ " not found, create file")
                             writeFile x ""
                      _  | isAlreadyInUseError e  -> error
                             ("Error: File " ++ y ++ "alredy use")       
                      _  | isEOFError e           -> error
                             ("Error: End of file " ++ y)
                      _  | isPermissionError e    -> error
                             ("Error: We don't have permission to read this \
                               \ file " ++ y)
                      _                           -> putStrLn
                             ("Uncaught exception " ++ y) >> ioError e
                    )
               ) [(sysPathDebugLog,   "Debug.log")
                 ,(sysPathErrorLog,   "Error.log")
                 ,(sysPathInfoLog,    "Info.log")
                 ,(sysPathWarningLog, "Warning.log")]

logM :: String -> IO ()
logM handleLog message = do
  let logLevel = parseLogLevel logLevelGeneral
  writeLogFiles LogLevel progName message =
    case LogLevel of
      Debug   -> do
        let mess = firstLogData ++ " " ++ progName ++ "" ++ message
        writeFile sysPathDebugLog mess
      Info    -> do
      	let mess = firstLogData ++ " " ++ progName ++ "" ++ message
        writeFile sysPathDebugLog mess
        writeFile sysPathInfoLog  mess
      Warning -> do
      	let mess = firstLogData ++ " " ++ progName ++ "" ++ message
        writeFile sysPathDebugLog mess
        writeFile sysPathInfoLog  mess
        writeFile sysPathErrorLog mess
      Error   -> do
      	let mess = firstLogData ++ " " ++ progName ++ "" ++ message
        writeFile sysPathDebugLog   mess
        writeFile sysPathInfoLog    mess
        writeFile sysPathErrorLog   mess
        writeFile sysPathWarningLog mess       

parseLogLevel :: String -> LogLevel
parseLogLevel logLevl = case logLevl of
                            "debug"   -> Debug
                            "info"    -> Info
                            "warning" -> Warning
                            "error"   -> Error

writeLogFile :: 
