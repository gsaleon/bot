{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}

module Main ( main,  LogLevel (..), Os (..), Service (..)
            ) where

--import qualified Data.Text as T
import qualified Data.ByteString as B   (readFile)
import           Control.Exception      (catch)
import           System.IO              (openFile, IOMode(ReadWriteMode), hClose)
import           System.IO.Error        ( isAlreadyExistsError, isDoesNotExistError
                                        , isEOFError, isPermissionError
                                        , isAlreadyExistsError, isAlreadyExistsError
                                        , isAlreadyExistsError, isAlreadyInUseError
                                        )
import           Data.Aeson             (decodeStrict)
import           System.Environment     (getArgs, getExecutablePath, getProgName)
import           Debug.Trace()                     -- для отладки, по готовности проги - удалить!!
import           System.Exit            (die)
import           Data.Maybe             (fromJust)

import           Services.ParseCommandLine
import           Lib
import           App.Types.Config
import           App.Types.Log
import           Services.LogM          (parseLogLevel, makeLogMessage, logM)
import           App.Handlers.HandleLog (handleLog, handleLogN)

main :: IO ()
main = do
  putStrLn ("------------------Start--------------------")
  -- Read command line arguments
  commandLine <- getArgs
  let commandLineParse = parseLine commandLine
  let commandLineParseErr = fromLeft "value" commandLineParse
  let commandLineParseValue = fromRight [("","")] commandLineParse
  -- putStrLn ("commandLineParse - " ++ show commandLineParse)
  -- putStrLn ("commandLineParseErr - " ++ show commandLineParseErr)
  -- putStrLn ("commandLineParseValue - " ++ show commandLineParseValue)
  putStrLn ("")
  -- Initialising, make system path
  systemPathStart <- getExecutablePath
  let systemPath = fst $ makeSystemPath systemPathStart :: FilePath
  let operSystem = snd $ makeSystemPath systemPathStart :: Os
  -- putStrLn ("systemPathStart - " ++ show systemPathStart)
  putStrLn ("systemPath - " ++ show systemPath ++ " OS: " ++ show operSystem)
  -- Control and read config files
  let sysPathConfig    = systemPath ++ "/config/configBot" :: FilePath
  let sysPathTelegramm = systemPath ++ "/config/configTelegramm" :: FilePath
  let sysPathVcontakte = systemPath ++ "/config/configVcontakte" :: FilePath
  let sysPathHelp      = systemPath ++ "/config/configHelp" :: FilePath
  putStrLn ("")
  mapM_ (\(x, y) ->
    catch (readFile x >>= (\a -> putStr ""))
      (\e ->  case e of
        _  | isAlreadyExistsError e -> error 
               ("Error: File " ++ y ++ " alredy exists")
        _  | isDoesNotExistError e  -> error
               ("Error: File " ++ y ++ " not found")
        _  | isEOFError e           -> error
               ("Error: End of file " ++ y)
        _  | isPermissionError e    -> error
               ("Error: We don't have permission to read this \
                 \ file " ++ y)
        _                           -> putStrLn
               ("Uncaught exception " ++ y) >> ioError e
      )
        ) [(sysPathConfig,    "configBot")
          ,(sysPathVcontakte, "configVcontakte")
          ,(sysPathTelegramm, "configTelegramm")
          ,(sysPathHelp,      "configHelp")
          ]
  -- Control and log files
  let sysPathDebugLog   = systemPath ++ "logs/Debug.log" :: FilePath
  let sysPathErrorLog   = systemPath ++ "logs/Error.log" :: FilePath
  let sysPathInfoLog    = systemPath ++ "logs/Info.log" :: FilePath
  let sysPathWarningLog = systemPath ++ "logs/Warning.log" :: FilePath
  mapM_ (\(x, y) ->
    catch (openFile x ReadWriteMode >>= (\a -> hClose a))
      (\e ->  case e of
        _  | isAlreadyExistsError e -> error 
               ("Error: File " ++ y ++ " alredy exists")
        _  | isDoesNotExistError e  -> putStrLn
               ("File " ++ y ++ " not found, create file")
               -- writeFile x ""
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
          ,(sysPathWarningLog, "Warning.log")
          ]

  rawJSONConfig <- B.readFile sysPathConfig
  let setupGeneral = decodeStrict rawJSONConfig 
  putStrLn $ case setupGeneral of
    Nothing           -> "Invalid configGeneral JSON!"
    Just setupGeneral -> printPrettySetup setupGeneral
  rawJSONTelegramm <- B.readFile sysPathTelegramm
  let setupTelegramm = decodeStrict rawJSONTelegramm
  putStrLn $ case setupTelegramm of
    Nothing             -> "Invalid configTelegramm JSON!"
    Just setupTelegramm -> printPrettyTelegramm setupTelegramm
  rawJSONVcontakte <- B.readFile sysPathVcontakte
  let setupVcontakte = decodeStrict rawJSONVcontakte
  putStrLn $ case setupVcontakte of
    Nothing             -> "Invalid configVcontakte JSON!"
    Just setupVcontakte -> printPrettyVcontakte setupVcontakte

  -- Write help, initialising with command line arguments
  case commandLineParseErr of
    "help"          -> do
        helpBig <- readFile sysPathHelp
        putStrLn (helpBig)
        die "Stop running"
    "parsingError"  -> do
        die "Usage stack run -- -[Args] or stack run -- -h (--help) \
        \ for help"
    "multipleValue" -> do
        die "Multiple Value arguments. Usage stack run -- -[Args] or \
        \ stack run -- -h (--help) for help"
    _               -> putStr ""
  let workGeneral = fst $ fromOut commandLineParseErr setupGeneral commandLineParseValue
  let mess = snd $ fromOut commandLineParseErr setupGeneral commandLineParseValue
  putStrLn mess
  putStrLn (printPrettySetup workGeneral)
  -- Write in log about start programm
  progName <- getProgName
  let logLevel = case parseLogLevel $ logLevelGeneral workGeneral of
            Debug   -> (Debug, sysPathDebugLog)
            Info    -> (Info, sysPathInfoLog)
            Warning -> (Warning, sysPathWarningLog)
            Error   -> (Error, sysPathErrorLog)
  putStrLn ("logLevel - " ++ show (fst logLevel) ++ " sysPath - " ++ show (snd logLevel))
  message <- makeLogMessage logLevel progName mess
  logM handleLog logLevel message
{-  message <- makeLogMessageN logLevel progName mess
  logM handleLogN logLevel message-}
 
  putStrLn ("--------------------Stop---------------------")

fromOut :: String -> Maybe SetupGeneral -> [(String, String)] -> (SetupGeneral, [Char])
fromOut cPE setupGeneral commandLineParseValue =
  if cPE == "value"
    then
      ( fromCommandLine (fromJust setupGeneral) commandLineParseValue
      , "Start with value define in command line"
      )
    else
      ( fromJust setupGeneral
      , "Start with with default value paramets"
      )
