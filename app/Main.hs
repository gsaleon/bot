{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import qualified Data.ByteString as B (readFile)
import           Control.Monad        (mzero)
import           Control.Applicative  ((<$>), (<*>))
--import           Control.Exception
import           Data.Aeson
--import           Data.Monoid          ((<>))
import           System.Environment   (getExecutablePath)
--import           System.IO
--import           Control.Applicative

data Setup = Setup { urlTelegramm           :: String
                   , tokenTelegramm         :: String
                   , repeatDefaultTelegramm :: Int
                   , timePollingSecunds     :: Int
                   , logLevelDefault        :: String
                   }

data FilePath = String

--data Parse = Parse Setup

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

data Service = Telegramm | Vcontakte deriving Show



{--
parseCommandLine :: Parser Setup
parseCommandLine = Setup
     <$> argument auto
          ( metavar "INTEGER"
         <> help "Number of repeat input value, default value - 3" )
     <*> argument auto
          ( metavar "INTEGER"
         <> help "Number of time polling, default value - 60, sec" )
     <*> argument str 
          ( metavar "LOGLEVELDEFAULT"
         <> help "LogLevelDefault - debug" )   

checkSetup :: SetupCommandLine -> Setup -> IO ()
checkSetup (SetupCommandLine repeatDefault timePollingSec)
           (Setup repeatDefaultTelegramm timePollingSecunds) =
            do
              let repeatDefaultTelegramm = repeatDefault
              let timePollingSecunds = timePollingSec
              printPretty setup
--}

main :: IO ()
main = do
--Определяем пути к каталогу
  systemPathStart <- getExecutablePath
  let systemPath = makeSystemPath systemPathStart
  putStrLn $ show systemPathStart
  putStrLn $ show systemPath
-- Читаем файл настроек
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
{--
  execParser opts >>= checkSetup --???
    where
      opts = info (helper <*> parseCommandLine)
             ( fullDesc
            <> progDesc "Telegramm and VK bot"
            <> header "Telegramm and VK bot - repeather"
             )
--}

--Make systemPath
makeSystemPath :: String -> String
makeSystemPath sPS = concat . map (\x -> "/" ++ x)
  $ take ((length sP) - 2) sP
    where sP = words $ map (\x -> if x == '/' then ' ' else x) sPS


