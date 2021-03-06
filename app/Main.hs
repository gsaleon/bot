{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE CPP #-}

module Main ( main,  LogLevel (..), Service (..)
            ) where

import qualified Data.ByteString            as B  (readFile)
import           Control.Exception                (catch)
import           System.IO                        (openFile, IOMode(ReadWriteMode), hClose)
import           System.IO.Error                  ( isAlreadyExistsError, isDoesNotExistError
                                                  , isEOFError, isPermissionError
                                                  , isAlreadyExistsError, isAlreadyExistsError
                                                  , isAlreadyExistsError, isAlreadyInUseError
                                                  )
import           Data.Time.Clock                  (getCurrentTime)
import           Data.Time.LocalTime              (getCurrentTimeZone, utcToLocalTime)
import           Data.Time.Format                 (formatTime, defaultTimeLocale)
import           Data.Aeson                       (decodeStrict, object)
import           System.Environment               (getArgs, getExecutablePath, getProgName)
import           Debug.Trace()                               -- для отладки, по готовности проги - удалить!!
import           System.Exit                      (die)
import           Data.Maybe                       (fromJust)
import           Prelude                  hiding  (id)
import           Data.Yaml
import           GHC.Generics
import           Data.Yaml                        (decodeFileEither, (.:), parseEither, prettyPrintParseException)
-- import           Data.Map                         ( Map )
import           Control.Applicative              ( (<$>) )
import           System.FilePath                  (FilePath, (</>))

import           Services.ParseCommandLine
import           Lib
import           App.Types.Config
import           App.Types.ConfigTelegram
import           App.Types.ConfigVkontakte
import           App.Types.Log
import           Services.LogM                    
import           Services.Server                  (serverTelegram, makeTelegramGetUpdates, serverVkontakte)
import           Services.Telegram                (makeRequest)
import           Services.Vkontakte               (vkGroupsGetLongPollServer, vkGetUpdate, vkSendMessage)
import           App.Handlers.HandleLog           (handleLogWarning, handleLogInfo, handleLogDebug)


data BotSetup = BotSetup { setupGeneral   :: SetupGeneral
                         , setupTelegram  :: SetupTelegram
                         , setupVkontakte :: SetupVkontakte
                         } deriving Show

type ErrorMsg = String

main :: IO ()
main = do
  putStrLn "------------------Start--------------------"
  -- Initialising, read command line arguments
  commandLine <- getArgs
  let commandLineParse = parseLine commandLine
  let commandLineParseErr = fromLeft "value" commandLineParse
  let commandLineParseValue = fromRight [("","")] commandLineParse
  
  -- Initialising, make system path
  systemPathStart <- getExecutablePath
  let systemPath = makeSystemPath systemPathStart :: FilePath
  putStrLn ("systemPath - " ++ show systemPath) 
  let sysPathHelp = systemPath </> "config" </> "helpRun.txt"  :: FilePath
  
  -- Print help
  case commandLineParseErr of
    "help"          -> do
        helpRun <- readFile sysPathHelp
        putStrLn helpRun
        die "Stop running"
    "parsingError"  -> do
        die "Usage stack run -- -[Args] or stack run -- -h (--help) for help"
    "multipleValue" -> do
        die "Multiple value arguments. Usage stack run -- -[Args] or stack run -- -h (--help) for help"
    _               -> putStr ""

  -- Control config and log files
  let sysPathConfig = systemPath </> "config" </> "config.yaml" :: FilePath
  mapM_ (\(x, y) ->                      --  forM_ вместо mapM_ в этом коде?
    catch (readFile x >>= (\a -> putStr ""))
      (\e ->  case e of
        _  | isAlreadyExistsError e -> error 
               ("Error: File " ++ y ++ " alredy exists")
        _  | isDoesNotExistError e  -> error
               ("Error: File " ++ y ++ " not found")
        _  | isEOFError e           -> error
               ("Error: End of file " ++ y)
        _  | isPermissionError e    -> error
               ("Error: We don't have permission to read this file " ++ y)
        _                           -> putStrLn
               ("Uncaught exception " ++ y) >> ioError e
      )
        ) [(sysPathConfig,    "config.yaml")
          ]
  let sysPathDebugLog   = systemPath </> "logs" </> "Debug.log"   :: FilePath
  let sysPathErrorLog   = systemPath </> "logs" </> "Error.log"   :: FilePath
  let sysPathInfoLog    = systemPath </> "logs" </> "Info.log"    :: FilePath
  let sysPathWarningLog = systemPath </> "logs" </> "Warning.log" :: FilePath
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
               ("Error: We don't have permission to read this file " ++ y)
        _                           -> putStrLn
               ("Uncaught exception " ++ y) >> ioError e
      )
        ) [(sysPathDebugLog,   "Debug.log")
          ,(sysPathErrorLog,   "Error.log")
          ,(sysPathInfoLog,    "Info.log")
          ,(sysPathWarningLog, "Warning.log")
          ]

  -- Read config files
  parsedValue <- readBotSetup sysPathConfig
  print parsedValue
  -- die "End"
  -- rawJSONConfig <- B.readFile sysPathConfig
  -- let setupGeneral = decodeStrict rawJSONConfig 
  -- case setupGeneral of
  --   Nothing           -> die "Invalid configGeneral JSON!"
  --   Just setupGeneral -> putStr $ printPrettySetup setupGeneral
  -- rawJSONTelegram <- B.readFile sysPathTelegram
  -- let setupTelegram = decodeStrict rawJSONTelegram
  -- case setupTelegram of
  --   Nothing             -> die "Invalid configTelegram JSON!"
  --   Just setupTelegram -> putStr $ printPrettyTelegram setupTelegram
  -- rawJSONVkontakte <- B.readFile sysPathVkontakte
  -- let setupVkontakte = decodeStrict rawJSONVkontakte
  -- case setupVkontakte of
  --   Nothing             -> die "Invalid configVkontakte JSON!"
  --   Just setupVkontakte -> putStr $ printPrettyVkontakte setupVkontakte
 
  -- Make note in log about start programm
  let workGeneral = fst $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  progName <- getProgName
  let logLevel = logLevelGeneral workGeneral
  let logLevelInfo = [ ("Debug", sysPathDebugLog), ("Info", sysPathInfoLog)
                     , ("Warning", sysPathWarningLog), ("Error", sysPathErrorLog)
                     ] :: [(String, FilePath)]         
  let mess = snd $ fromOutCommandLine commandLineParseErr setupGeneral commandLineParseValue
  putStr mess
  putStrLn $ printPrettyworkGeneral workGeneral
  message' <- makeLogMessage progName (mess ++ printPrettyworkGeneral workGeneral)
  logInfo handleLogInfo logLevel logLevelInfo message'
  logDebug handleLogDebug logLevel logLevelInfo message'
  
  -- Start bot
  putStrLn "-------------------------------"
  message <- makeLogMessage progName ""
  let longPolling = pollingGeneral workGeneral
  let repeatN = repeatGeneral workGeneral
  let userList = [(0, repeatN)] :: [(Int, Int)]
  if (serviceGeneral workGeneral) == "telegram"
    then do
      --service Telegram start
      let token = tokenTelegram $ fromJust setupTelegram
      let requestObjectGetMe = object []      
      responseGetMe <- makeRequestTelegramGetMe token requestObjectGetMe logLevel logLevelInfo message
      -- logInfo handleLogInfo logLevel logLevelInfo
      --   $ message ++ "Ok check control default setupTelegram"
      -- logDebug handleLogDebug logLevel logLevelInfo
      --   $ message ++ "Ok check control default setupTelegram"
      let requestGetUpdateObject = SendGetUpdate 0 100 1
      responseGetUpdate <- makeTelegramGetUpdates token requestGetUpdateObject
                             logLevel logLevelInfo message  :: IO ResultRequest
      let offsetGetUpdate = 
            if (result $ responseGetUpdate) == []
              then 1
              else (update_idUpdate $ last $ result $ responseGetUpdate) + 1
      serverTelegram setupTelegram logLevel logLevelInfo token message userList longPolling offsetGetUpdate
    else do
      --service Vkontakte start
      let clientIdVk = client_id $ fromJust setupVkontakte
      let groupIdVk = group_id $ fromJust setupVkontakte
      let tokenVk = tokenVkontakte $ fromJust setupVkontakte
      sessionKey <- vkGroupsGetLongPollServer tokenVk groupIdVk logLevel logLevelInfo message
      serverVkontakte setupVkontakte logLevel logLevelInfo message userList longPolling sessionKey

  putStrLn "--------------------Stop---------------------"

fromOutCommandLine :: String -> Maybe SetupGeneral -> [(String, String)] -> (SetupGeneral, String)
fromOutCommandLine cPE setupGeneral commandLineParseValue =
  if cPE == "value"
    then
      ( fromCommandLine (fromJust setupGeneral) commandLineParseValue
      , "Start with value define in command line: "
      )
    else
      ( fromJust setupGeneral
      , "Start with default value parametrs: "
      )

readBotSetup :: FilePath -> IO (Either ErrorMsg BotSetup)
readBotSetup file =
  (\val -> case val of
      (Right yamlObj) -> do
        setupGeneral   <- parseEither (.: "setupGeneral") yamlObj
        setupTelegram  <- parseEither (.: "setupTelegram") yamlObj
        setupVkontakte <- parseEither (.: "setupVkontakte") yamlObj
        return $ BotSetup setupGeneral setupTelegram setupVkontakte
      (Left exception) -> Left $ prettyPrintParseException exception
    )
    <$> decodeFileEither file

-- makeRequestTelegram ::
makeRequestTelegramGetMe token requestSendMessageObject logLevel logLevelInfo message = do
  responseGetMe <- makeRequest token "getMe" requestSendMessageObject logLevel logLevelInfo
                      $ message ++ "getMe" :: IO ResponseGetMe
  return (responseGetMe)


