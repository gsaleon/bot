{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
import           Control.Monad        (mzero)

data SetupVkontakte = SetupVkontakte
                    { urlVkontakte         :: String
                    , nameVkontakte        :: String
                    , userNameVkontakte    :: String
                    , tokenVkontakte       :: String
                    , descriptionVkontakte :: String
                    , aboutVkontakte       :: String
                    , commandVkontakte     :: String
                    } deriving Show

instance FromJSON SetupVkontakte where
  parseJSON (Object setupVkontakte) = SetupVkontakte
    <$> setupVkontakte .: "urlVkontakte"
    <*> setupVkontakte .: "nameVkontakte"
    <*> setupVkontakte .: "userNameVkontakte"
    <*> setupVkontakte .: "tokenVkontakte"
    <*> setupVkontakte .: "descriptionVkontakte"
    <*> setupVkontakte .: "aboutVkontakte"
    <*> setupVkontakte .: "commandVkontakte"
  parseJSON _                       = mzero
