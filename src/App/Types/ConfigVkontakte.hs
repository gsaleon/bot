{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types.ConfigVkontakte where

import           Data.Aeson
import           Control.Monad        (mzero)

data SetupVkontakte = SetupVkontakte
                    { urlVkontakte   :: String
                    , client_id      :: Int
                    , group_id       :: Int
                    , tokenVkontakte :: String
                    , version        :: Float   -- 5.131 in use
                    , lang           :: Int     -- 0-ru, 3-en
                    , test_mode      :: Int     -- 0-normal, 1-test
                    } deriving Show

instance FromJSON SetupVkontakte where
  parseJSON (Object setupVkontakte) = SetupVkontakte
    <$> setupVkontakte .: "urlVkontakte"
    <*> setupVkontakte .: "client_id"
    <*> setupVkontakte .: "group_id"
    <*> setupVkontakte .: "tokenVkontakte"
    <*> setupVkontakte .: "version"
    <*> setupVkontakte .: "lang"
    <*> setupVkontakte .: "test_mode"
  parseJSON _                       = mzero

newtype MessagesGetLongPollServer = MessagesGetLongPollServer
                                  { response :: SessionKey
                                  } deriving (Show)

instance FromJSON MessagesGetLongPollServer where
  parseJSON (Object r) = MessagesGetLongPollServer
    <$> r .: "response"
  parseJSON _          = mzero

data SessionKey = SessionKey
                { longPollServer :: String
                , longPollkey    :: String
                , longPollTs     :: Int
                } deriving (Show)

instance FromJSON SessionKey where
  parseJSON = withObject "SessionKey" $ \s -> do
    longPollServer <- s .: "server"
    longPollkey    <- s .: "key"
    longPollTs     <- s .: "ts"
    return SessionKey {..}
