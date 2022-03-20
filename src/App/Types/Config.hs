{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.Config where

import           Control.Monad        (mzero)
import           Data.Aeson
import           Prelude hiding       (id)
import           Data.Yaml
import           GHC.Generics

data SetupGeneral = SetupGeneral
            { pollingGeneral :: Int
            , repeatGeneral :: Int
            , logLevelGeneral :: String
            , serviceGeneral :: String
            } deriving Show

instance FromJSON SetupGeneral where
  parseJSON = withObject "SetupGeneral" $ \s -> do
    pollingGeneral  <- s .: "pollingGeneral"
    repeatGeneral   <- s .: "repeatGeneral"
    logLevelGeneral <- s .: "logLevelGeneral"
    serviceGeneral  <- s .: "serviceGeneral"
    return SetupGeneral {..}

-- data CommandLineSet = CommandLineSet {helpLine :: String} deriving Show

-- instance FromJSON CommandLineSet where
--   parseJSON = withObject "CommandLineSet" $ \s -> do
--     -- s              <- o .: "CommandLineSet"
--     helpLine       <- s .: "helpLine"
--     return CommandLineSet {..}


data Service = Telegramm | Vcontakte
  deriving (Show)

{-data SetupGeneral = SetupGeneral
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
-}