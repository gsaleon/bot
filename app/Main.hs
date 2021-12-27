{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

--import qualified Data.Text as T
import qualified Data.ByteString as B (readFile)
--import           System.IO            (openFile)
import           Control.Monad        (mzero, when)
import           Control.Exception    (catch)
import           System.IO.Error      (isAlreadyExistsError, isDoesNotExistError
                                      , isEOFError, isPermissionError)
--import           Control.Applicative  ((<$>), (<*>))
--import           Control.Exception
import           Data.Aeson
import           Data.List            (find)
--import           Data.Monoid          ((<>))
import           System.Environment   (getArgs, getExecutablePath)
--import           System.IO
--import           Control.Applicative
import           Debug.Trace()                     -- для отладки, по готовности проги - удалить!!
--import           System.FilePath
import           System.Exit          (die)
import           Data.Maybe           (isJust)


import           Services.ParseCommandLine
--import           App.Handlers.LogCommandLine

--Определения типов, использующихся в программе
data Os = Linux | Windows deriving Show

data Service = Telegramm | Vcontakte deriving Show

data LogLevel = Debug | Info | Warning | Error deriving (Eq, Ord, Show)

data WorkValue = WorkValue SetupGeneral SetupTelegramm SetupVcontakte deriving Show

--data SetupLocal = SetupLocal Service LogLevel SetupGeneral SetupTelegramm
--                | SetupLocal Service LogLevel SetupGeneral SetupVcontakte

data SetupTelegramm = SetupTelegramm
                    { urlTelegramm            :: String
                    , nameTelegramm           :: String
                    , userNameTelegramm       :: String
                    , tokenTelegramm          :: String
                    , descriptionTelegramm    :: String
                    , aboutTelegramm          :: String
                    , commandTelegramm        :: String
                    , questionTelegrammRepeat :: String
                    } deriving Show

instance FromJSON SetupTelegramm where
  parseJSON (Object setupTelegramm) = SetupTelegramm
    <$> setupTelegramm .: "urlTelegramm"
    <*> setupTelegramm .: "nameTelegramm"
    <*> setupTelegramm .: "userNameTelegramm"
    <*> setupTelegramm .: "tokenTelegramm"
    <*> setupTelegramm .: "descriptionTelegramm"
    <*> setupTelegramm .: "aboutTelegramm"
    <*> setupTelegramm .: "commandTelegramm"
    <*> setupTelegramm .: "questionTelegrammRepeat"
  parseJSON _                       = mzero

data SetupVcontakte = SetupVcontakte
                    { urlVcontakte         :: String
                    , nameVcontakte        :: String
                    , userNameVcontakte    :: String
                    , tokenVcontakte       :: String
                    , descriptionVcontakte :: String
                    , aboutVcontakte       :: String
                    , commandVcontakte     :: String
                    } deriving Show

instance FromJSON SetupVcontakte where
  parseJSON (Object setupVcontakte) = SetupVcontakte
    <$> setupVcontakte .: "urlVcontakte"
    <*> setupVcontakte .: "nameVcontakte"
    <*> setupVcontakte .: "userNameVcontakte"
    <*> setupVcontakte .: "tokenVcontakte"
    <*> setupVcontakte .: "descriptionVcontakte"
    <*> setupVcontakte .: "aboutVcontakte"
    <*> setupVcontakte .: "commandVcontakte"
  parseJSON _                       = mzero

data SetupGeneral = SetupGeneral
                  { pollingGeneral    :: Int
                  , repeatGeneral     :: Int
                  , logLevelGeneral   :: String
                  , serviceGeneral    :: String
                  } deriving Show

instance FromJSON SetupGeneral where
  parseJSON (Object setupGeneral) = SetupGeneral
    <$> setupGeneral .: "pollingGeneral"
    <*> setupGeneral .: "repeatGeneral"
    <*> setupGeneral .: "logLevelGeneral"
    <*> setupGeneral .: "serviceGeneral"
  parseJSON _                     = mzero

printPrettyVcontakte :: SetupVcontakte -> String
printPrettyVcontakte (SetupVcontakte urlVcontakte nameVcontakte
     userNameVcontakte tokenVcontakte descriptionVcontakte
     aboutVcontakte commandVcontakte questionTelegrammRepeat) = ""
{--  "urlVcontakte -         " ++ urlVcontakte         ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "userNameVcontakte -    " ++ userNameVcontakte    ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "descriptionVcontakte - " ++ descriptionVcontakte ++ "\n" ++
  "aboutVcontakte -       " ++ aboutVcontakte       ++ "\n" ++
  "commandVcontakte -     " ++ commandVcontakte
--}
printPrettyTelegramm :: SetupTelegramm -> String
printPrettyTelegramm (SetupTelegramm urlTelegramm nameTelegramm
     userNameTelegramm tokenTelegramm descriptionTelegramm
     aboutTelegramm commandTelegramm questionTelegrammRepeat) = ""
{--  "urlTelegramm -         " ++ urlTelegramm         ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "userNameTelegramm -    " ++ userNameTelegramm    ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "descriptionTelegramm - " ++ descriptionTelegramm ++ "\n" ++
  "aboutTelegramm -       " ++ aboutTelegramm       ++ "\n" ++
  "commandTelegramm -     " ++ commandTelegramm     ++ "\n" ++
  "questionTelegrammRepeat"
--}
printPrettySetup :: SetupGeneral -> String
printPrettySetup (SetupGeneral pollingGeneral repeatGeneral
     logLevelGeneral serviceGeneral) = ""
{--  "pollingGeneral -       " ++ show pollingGeneral  ++ "\n" ++
  "repeatGeneral -        " ++ show repeatGeneral   ++ "\n" ++
  "logLevelGeneral -      " ++ show logLevelGeneral ++ "\n" ++
  "serviceGeneral -       " ++ show serviceGeneral
--}
main :: IO ()
main = do
         putStrLn ("------------------Start--------------------")
--       Читаем аргументы командной строки
         commandLine <- getArgs
         let commandLineParse = parseLine commandLine
         let commandLineParseErr = fromLeft "value" commandLineParse
         let commandLineParseValue = fromRight [("","")] commandLineParse
         putStrLn ("commandLineParse - " ++ show commandLineParse)
         putStrLn ("commandLineParseErr - " ++ show commandLineParseErr)
         putStrLn ("commandLineParseValue - " ++ show commandLineParseValue)
--       Инициализируем переменные, при необходимости выводим хелп
--       Определяем пути
         systemPathStart <- getExecutablePath
         let systemPath = fst $ makeSystemPath systemPathStart
--         putStrLn ("systemPathStart - " ++ show systemPathStart)
         putStrLn ("systemPath - " ++ show systemPath)
--       Проверяем и читаем файлы настроек
         let sysPathConfig = systemPath ++ "/config/configBot"
         let sysPathTelegramm = systemPath ++ "/config/configTelegramm"
         let sysPathVcontakte = systemPath ++ "/config/configVcontakte"
         let sysPathHelp = systemPath ++ "/config/configHelp"
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
                 ,(sysPathHelp,      "configHelp")]

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

--       Выводим полную справку если она задана в коммандной строке или
--       короткую, если есть ошибки парсинга, а также перезаписываем
--       данные конфигов данными в командной строке, если они есть
         when (commandLineParseErr == "help")          $ do
           helpBig <- readFile sysPathHelp
           putStrLn (helpBig)
           die "Stop running"
         when (commandLineParseErr == "parsingError")  $ do
           die "Usage stack run -- -[Args] or stack run -- -h (--help) \
             \ for help"
         when (commandLineParseErr == "multipleValue") $ do
           die "Multiple Value arguments. Usage stack run -- -[Args] or \
             \ stack run -- -h (--help) for help"
         when (commandLineParseErr == "value")         $ do
           let valueParse = fromRight [("","")] commandLineParse
           let pollingGeneral workValue =
                 if isJust $ find ((=="polling:") . fst) valueParse
                   then snd $ fromJust $ find ((=="polling:") . fst) valueParse
--                      concat $ map (\x -> case x of ("polling:", y) -> y ; _ -> "") valueParse
                   else pollingGeneral setupGeneral
           let repeatGeneral workValue =
                 if isJust $ find ((=="repeat:") . fst) valueParse
                   then snd $ fromJust $ find ((=="repeat:") . fst) valueParse
                   else repeatGeneral setupGeneral
           let loglevelGeneral workValue =
                 if isJust $ find ((=="loglevel:") . fst) valueParse
                   then snd $ fromJust $ find ((=="loglevel:") . fst) valueParse
                   else loglevelGeneral setupGeneral
           let serviceGeneral workValue =
                 if isJust $ find ((=="service:") . fst) valueParse
                   then snd $ fromJust $ find ((=="service:") . fst) valueParse
                   else serviceGeneral setupGeneral


         
         putStrLn ("--------------------Stop---------------------")

--data WorkValue = WorkValue SetupGeneral SetupTelegramm SetupVcontakte

--newValue :: Parse a b -> SetupGeneral -> SetupVcontakte
--  -> SetupTelegramm -> WorkValue
{--newValue commandLineParse setupGeneral setupVcontakte setupTelegramm = 
  if (findStr (snd $ fromRight [("","")] commandLineParse) "vcontakte")
    then WorkValue Vcontakte SetupGeneral SetupTelegramm SetupVcontakte
    else _
--}
fromLeft :: String -> Parse a b -> String
fromLeft _ (Err a) = a
fromLeft a _       = a

fromRight :: [(String,String)] -> Parse a b -> [(String,String)]
fromRight _ (Value b) = b
fromRight b _         = b

makeSystemPath :: FilePath -> (FilePath, Os)
makeSystemPath str =
  if '/' `elem` str
    then ((makeSystemPath' str) ++ "/bot/", Linux)
    else ((makeSystemPath'' str) ++ "\\bot", Windows)
  where
    makeSystemPath' [] = []
    makeSystemPath' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "/bot/" = x0 : makeSystemPath' (x1:x2:x3:x4:xs)
      | otherwise                    = []
    makeSystemPath'' [] = []
    makeSystemPath'' (x0:x1:x2:x3:x4:xs)
      | x0:x1:x2:x3:x4:[] /= "\\bot" = x0 : makeSystemPath'' (x1:x2:x3:x4:xs)
      | otherwise                    = []

