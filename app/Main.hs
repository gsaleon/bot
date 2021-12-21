{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import qualified Data.ByteString as B (readFile)
import           Control.Monad        (mzero)
import           Control.Applicative  ((<$>), (<*>))
--import           Control.Exception
import           Data.Aeson
--import           Data.Monoid          ((<>))
import           System.Environment   (getArgs, getExecutablePath)
--import           System.IO
--import           Control.Applicative
import           Debug.Trace()                     -- для отладки, по готовности проги - удалить!!
import           System.FilePath

import           Services.ParseCommandLine

--Определения типов, использующихся в программе
newtype Repeat = Repeat Int

newtype Polling = Polling Int

data Service = Telegramm | Vcontakte deriving Show

data LogLevel = Debug | Info | Warning | Error deriving Show

data SetupTelegramm = SetupTelegramm
                   { urlTelegramm      :: String
                   , nameTelegramm     :: String
                   , userNameTelegramm :: String
                   , tokenTelegramm    :: String
                   , description       :: String
                   , about             :: String
                   , command           :: String
                   }

data SetupVcontakte = SetupVcontakte
                   { urlVcontakte      :: String
                   , nameVcontakte     :: String
                   }

data SetupDefault = SetupDefault
                   { pollingDefault    :: Int
                   , repeatDefault     :: Int
                   , logLevelDefault   :: String
                   }

instance FromJSON SetupTelegramm where
  parseJSON (Object setupTelegramm) = SetupTelegramm
                                   <$> setupTelegramm .: "urlTelegramm"
                                   <*> setupTelegramm .: "nameTelegramm"
                                   <*> setupTelegramm .: "userNameTelegramm"
                                   <*> setupTelegramm .: "tokenTelegramm"
                                   <*> setupTelegramm .: "description"
                                   <*> setupTelegramm .: "about"
                                   <*> setupTelegramm .: "command"
  parseJSON _                       = mzero

instance FromJSON SetupDefault where
  parseJSON (Object setupDefault) = SetupDefault
                                   <$> setupDefault .: "pollingDefault"
                                   <*> setupDefault .: "repeatDefault"
                                   <*> setupDefault .: "logLevelDefault"
  parseJSON _                     = mzero

printPrettyTelegramm :: SetupTelegramm -> String
printPrettyTelegramm (SetupTelegramm urlTelegramm nameTelegramm
     userNameTelegramm tokenTelegramm description about command) =
  "urlTelegramm - "      ++ urlTelegramm ++ "\n" ++
  "tokenTelegramm - "    ++ tokenTelegramm ++ "\n" ++
  "userNameTelegramm - " ++ userNameTelegramm ++ "\n" ++
  "tokenTelegramm - "    ++ tokenTelegramm ++ "\n" ++
  "description - "       ++ description ++ "\n" ++
  "about - "             ++ about ++ "\n" ++
  "command - "           ++ command

printPrettySetup :: SetupDefault -> String
printPrettySetup (SetupDefault pollingDefault repeatDefault
     logLevelDefault) =
  "pollingDefault - "    ++ show pollingDefault ++ "\n" ++
  "repeatDefault - "     ++ show repeatDefault ++ "\n" ++
  "logLevelDefault - "   ++ show logLevelDefault

main :: IO ()
main = do
--       Читаем аргументы командной строки
         commandLine <- getArgs
         putStrLn ("commandLine -" ++ show commandLine)
         let commandLineParse = parseLine commandLine
         putStrLn ("commandLineParse - " ++ show commandLineParse)
--       И инициализируем переменные, при необходимости выводим хелп
--       Определяем пути
         systemPathStart <- getExecutablePath
         let systemPath = makeSystemPath systemPathStart
         putStrLn ("systemPathStart - " ++ show systemPathStart)
         putStrLn ("systemPath - " ++ show systemPath)
--       Читаем файл настроек
         let sysPathConfig = systemPath ++ "/config/configBot"
         let sysPathTelegramm = systemPath ++ "/config/configTelegramm"
{--
  handle (\(e :: IOException) -> print e >> return Nothing) $ do
    h <- openFile sysPathConfig ReadMode
    putStrLn $ show Just h
    return (Just h)
-- Ошибки открытия файла    
    isAlreadyInUseError если файл уже открыт и не может быть открыт повторно;
    isDoesNotExistError, если файл не существует; или
    isPermissionError, если у пользователя нет разрешения на открытие файла.
--}
         rawJSONConfig <- B.readFile sysPathConfig
         let result = decodeStrict rawJSONConfig 
         putStrLn $ case result of
           Nothing           -> "Invalid JSON!"
           Just setupDefault -> printPrettySetup setupDefault

         rawJSONTelegramm <- B.readFile sysPathTelegramm
         let result = decodeStrict rawJSONTelegramm
         putStrLn $ case result of
           Nothing             -> "Invalid JSON!"
           Just setupTelegramm -> printPrettyTelegramm setupTelegramm

--Make systemPath
makeSystemPath :: FilePath -> FilePath
makeSystemPath sPS = concatMap (\x -> "/" ++ x)
                   $ take (length sP - 2) sP
    where sP = words $ map (\x -> if x == '/' then ' ' else x) sPS

