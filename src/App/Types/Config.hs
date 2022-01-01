{-# LANGUAGE OverloadedStrings #-}

module App.Types.Config where

import           Control.Monad        (mzero)
import           Data.Aeson

--Define Types wich uses in Config modules
data Os = Linux | Windows
  deriving Show

data Service = Telegramm | Vcontakte
  deriving Show

--data LogLevel = Debug | Info | Warning | Error
--  deriving (Eq, Ord, Show)

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
