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

data SessionKey = SessionKey
                { vkServer :: String
                , vkKey    :: String
                , vkTs     :: String
                } deriving (Show)

instance FromJSON SessionKey where
  parseJSON = withObject "SessionKey" $ \s -> do
    r        <- s .: "response"
    vkKey    <- r .: "key"
    vkServer <- r .: "server"
    vkTs     <- r .: "ts"
    return SessionKey {..}

data VkConnect = VkConnect
               { vkTsNew  :: String
               , updates  :: Object
               , typeVk   :: String
               , objectVk :: Object
               , text     :: String
               } deriving (Show)

instance FromJSON VkConnect where
  parseJSON = withObject "VkConnect" $ \v -> do
    vkTsNew  <- v        .: "ts"
    updates  <- v        .: "updates"
    typeVk   <- updates  .: "type"
    objectVk <- updates  .: "object"
    text     <- objectVk .: "text"
    return VkConnect {..}