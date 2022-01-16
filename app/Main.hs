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
import           Services.Telegramm               (makeRequest)
import           App.Handlers.HandleLog           (handleLogError, handleLogWarning, handleLogInfo, handleLogDebug)
-- import           App.Handlers.HandleTelegramm     (handleTelegram)

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
  -- putStrLn (printPrettySetup workGeneral)

  -- Make note in log about start programm
  progName <- getProgName
  let logLevel = logLevelGeneral workGeneral
  let logLevelInfo = [ ("Debug", sysPathDebugLog), ("Info", sysPathInfoLog)
                     , ("Warning", sysPathWarningLog), ("Error", sysPathErrorLog)
                     ] :: [(String, FilePath)]         
  message <- makeLogMessage progName mess
  logInfo handleLogInfo logLevel logLevelInfo message  -- Write note in log about start programm
  logDebug handleLogDebug logLevel logLevelInfo message
  -- Basic function bot
  let urlTel = urlTelegramm (fromJust setupTelegramm) ++ "bot" ++ tokenTelegramm (fromJust setupTelegramm)
 
  --First request
  putStrLn "-------------------------------"
  -- Change to out function start
  message <- makeLogMessage progName ""
  let requestObjectGetMe = object []
  -- manager <- newManager tlsManagerSettings
  let requestGetMe = "getMe"
  let token = tokenTelegramm (fromJust setupTelegramm)
  responseGetMe <- makeRequest token requestGetMe requestObjectGetMe logLevel logLevelInfo message
  putStrLn $ case responseGetMe of
      Nothing          -> "Error response getMe, check tokenTelegramm in /config/tmp/configTelegramm"
      Just responseGetMe -> printResponseGetMe responseGetMe
  if first_nameResponseGetMe (fromJust responseGetMe) /= nameTelegramm (fromJust setupTelegramm)
             || username (fromJust responseGetMe) /= userNameTelegramm (fromJust setupTelegramm)
    then logWarning handleLogWarning logLevel logLevelInfo
           $ message ++ "Error define nameTelegramm or userNameTelegramm in configTelegramm"
    else logInfo handleLogInfo logLevel logLevelInfo
           $ message ++ "Ok check control default setupTelegramm"
  -- Basic cycle
  let longPolling = pollingGeneral workGeneral
  let limitGetUpdate = 1
  let offsetGetUpdate = 1
  let requestGetUpdateObject = object [ "timeout" .= (longPolling     :: Int)
                                      , "limit"   .= (limitGetUpdate  :: Int)
                                      , "offset"  .= (offsetGetUpdate :: Int)
                                      ]
  let requestGetUpdate = "getUpdates"
  responseGetUpdate <- makeRequest token requestGetUpdate requestGetUpdateObject logLevel logLevelInfo message
  {-
  getUpdateRequest <- parseRequest requestGetUpdate
  let requestGetUpdate = getUpdateRequest 
              { method = "GET"
              , requestBody = RequestBodyLBS $ encode requestGetUpdateObject
              , requestHeaders = [ ("Content-Type", "application/json; charset=utf-8")]
               }
  logInfo handleLogInfo logLevel logLevelInfo
      $ message ++ "Send GET request getUpdates " ++ "timeout " ++ show longPolling
  responseGetUpdate <- Cli.httpLbs requestGetUpdate manager
  -- print (getResponseBody responseGetUpdate)
  let statusCodeResponseGetUpdate = statusCode $ responseStatus responseGetUpdate
  if statusCodeResponseGetUpdate == 200
    then logInfo handleLogInfo logLevel logLevelInfo
             $ message ++ "The status code getUpdate was: " ++ show statusCodeResponseGetUpdate
        -- putStrLn $ "The status code getUpdates was: " ++ show statusCodeResponseGetUpdate
    else logError handleLogError logLevel logLevelInfo
             $ message ++ "The status code getUpdates was: " ++ show statusCodeResponseGetUpdate ++ " error response"
        -- putStrLn $ "The status code getUpdates was: " ++ show statusCodeResponseGetUpdate ++ " error response"
  let responseGet = decode $ getResponseBody responseGetUpdate
  -}
  putStrLn $ case responseGetUpdate of
    Nothing                -> "Error decode response getUpdate"
    Just responseGetUpdate -> printResponseGetUpdate responseGetUpdate
                                                                                                                                      
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
