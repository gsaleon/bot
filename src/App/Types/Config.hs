{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.Config where

import           Control.Monad        (mzero)
import           Data.Aeson
import           Prelude hiding       (id)

data Os = Linux | Windows
  deriving (Show)

data Service = Telegramm | Vcontakte
  deriving (Show)

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
