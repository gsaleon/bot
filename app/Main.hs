{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

--import qualified Data.ByteString as B (readFile)
import           Control.Monad        (mzero)
--import           Control.Applicative  ((<$>), (<*>))
--import           Control.Exception
import           Data.Aeson
--import           Data.Monoid          ((<>))
import           System.Environment   (getArgs)
--import           System.IO
--import           Control.Applicative


import           Services.ParseCommandLine


data Setup = Setup { urlTelegramm           :: String
                   , tokenTelegramm         :: String
                   , repeatDefaultTelegramm :: Int
                   , timePollingSecunds     :: Int
                   , logLevelDefault        :: String
                   }

data SetupCommandLine = SetupCommandLine
                   { repeatDefault  :: Int
                   , timePollingSec :: Int
                   }


instance FromJSON Setup where
  parseJSON (Object setup) = Setup <$> setup .: "urlTelegramm"
                                   <*> setup .: "tokenTelegramm"
                                   <*> setup .: "repeatDefaultTelegramm"
                                   <*> setup .: "timePollingSecunds"
                                   <*> setup .: "logLevelDefault"
  parseJSON _              = mzero

printPretty :: Setup -> String
printPretty (Setup urlTelegramm tokenTelegramm repeatDefaultTelegramm
             timePollingSecunds logLevelDefault)
  = urlTelegramm ++ " -> " ++ tokenTelegramm ++ " -> "
    ++ show repeatDefaultTelegramm ++ " -> " ++ show timePollingSecunds
    ++ " -> " ++ show logLevelDefault


--Определения типов, использующихся в программе
type FilePathBot = String

newtype Repeat = Repeat Int

data Service = Telegramm | Vcontakte deriving Show

data LogLevel = Debug | Info | Warning | Error deriving Show

main :: IO ()
main = do
--       Читаем аргументы командной строки
         commandLine <- getArgs
         putStrLn $ show commandLine
         let commandLineValue = parseLine commandLine
         putStrLn $ show commandLineValue
{--
--       Определяем пути
         systemPathStart <- getExecutablePath
         let systemPath = makeSystemPath systemPathStart
         putStrLn $ show systemPathStart
         putStrLn $ show systemPath
--       Читаем файл настроек
         let sysPathConfig = systemPath ++ "/config/config.ini"
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
  rawJSON <- B.readFile sysPathConfig
  let result = decodeStrict rawJSON
  putStrLn $ case result of
        Nothing    -> "Invalid JSON!"
        Just setup -> printPretty setup

--Make systemPath
makeSystemPath :: FilePathBot -> FilePathBot
makeSystemPath sPS = concat . map (\x -> "/" ++ x)
  $ take ((length sP) - 2) sP
    where sP = words $ map (\x -> if x == '/' then ' ' else x) sPS
--}
