{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Main ( main,  LogLevel (..), Os (..), Service (..)
            ) where

--import qualified Data.Text as T
import           Network.HTTP.Conduit     -- as Con
import           Network.HTTP.Client        as Cli
import           Network.HTTP.Simple
-- import           Network.HTTP.Client.TLS
import           Network.HTTP.Types.Status        (statusCode)
-- import           Data.Text                        (Text)

-- import qualified Data.ByteString.Lazy.Char8 as L8
-- import qualified Data.ByteString.Lazy       as L
import qualified Data.ByteString            as B  (readFile)
import           Control.Exception                (catch)
-- import           Data.Conduit                     (($$))
-- import           Network.HTTP.Client.Conduit      (bodyReaderSource)
-- import           Data.Aeson.Parser                (json)
-- import           Data.Conduit.Attoparsec          (sinkParser)
import           System.IO                        (openFile, IOMode(ReadWriteMode), hClose)
import           System.IO.Error                  ( isAlreadyExistsError, isDoesNotExistError
                                                  , isEOFError, isPermissionError
                                                  , isAlreadyExistsError, isAlreadyExistsError
                                                  , isAlreadyExistsError, isAlreadyInUseError
                                                  )
import           Data.Aeson                       (decode, decodeStrict, (.=), object, encode)
import           System.Environment               (getArgs, getExecutablePath, getProgName)
import           Debug.Trace()                               -- для отладки, по готовности проги - удалить!!
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
-- import           Data.Text
import           Prelude                  hiding  (id)

import           Services.ParseCommandLine
import           Lib
import           App.Types.Config
import           App.Types.ConfigTelegram
import           App.Types.Log
import           Services.LogM                    
import           App.Handlers.HandleLog           (handleLogError, handleLogWarning, handleLogInfo, handleLogDebug)

main :: IO ()
main = do
  putStrLn "------------------Start--------------------"
  -- Read command line arguments
  commandLine <- getArgs
  let commandLineParse = parseLine commandLine
  let commandLineParseErr = fromLeft "value" commandLineParse
  let commandLineParseValue = fromRight [("","")] commandLineParse
  -- putStrLn ("commandLineParse - " ++ show commandLineParse)
  -- putStrLn ("commandLineParseErr - " ++ show commandLineParseErr)
  -- putStrLn ("commandLineParseValue - " ++ show commandLineParseValue)
  putStrLn ""
  -- Initialising, make system path
  systemPathStart <- getExecutablePath
  let systemPath = fst $ makeSystemPath systemPathStart :: FilePath
  let operSystem = snd $ makeSystemPath systemPathStart :: Os
  -- putStrLn ("systemPathStart - " ++ show systemPathStart)
  putStrLn ("systemPath - " ++ show systemPath ++ " OS: " ++ show operSystem)
  -- Control and read config files
  let sysPathConfig    = systemPath ++ "/config/configBot"       :: FilePath
  let sysPathTelegramm = systemPath ++ "/config/configTelegramm" :: FilePath
  let sysPathVcontakte = systemPath ++ "/config/configVcontakte" :: FilePath
  let sysPathHelp      = systemPath ++ "/config/configHelp"      :: FilePath
  putStrLn ""
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
  -- Control log files
  let sysPathDebugLog   = systemPath ++ "logs/Debug.log"   :: FilePath
  let sysPathErrorLog   = systemPath ++ "logs/Error.log"   :: FilePath
  let sysPathInfoLog    = systemPath ++ "logs/Info.log"    :: FilePath
  let sysPathWarningLog = systemPath ++ "logs/Warning.log" :: FilePath
  mapM_ (\(x, y) ->
    catch (openFile x ReadWriteMode >>= hClose)
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
  -- Control config files
  rawJSONConfig <- B.readFile sysPathConfig
  let setupGeneral = decodeStrict rawJSONConfig 
  putStr $ case setupGeneral of
    Nothing           -> "Invalid configGeneral JSON!"
    Just setupGeneral -> printPrettySetup setupGeneral
  rawJSONTelegramm <- B.readFile sysPathTelegramm
  let setupTelegramm = decodeStrict rawJSONTelegramm
  putStr $ case setupTelegramm of
    Nothing             -> "Invalid configTelegramm JSON!"
    Just setupTelegramm -> printPrettyTelegramm setupTelegramm
  rawJSONVcontakte <- B.readFile sysPathVcontakte
  let setupVcontakte = decodeStrict rawJSONVcontakte
  putStr $ case setupVcontakte of
    Nothing             -> "Invalid configVcontakte JSON!"
    Just setupVcontakte -> printPrettyVcontakte setupVcontakte
  -- Print help, initialising with (or not) command line arguments
  case commandLineParseErr of
    "help"          -> do
        helpBig <- readFile sysPathHelp
        putStrLn helpBig
        die "Stop running"
    "parsingError"  -> do
        die "Usage stack run -- -[Args] or stack run -- -h (--help) \
        \ for help"
    "multipleValue" -> do
        die "Multiple Value arguments. Usage stack run -- -[Args] or \
        \ stack run -- -h (--help) for help"
    _               -> putStr ""
  let workGeneral = fst $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  let mess = snd $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  putStrLn mess
  putStrLn (printPrettySetup workGeneral)

  -- Make note in log about start programm
  progName <- getProgName
  let logLevel = logLevelGeneral workGeneral
  let logLevelInfo = [ ("Debug", sysPathDebugLog), ("Info", sysPathInfoLog)
                     , ("Warning", sysPathWarningLog), ("Error", sysPathErrorLog)
                     ] :: [(String, FilePath)]         
  message <- makeLogMessage progName mess
  logInfo handleLogInfo logLevel logLevelInfo message  -- Write note in log about start programm

  -- Basic function bot
  let urlTel = urlTelegramm (fromJust setupTelegramm) ++ "bot" ++ tokenTelegramm (fromJust setupTelegramm)
 
  --First request
  putStrLn "-------------------------------"
  message <- makeLogMessage progName ""
  manager <- newManager tlsManagerSettings
  let requestObject = object []
  let requestGetMe = urlTel ++ "/getMe"
  initialRequest <- parseRequest requestGetMe
  let request = initialRequest 
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode requestObject
              , requestHeaders = [ ("Content-Type", "application/json; charset=utf-8")]
               }
  logInfo handleLogInfo logLevel logLevelInfo
      $ message ++ "Send GET request getMe"
  response <- Cli.httpLbs request manager
  print (getResponseBody response)  -- ----------------------------
  let statusCodeResponse = statusCode $ responseStatus response
  if statusCodeResponse == 200
    then putStrLn $ "The status code getMe was: " ++ show statusCodeResponse
    else putStrLn $ "The status code getMe was: " ++ show statusCodeResponse ++ " error response"
  let responseGet = decode $ responseBody response
  putStrLn $ case responseGet of
      Nothing           -> "Error response getMe, check tokenTelegramm in /config/tmp/configTelegramm"
      Just responseGet -> printResponseGetMe responseGet
  if first_nameResponseGetMe (fromJust responseGet) /= nameTelegramm (fromJust setupTelegramm)
             || username (fromJust responseGet) /= userNameTelegramm (fromJust setupTelegramm)
    then logWarning handleLogWarning logLevel logLevelInfo
           $ message ++ "Error define nameTelegramm or userNameTelegramm in configTelegramm"
    else logInfo handleLogInfo logLevel logLevelInfo
           $ message ++ "Ok check control default setupTelegramm"

  let longPolling = pollingGeneral workGeneral
  let requestObject = object ["timeout" .= (longPolling :: Int)]
  let requestGetMe = urlTel ++ "/getUpdates"
  initialRequest <- parseRequest requestGetMe
  let request = initialRequest 
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode requestObject
              , requestHeaders = [ ("Content-Type", "application/json; charset=utf-8")]
               }
  logInfo handleLogInfo logLevel logLevelInfo
      $ message ++ "Send GET request getUpdates " ++ "timeout " ++ show longPolling
  response <- Cli.httpLbs request manager
  print (getResponseBody response)  -- ----------------------------
  let statusCodeResponse = statusCode $ responseStatus response
  if statusCodeResponse == 200
    then putStrLn $ "The status code getUpdates was: " ++ show statusCodeResponse
    else putStrLn $ "The status code getUpdates was: " ++ show statusCodeResponse ++ " error response"
  let responseGet = decode $ getResponseBody response
  putStrLn $ case responseGet of
    Nothing          -> "Error decode response getUpdate"
    Just responseGet -> printResultRequest responseGet




  putStrLn "--------------------Stop---------------------"

fromOutCommandLine :: String -> Maybe SetupGeneral -> [(String, String)] -> (SetupGeneral, [Char])
fromOutCommandLine cPE setupGeneral commandLineParseValue =
  if cPE == "value"
    then
      ( fromCommandLine (fromJust setupGeneral) commandLineParseValue
      , "Start with value define in command line"
      )
    else
      ( fromJust setupGeneral
      , "Start with default value parametrs"
      )
