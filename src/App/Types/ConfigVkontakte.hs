{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
import           Control.Monad        (mzero)

data SetupVkontakte = SetupVkontakte
                    { urlVkontakte   :: String
                    , tokenVkontakte :: String
                    , version        :: Float   -- 5.131 in use
                    , lang           :: Int     -- 0-ru, 3-en
                    , test_mode      :: Int     -- 0-normal, 1-test
                    } deriving Show

instance FromJSON SetupVkontakte where
  parseJSON (Object setupVkontakte) = SetupVkontakte
    <$> setupVkontakte .: "urlVkontakte"
    <*> setupVkontakte .: "tokenVkontakte"
    <*> setupVkontakte .: "version"
    <*> setupVkontakte .: "lang"
    <*> setupVkontakte .: "test_mode"
  parseJSON _                       = mzero
