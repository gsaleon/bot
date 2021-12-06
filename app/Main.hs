{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString as B (readFile)
import           Control.Monad        (mzero)
import           Control.Applicative  ((<$>), (<*>))
import           Data.Aeson
import           Data.Monoid          ((<>))
import           System.Environment   (getExecutablePath)
import           Control.Applicative

data Setup = Setup { urlTelegramm   :: String
                   , tokenTelegramm :: String
                   , repeatDefaultTelegramm :: Int
                   , timePollingSecunds :: Int
                   , language :: String
                   }

instance FromJSON Setup where
  parseJSON (Object setup) = Setup <$> setup .: "urlTelegramm"
                                   <*> setup .: "tokenTelegramm"
                                   <*> setup .: "repeatDefaultTelegramm"
                                   <*> setup .: "timePollingSecunds"
                                   <*> setup .: "language"
  parseJSON _              = mzero

printPretty :: Setup -> String
printPretty (Setup urlTelegramm tokenTelegramm repeatDefaultTelegramm
             timePollingSecunds language)
  = urlTelegramm ++ " -> " ++ tokenTelegramm ++ " -> "
    ++ show repeatDefaultTelegramm ++ " -> " ++ show timePollingSecunds
    ++ " -> " ++ language

main :: IO ()
main = do
--Определяем пути к каталогу
  systemPathStart <- getExecutablePath
  let systemPath = makeSystemPath systemPathStart
  putStrLn $ show systemPathStart
  putStrLn $ show systemPath
-- Читаем файл настроек
  let sysPathConfig = systemPath ++ "/config/config.ini"
  rawJSON <- B.readFile sysPathConfig
-- Проверки, связанные с чтением файла, опущены...
  let result = decodeStrict rawJSON
  putStrLn $ case result of
        Nothing    -> "Invalid JSON!"
        Just setup -> printPretty setup
--}

--Make systemPath
makeSystemPath :: String -> String
makeSystemPath sPS = concat . map (\x -> "/" ++ x)
  $ take ((length sP) - 2) sP
    where sP = words $ map (\x -> if x == '/' then ' ' else x) sPS

-- Replacing all symbols 'cs' to symbol 'cd' in string.
replacing :: Char -> Char -> String -> String
replacing _  _ [] = []
replacing cs cd (x:xs)
  | x == cs = cd : replacing cs cd xs
  | otherwise = x : replacing cs cd xs
