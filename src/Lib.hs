{-# LANGUAGE OverloadedStrings #-}

module Lib where

import           Control.Monad        (mzero)
import           Data.Aeson

import           Services.ParseCommandLine (Parse(Err, Value))

--Определения типов, использующихся в программе
data Os = Linux | Windows
  deriving Show

data Service = Telegramm | Vcontakte
  deriving Show

data LogLevel = Debug | Info | Warning | Error
  deriving (Eq, Ord, Show)

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
     aboutVcontakte commandVcontakte) =
  "urlVcontakte -         " ++ urlVcontakte         ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "userNameVcontakte -    " ++ userNameVcontakte    ++ "\n" ++
  "tokenVcontakte -       " ++ tokenVcontakte       ++ "\n" ++
  "descriptionVcontakte - " ++ descriptionVcontakte ++ "\n" ++
  "aboutVcontakte -       " ++ aboutVcontakte       ++ "\n" ++
  "commandVcontakte -     " ++ commandVcontakte     ++ "\n" ++
  "----------------------end printPrettyVcontakte------------"

printPrettyTelegramm :: SetupTelegramm -> String
printPrettyTelegramm (SetupTelegramm urlTelegramm nameTelegramm
     userNameTelegramm tokenTelegramm descriptionTelegramm
     aboutTelegramm commandTelegramm questionTelegrammRepeat) =
  "urlTelegramm -         " ++ urlTelegramm         ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "userNameTelegramm -    " ++ userNameTelegramm    ++ "\n" ++
  "tokenTelegramm -       " ++ tokenTelegramm       ++ "\n" ++
  "descriptionTelegramm - " ++ descriptionTelegramm ++ "\n" ++
  "aboutTelegramm -       " ++ aboutTelegramm       ++ "\n" ++
  "commandTelegramm -     " ++ commandTelegramm     ++ "\n" ++
  "questionTelegrammRepeat" ++ "\n" ++
  "----------------------end printPrettyTelegramm------------"

printPrettySetup :: SetupGeneral -> String
printPrettySetup (SetupGeneral pollingGeneral repeatGeneral
     logLevelGeneral serviceGeneral) =
  "pollingGeneral -       " ++ show pollingGeneral  ++ "\n" ++
  "repeatGeneral -        " ++ show repeatGeneral   ++ "\n" ++
  "logLevelGeneral -      " ++ show logLevelGeneral ++ "\n" ++
  "serviceGeneral -       " ++ show serviceGeneral  ++ "\n" ++
  "----------------------end printPrettySetup----------------"

{--
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
--}

valueParse :: Parse a b -> [(String,String)]
valueParse commandLineParse = fromRight [("","")] commandLineParse

fromCommandLine :: SetupGeneral -> [(String,String)] -> SetupGeneral
fromCommandLine p v =
  if (isJust $ find ((=="polling:") . fst) v)
    then 
      let x = read $ snd $ fromJust $ find ((=="polling:") . fst) v :: Int
        in fromCommandLine {pollingGeneral  = x}
    else   fromCommandLine {pollingGeneral  = pollingGeneral (p)}
  if (isJust $ find ((=="repeat:") . fst) v)
    then 
      let x = read $ snd $ fromJust $ find ((=="repeat:") . fst) v :: Int
        in fromCommandLine {repeatGeneral   = x}
    else   fromCommandLine {repeatGeneral   = repeatGeneral (p)}
  if (isJust $ find ((=="loglevel:") . fst) v)
    then 
      let x = snd $ fromJust $ find ((=="loglevel:") . fst) v
        in fromCommandLine {logLevelGeneral = x}
    else   fromCommandLine {logLevelGeneral = logLevelGeneral (p)}
  if (isJust $ find ((=="service:") . fst) v)
    then 
      let x = snd $ fromJust $ find ((=="service:") . fst) v
        in fromCommandLine {serviceGeneral  = x}
    else   fromCommandLine {serviceGeneral  = serviceGeneral (p)}


{--
  if isJust $ find ((=="polling:") . fst) valueParse
    then snd $ fromJust $ find ((=="polling:") . fst) valueParse
--       concat $ map (\x -> case x of ("polling:", y) -> y ; _ -> "") valueParse
    else repeatGeneral setupGeneral

--repeatGeneral ::
repeatGeneral workValue =
  if isJust $ find ((=="repeat:") . fst) valueParse
    then snd $ fromJust $ find ((=="repeat:") . fst) valueParse
    else repeatGeneral setupGeneral

--loglevelGeneral ::
loglevelGeneral workValue =
  if isJust $ find ((=="loglevel:") . fst) valueParse
    then snd $ fromJust $ find ((=="loglevel:") . fst) valueParse
    else loglevelGeneral setupGeneral

--serviceGeneral ::
serviceGeneral workValue =
  if isJust $ find ((=="service:") . fst) valueParse
    then snd $ fromJust $ find ((=="service:") . fst) valueParse
    else serviceGeneral setupGeneral
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
