{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Main ( main,  LogLevel (..), Os (..), Service (..)
            ) where

--import qualified Data.Text as T
-- import           Network.HTTP.Conduit     -- as Con
-- import           Network.HTTP.Client        as Cli
-- import           Network.HTTP.Simple
-- import           Network.HTTP.Client.TLS
-- import           Network.HTTP.Types.Status        (statusCode)
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
import           Data.Aeson                       (decodeStrict, object)
import           System.Environment               (getArgs, getExecutablePath, getProgName)
import           Debug.Trace()                               -- для отладки, по готовности проги - удалить!!
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Prelude                  hiding  (id)

import           Services.ParseCommandLine
import           Lib
import           App.Types.Config
import           App.Types.ConfigTelegram
import           App.Types.ConfigVkontakte
import           App.Types.Log
import           Services.LogM                    
import           Services.Server                  (serverTelegram, makeTelegramGetUpdates, serverVkontakte)
import           Services.Telegram                (makeRequest)
import           Services.Vkontakte               (vkGroupsGetLongPollServer, vkConnect)
import           App.Handlers.HandleLog           (handleLogWarning, handleLogInfo, handleLogDebug)
-- import           App.Handlers.HandleTelegram     (handleTelegram)

main :: IO ()
main = do
  putStrLn "------------------Start--------------------"
  
  -- Initialising, read command line arguments
  commandLine <- getArgs
  let commandLineParse = parseLine commandLine
  let commandLineParseErr = fromLeft "value" commandLineParse
  let commandLineParseValue = fromRight [("","")] commandLineParse
{-  putStrLn ("commandLineParse - " ++ show commandLineParse)
  putStrLn ("commandLineParseErr - " ++ show commandLineParseErr)
  putStrLn ("commandLineParseValue - " ++ show commandLineParseValue)
  putStrLn ""-}
  
  -- Initialising, make system path
  systemPathStart <- getExecutablePath
  let systemPath = fst $ makeSystemPath systemPathStart :: FilePath
  let operSystem = snd $ makeSystemPath systemPathStart :: Os
  -- putStrLn ("systemPathStart - " ++ show systemPathStart)
  putStrLn ("systemPath - " ++ show systemPath ++ " OS: " ++ show operSystem)
  
  -- Initialising, control and read config files
  let sysPathConfig    =  systemPath ++ "/config/configBot"      :: FilePath
  let sysPathTelegram  = systemPath ++ "/config/configTelegram"  :: FilePath
  let sysPathVkontakte = systemPath ++ "/config/configVkontakte" :: FilePath
  let sysPathHelp      = systemPath ++ "/config/configHelp"      :: FilePath
  mapM_ (\(x, y) ->                                                   --  forM_ вместо mapM_ в этом коде?
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
          ,(sysPathVkontakte, "configVkontakte")
          ,(sysPathTelegram, "configTelegram")
          ,(sysPathHelp,      "configHelp")
          ]

  -- Initialising, control log files
  let sysPathDebugLog   = systemPath ++ "/logs/Debug.log"   :: FilePath
  let sysPathErrorLog   = systemPath ++ "/logs/Error.log"   :: FilePath
  let sysPathInfoLog    = systemPath ++ "/logs/Info.log"    :: FilePath
  let sysPathWarningLog = systemPath ++ "/logs/Warning.log" :: FilePath
  mapM_ (\(x, y) ->
    catch (openFile x ReadWriteMode >>= hClose)
      (\e ->  case e of
{-        _  | isAlreadyExistsError e -> error 
               ("Error: File " ++ y ++ " alredy exists")-}
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

  -- Initialising, control config files
  rawJSONConfig <- B.readFile sysPathConfig
  let setupGeneral = decodeStrict rawJSONConfig 
  case setupGeneral of
    Nothing           -> die "Invalid configGeneral JSON!"
    Just setupGeneral -> putStr $ printPrettySetup setupGeneral
  rawJSONTelegram <- B.readFile sysPathTelegram
  let setupTelegram = decodeStrict rawJSONTelegram
  case setupTelegram of
    Nothing             -> die "Invalid configTelegram JSON!"
    Just setupTelegram -> putStr $ printPrettyTelegram setupTelegram
  rawJSONVkontakte <- B.readFile sysPathVkontakte
  let setupVkontakte = decodeStrict rawJSONVkontakte
  case setupVkontakte of
    Nothing             -> die "Invalid configVkontakte JSON!"
    Just setupVkontakte -> putStr $ printPrettyVkontakte setupVkontakte

  -- Print help, initialising with (or not) command line arguments
  case commandLineParseErr of
    "help"          -> do
        helpBig <- readFile sysPathHelp
        putStrLn helpBig
        die "Stop running"
    "parsingError"  -> do
        die "Usage stack run -- -[Args] or stack run -- -h (--help) for help"
    "multipleValue" -> do
        die "Multiple value arguments. Usage stack run -- -[Args] or stack run -- -h (--help) for help"
    _               -> putStr ""
  
  -- Initialising, make note in log about start programm
  let workGeneral = fst $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  putStrLn (show workGeneral)
  progName <- getProgName
  let logLevel = logLevelGeneral workGeneral
  let logLevelInfo = [ ("Debug", sysPathDebugLog), ("Info", sysPathInfoLog)
                     , ("Warning", sysPathWarningLog), ("Error", sysPathErrorLog)
                     ] :: [(String, FilePath)]         
  let mess = snd $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  putStrLn mess
  message' <- makeLogMessage progName mess
  logInfo handleLogInfo logLevel logLevelInfo message'
  logDebug handleLogDebug logLevel logLevelInfo message'
  
  -- Initialising, control work bot
  putStrLn "-------------------------------"
  message <- makeLogMessage progName ""
  if (serviceGeneral workGeneral) == "telegram"
    then do
      --service Telegram start
      let token = tokenTelegram $ fromJust setupTelegram
      let requestObjectGetMe = object []      
      responseGetMe <- makeRequestTelegramGetMe token requestObjectGetMe logLevel logLevelInfo message
      if first_nameResponseGetMe responseGetMe /= nameTelegram (fromJust setupTelegram)
                 || usernameResponseGetMe responseGetMe /= userNameTelegram (fromJust setupTelegram)
        then do
                logWarning handleLogWarning logLevel logLevelInfo
                  $ message ++ "Error define nameTelegram or userNameTelegram in configTelegram"
                logDebug handleLogDebug logLevel logLevelInfo
                  $ message ++ "Error define nameTelegram or userNameTelegram in configTelegram"
                return ()
        else do
                logInfo handleLogInfo logLevel logLevelInfo
                  $ message ++ "Ok check control default setupTelegram"
                logDebug handleLogDebug logLevel logLevelInfo
                  $ message ++ "Ok check control default setupTelegram"
                return ()
      let longPolling = pollingGeneral workGeneral
      let repeatN = repeatGeneral workGeneral
      let requestGetUpdateObject = SendGetUpdate 0 100 1
      responseGetUpdate <- makeTelegramGetUpdates token requestGetUpdateObject
                             logLevel logLevelInfo message  :: IO ResultRequest
      let offsetGetUpdate = 
            if (result $ responseGetUpdate) == []
              then 1
              else (update_idUpdate $ last $ result $ responseGetUpdate) + 1
      let userList = [(0, repeatN)] :: [(Int, Int)]
      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      --service Vkontakte start
      let clientIdVk = client_id $ fromJust setupVkontakte
      let groupIdVk = group_id $ fromJust setupVkontakte
      let tokenVk = tokenVkontakte $ fromJust setupVkontakte
      sessionKey <- vkGroupsGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message
      let longPolling = pollingGeneral workGeneral
      let repeatN = repeatGeneral workGeneral
      let userList = [(0, repeatN)] :: [(Int, Int)]
      serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKey
      
      die "Sorry, vk is still don't work"




  putStrLn "--------------------Stop---------------------"

fromOutCommandLine :: String -> Maybe SetupGeneral -> [(String, String)] -> (SetupGeneral, String)
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

-- makeRequestTelegram ::
makeRequestTelegramGetMe token requestSendMessageObject logLevel logLevelInfo message = do
  responseGetMe <- makeRequest token "getMe" requestSendMessageObject logLevel logLevelInfo
                      $ message ++ "getMe" :: IO ResponseGetMe
  return (responseGetMe)

{--- vkImplicitFlow ::
vkImplicitFlow token requestSendMessageObject logLevel logLevelInfo message = do
  responseVkImplicitFlow <- makeRequest token "getMe" requestSendMessageObject logLevel logLevelInfo
                      $ message ++ "getMe" :: IO ResponseVkImplicitFlow
  return (responseGetMe)-}