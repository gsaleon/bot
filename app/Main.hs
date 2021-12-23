{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

--import qualified Data.Text as T
import qualified Data.ByteString as B (readFile)
--import           System.IO            (openFile)
import           Control.Monad        (mzero)
import           Control.Exception    (catch)
import           System.IO.Error      (isAlreadyExistsError
                                      , isDoesNotExistError
                                      , isEOFError, isUserError
                                      , isPermissionError)
--import           Control.Applicative  ((<$>), (<*>))
--import           Control.Exception
import           Data.Aeson
--import           Data.Monoid          ((<>))
import           System.Environment   (getArgs, getExecutablePath)
--import           System.IO
--import           Control.Applicative
import           Debug.Trace()                     -- для отладки, по готовности проги - удалить!!
--import           System.FilePath

import           Services.ParseCommandLine
--import           App.Handlers.LogCommandLine

--Определения типов, использующихся в программе
newtype Repeat = Repeat Int

newtype Polling = Polling Int

data Service = Telegramm | Vcontakte deriving Show

data LogLevel = Debug | Info | Warning | Error deriving (Eq, Ord, Show)

data SetupTelegramm = SetupTelegramm
                    { urlTelegramm         :: String
                    , nameTelegramm        :: String
                    , userNameTelegramm    :: String
                    , tokenTelegramm       :: String
                    , descriptionTelegramm :: String
                    , aboutTelegramm       :: String
                    , commandTelegramm     :: String
                    }

instance FromJSON SetupTelegramm where
  parseJSON (Object setupTelegramm) = SetupTelegramm
    <$> setupTelegramm .: "urlTelegramm"
    <*> setupTelegramm .: "nameTelegramm"
    <*> setupTelegramm .: "userNameTelegramm"
    <*> setupTelegramm .: "tokenTelegramm"
    <*> setupTelegramm .: "descriptionTelegramm"
    <*> setupTelegramm .: "aboutTelegramm"
    <*> setupTelegramm .: "commandTelegramm"
  parseJSON _                       = mzero

data SetupVcontakte = SetupVcontakte
                    { urlVcontakte         :: String
                    , nameVcontakte        :: String
                    , userNameVcontakte    :: String
                    , tokenVcontakte       :: String
                    , descriptionVcontakte :: String
                    , aboutVcontakte       :: String
                    , commandVcontakte     :: String
                    }

instance FromJSON SetupVcontakte where
  parseJSON (Object setupVcontakte) = SetupVcontakte
    <$> setupVcontakte .: "urlVcontakte"
    <*> setupVcontakte .: "nameVcontakte"
    <*> setupVcontakte .: "userNameVcontakte"
    <*> setupVcontakte .: "tokenVcontakte"
    <*> setupVcontakte .: "descriptionVcontakte"
    <*> setupVcontakte .: "aboutVcontakte"
    <*> setupVcontakte .: "commandVcontakte"
  parseJSON _                     = mzero

data SetupDefault = SetupDefault
                  { pollingDefault    :: Int
                  , repeatDefault     :: Int
                  , logLevelDefault   :: String
                  }

instance FromJSON SetupDefault where
  parseJSON (Object setupDefault) = SetupDefault
    <$> setupDefault .: "pollingDefault"
    <*> setupDefault .: "repeatDefault"
    <*> setupDefault .: "logLevelDefault"
  parseJSON _                     = mzero

printPrettyVcontakte :: SetupVcontakte -> String
printPrettyVcontakte (SetupVcontakte urlVcontakte nameVcontakte
     userNameVcontakte tokenVcontakte descriptionVcontakte
     aboutVcontakte commandVcontakte) =
  "urlVcontakte -         " ++ urlVcontakte         ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "userNameVcontakte -    " ++ userNameVcontakte    ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "descriptionVcontakte - " ++ descriptionVcontakte ++ "\n" ++
  "aboutVcontakte -       " ++ aboutVcontakte       ++ "\n" ++
  "commandVcontakte -     " ++ commandVcontakte

printPrettyTelegramm :: SetupTelegramm -> String
printPrettyTelegramm (SetupTelegramm urlTelegramm nameTelegramm
     userNameTelegramm tokenTelegramm descriptionTelegramm
     aboutTelegramm commandTelegramm) =
  "urlTelegramm -         " ++ urlTelegramm         ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "userNameTelegramm -    " ++ userNameTelegramm    ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "descriptionTelegramm - " ++ descriptionTelegramm ++ "\n" ++
  "aboutTelegramm -       " ++ aboutTelegramm       ++ "\n" ++
  "commandTelegramm -     " ++ commandTelegramm

printPrettySetup :: SetupDefault -> String
printPrettySetup (SetupDefault pollingDefault repeatDefault
     logLevelDefault) =
  "pollingDefault -    " ++ show pollingDefault ++ "\n" ++
  "repeatDefault -     " ++ show repeatDefault  ++ "\n" ++
  "logLevelDefault -   " ++ show logLevelDefault

main :: IO ()
main = do
         putStrLn ("---------Start---------")
--       Читаем аргументы командной строки
         commandLine <- getArgs
         let commandLineParse = parseLine commandLine
         putStrLn ("commandLineParse - " ++ show commandLineParse)
--       И инициализируем переменные, при необходимости выводим хелп
--       Определяем пути
         systemPathStart <- getExecutablePath
         let systemPath = makeSystemPath systemPathStart
--         putStrLn ("systemPathStart - " ++ show systemPathStart)
         putStrLn ("systemPath - " ++ show systemPath)
--       Проверяем и читаем файлы настроек
         let sysPathConfig = systemPath ++ "/config/configBot"
         let sysPathTelegramm = systemPath ++ "/config/configTelegramm"
         let sysPathVcontakte = systemPath ++ "/config/configVcontakte"
         catch (readFile sysPathConfig >>= putStrLn)
          (\out ->  case out of
              _  | isAlreadyExistsError out -> putStrLn "Error: File configBot alredy exists"
              _  | isDoesNotExistError out  -> putStrLn "Error: File configBot not found"
              _  | isEOFError out           -> putStrLn "Error: End of file configBot"
              _  | isUserError out          -> putStrLn "Error: User raised an exception"
              _  | isPermissionError out    -> putStrLn "Error: We don't have permission to read this file configBot"
              _                             -> putStrLn "Uncaught exception configBot" >> ioError out
          )
         catch (readFile sysPathVcontakte >>= putStrLn)
          (\out ->  case out of
              _  | isAlreadyExistsError out -> putStrLn "Error: File configTelegramm alredy exists"
              _  | isDoesNotExistError out  -> putStrLn "Error: File configTelegramm not found"
              _  | isEOFError out           -> putStrLn "Error: End of file configTelegramm"
              _  | isUserError out          -> putStrLn "Error: User raised an exception"
              _  | isPermissionError out    -> putStrLn "Error: We don't have permission to read this file configTelegramm"
              _                             -> putStrLn "Uncaught exception configTelegramm" >> ioError out
          )
         catch (readFile sysPathTelegramm >>= putStrLn)
          (\out ->  case out of
              _  | isAlreadyExistsError out -> putStrLn "Error: File configTelegramm alredy exists"
              _  | isDoesNotExistError out  -> putStrLn "Error: File configTelegramm not found"
              _  | isEOFError out           -> putStrLn "Error: End of file configTelegramm"
              _  | isUserError out          -> putStrLn "Error: User raised an exception"
              _  | isPermissionError out    -> putStrLn "Error: We don't have permission to read this file configTelegramm"
              _                             -> putStrLn "Uncaught exception configTelegramm" >> ioError out
          )

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

         rawJSONVcontakte <- B.readFile sysPathVcontakte
         let result = decodeStrict rawJSONVcontakte
         putStrLn $ case result of
           Nothing             -> "Invalid JSON!"
           Just setupVcontakte -> printPrettyVcontakte setupVcontakte

makeSystemPath :: FilePath -> FilePath
makeSystemPath str = (makeSystemPath' str) ++ "/bot/"
makeSystemPath' [] = []
makeSystemPath' (x0:x1:x2:x3:x4:xs)
  | x0:x1:x2:x3:x4:[] /= "/bot/" = x0 : makeSystemPath' (x1:x2:x3:x4:xs)
  | otherwise            = []

